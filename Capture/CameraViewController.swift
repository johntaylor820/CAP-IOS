//
//  CameraViewController.swift
//  Capture
//
//  Created by Mathias Palm on 2016-06-23.
//  Copyright © 2016 capture. All rights reserved.
//

import UIKit
import AVFoundation
import GPUImage
import CoreData
import Photos

class CameraViewController: UIViewController {
    
    @IBOutlet weak var flashButton: Button!
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var stabilizationOnOffLabel: UILabel!
    @IBOutlet weak var recordButton: Button!
    @IBOutlet weak var previousButton: RoundButton!
    @IBOutlet weak var gridButton: Button!
    @IBOutlet weak var stabilizationButton: UIButton!
    @IBOutlet weak var flipButton: Button!
    
    var currentCameraDevice:AVCaptureDevice?


    var timer = Timer()
    var startTime = TimeInterval()
    
    var asset:URL?
    var croppingFrame:CGRect?
    var rotation:GPUImageRotationMode?
    var transform1:GPUImageTransformFilter?
    var cropFilter: GPUImageCropFilter?
    var movieFile:GPUImageMovie?
    var movieView:GPUImageView!
    let screenheight = UIScreen.main.bounds.height
    var flashOn = UIImage(named: "flashOn")
    var flashOff = UIImage(named: "flashOff")
    
    let managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
    var filterItems = [Custom_Filters]()
    var updateFetch = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        movieView = GPUImageView(frame: videoView.frame)
        videoView.addSubview(movieView)
        navigationController?.navigationBar.barTintColor = UIColor.white
        navigationController?.navigationBar.alpha = 1

        setupCameraSession()
        fetchPhotoAtIndexFromEnd()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.barTintColor = UIColor(red: 24/255, green: 24/255, blue: 24/255, alpha: 1.0)
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.barStyle = UIBarStyle.black
        navigationController?.navigationBar.titleTextAttributes = [
            NSFontAttributeName: UIFont(name: "HelveticaNeue-Light", size: 20)!,
            NSForegroundColorAttributeName: UIColor(red: 1, green: 1, blue: 1, alpha: 1.0)
        ]
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        videoView.layer.addSublayer(previewLayer)
        
        cameraSession.startRunning()
        
        checkIfStaticFilters()

    }
    
    lazy var cameraSession: AVCaptureSession = {
        let s = AVCaptureSession()
        s.sessionPreset = AVCaptureSessionPresetHigh
        return s
    }()
    
    lazy var previewLayer: AVCaptureVideoPreviewLayer = {
        let preview:AVCaptureVideoPreviewLayer =  AVCaptureVideoPreviewLayer(session: self.cameraSession)
        preview.bounds = CGRect(x: 0, y: 0, width: self.videoView.bounds.width, height: self.videoView.bounds.height)
        preview.position = CGPoint(x: self.videoView.bounds.midX, y: self.videoView.bounds.midY)
        preview.videoGravity = AVLayerVideoGravityResizeAspectFill
        return preview
    }()
    var hasFrontCamera: Bool = {
        let devices = AVCaptureDevice.devices(withMediaType: AVMediaTypeVideo)
        for  device in devices!  {
            let captureDevice = device as! AVCaptureDevice
            if (captureDevice.position == .front) {
                return true
            }
        }
        return false
    }()
    /*lazy var dataOutput: AVCaptureVideoDataOutput = {
        let output = AVCaptureVideoDataOutput()
        output.videoSettings = [(kCVPixelBufferPixelFormatTypeKey as NSString) : NSNumber(unsignedInt: kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)]
        output.alwaysDiscardsLateVideoFrames = false
        return output
    }()*/
    
    lazy var videoFileOutput = AVCaptureMovieFileOutput()
    
    var videoIsStabalized = false
    
    func setupCameraSession() {
        let captureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo) as AVCaptureDevice
        if (captureDevice.hasTorch) {
            do {
                try captureDevice.lockForConfiguration()
                flashButton.setImage(flashOff, for: UIControlState())
                captureDevice.torchMode = AVCaptureTorchMode.off
                captureDevice.unlockForConfiguration()
            } catch {
                print(error)
            }
        }
        let audioDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeAudio) as AVCaptureDevice
        do {
            let deviceInput = try AVCaptureDeviceInput(device: captureDevice)
            
            let audioDeviceIput = try AVCaptureDeviceInput(device: audioDevice)
            
            cameraSession.beginConfiguration()
            
            if cameraSession.canAddInput(audioDeviceIput) {
                cameraSession.addInput(audioDeviceIput)
            }
            
            if cameraSession.canAddInput(deviceInput) {
                cameraSession.addInput(deviceInput)
            }
            
            /*if (cameraSession.canAddOutput(dataOutput) == true) {
                cameraSession.addOutput(dataOutput)
            }*/
            
            if cameraSession.canAddOutput(videoFileOutput) {
                cameraSession.addOutput(videoFileOutput)
            }
            
            cameraSession.commitConfiguration()

            currentCameraDevice = captureDevice
            toggleStabilization()
            
        }
        catch let error as NSError {
            NSLog("\(error), \(error.localizedDescription)")
        }
    }
    func neutralizeRect(_ rect:CGRect) -> CGRect {
        let transform = CGAffineTransform(scaleX: 1.0/view.frame.size.width, y: 1.0/screenheight)
        return rect.applying(transform)
    }
    func RadiansToDegrees(_ radians: CGFloat) -> CGFloat {
        return radians * 180.0 / CGFloat(M_PI)
    }
    func orientationOfVideo(_ asset: AVAsset) -> GPUImageRotationMode {
        let videoTracks = asset.tracks(withMediaType: AVMediaTypeVideo).first
        if let track = videoTracks {
            let txf = track.preferredTransform
            let videoAngle = self.RadiansToDegrees(atan2(txf.b, txf.a))
            switch videoAngle {
            case 0:
                return kGPUImageNoRotation
            case 90:
                return kGPUImageRotateRight
            case 180:
                return kGPUImageRotate180
            case -90:
                return kGPUImageRotateLeft
            default:
                return kGPUImageNoRotation
            }
        } else {
            return kGPUImageNoRotation
        }
    }
    
    func toggleStabilization() {
        let captureDevice = videoFileOutput.connection(withMediaType: AVMediaTypeVideo)
        
        if (captureDevice?.isVideoStabilizationSupported)! {
            if videoIsStabalized {
                videoIsStabalized = false
                captureDevice?.preferredVideoStabilizationMode = AVCaptureVideoStabilizationMode.off
            } else {
                captureDevice?.preferredVideoStabilizationMode = AVCaptureVideoStabilizationMode.auto
                videoIsStabalized = true
            }
        }
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "moveToNewEdit" {
            let vc: EditsViewController = segue.destination as! EditsViewController
            vc.videoAsset = asset!
            vc.orientation = rotation
            vc.croppingFrame = croppingFrame
            movieFile!.endProcessing()
            movieFile!.removeAllTargets()
            transform1!.removeAllTargets()
            cropFilter!.removeAllTargets()
        }
    }

}
extension CameraViewController: AVCaptureFileOutputRecordingDelegate {
    func capture(_ captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAt outputFileURL: URL!, fromConnections connections: [Any]!, error: Error!) {
        movieFile = GPUImageMovie(url: outputFileURL)
        movieView.frame = videoView.frame
        movieFile!.playAtActualSpeed = true
        movieFile!.shouldRepeat = true
        asset = outputFileURL
        rotation = orientationOfVideo(AVAsset(url:outputFileURL))
        transform1 = GPUImageTransformFilter()
        transform1!.setInputRotation(rotation!, at: 0)
        croppingFrame = neutralizeRect(videoView.frame)
        croppingFrame!.origin.y = view.frame.origin.y*2 / view.frame.size.height
        cropFilter = GPUImageCropFilter(cropRegion: croppingFrame!)
        movieFile!.addTarget(transform1)
        transform1!.addTarget(cropFilter!)
        cropFilter!.addTarget(movieView)
        movieFile!.startProcessing()
        cameraSession.stopRunning()
        previewLayer.isHidden = true
        enableButtons(false)
    }
    
    func capture(_ captureOutput: AVCaptureFileOutput!, didStartRecordingToOutputFileAt fileURL: URL!, fromConnections connections: [Any]!) {
        
    }
}
extension CameraViewController {
    // MARK: - Actions
    
    @IBAction func recordButtonPressed(_ sender: UIButton) {
        if sender.isSelected {
            sender.isSelected = false
            videoFileOutput.stopRecording()
            timer.invalidate()
        } else {
            sender.isSelected = true
            let recordingDelegate:AVCaptureFileOutputRecordingDelegate? = self
            
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let dateString = "\(Date())"
            let fileName = "\(dateString.removeWhitespace()).mp4"
            let filePath = documentsURL.appendingPathComponent(fileName)
            
            videoFileOutput.startRecording(toOutputFileURL: filePath, recordingDelegate: recordingDelegate)
            if (!timer.isValid) {
                timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(CameraViewController.updateTime), userInfo: nil, repeats: true)
                startTime = Date.timeIntervalSinceReferenceDate
            }
        }
    }
    
    func enableButtons(_ isEnabled:Bool) {
        flashButton.isEnabled = isEnabled
        flipButton.isEnabled = isEnabled
        recordButton.isEnabled = isEnabled
        stabilizationButton.isEnabled = isEnabled
        previousButton.isEnabled = isEnabled
        gridButton.isEnabled = isEnabled
    }
    
    func updateTime() {
        let currentTime = Date.timeIntervalSinceReferenceDate
        
        var elapsedTime: TimeInterval = currentTime - startTime
        
        let minutes = UInt8(elapsedTime / 60.0)
        elapsedTime -= (TimeInterval(minutes) * 60)
        
        let seconds = UInt8(elapsedTime)
        elapsedTime -= TimeInterval(seconds)
        
        let strMinutes = String(format: "%01d", minutes)
        let strSeconds = String(format: "%02d", seconds)
        
        let text = "\(strMinutes):\(strSeconds)"
        navigationController?.navigationBar.topItem?.title = text
    }
    
    @IBAction func toggleStabilazation(_ sender: UIButton) {
        if stabilizationOnOffLabel.text == "ON" {
            stabilizationOnOffLabel.text = "OFF"
            toggleStabilization()
        } else {
            stabilizationOnOffLabel.text = "ON"
            toggleStabilization()
        }
    }
    
    @IBAction func cancelButtonPressed(_ sender: AnyObject) {
        if let movieFile = movieFile {
            movieFile.endProcessing()
            self.movieFile = nil
            cameraSession.startRunning()
            navigationController?.navigationBar.topItem?.title = "0:00"
            previewLayer.isHidden = false
            asset = nil
            enableButtons(true)
        } else {
            self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func acceptbuttonPressed(_ sender: AnyObject) {
        if let _ = asset {
            performSegue(withIdentifier: "moveToNewEdit", sender: nil)
        }
    }
    @IBAction func videoAlbumPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "goToImport", sender: nil)
    }
    
    @IBAction func toggleFlashButtonPressed(_ sender: UIButton) {
        let device = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        if (device?.hasTorch)! {
            do {
                try device?.lockForConfiguration()
                if (device?.torchMode == AVCaptureTorchMode.on) {
                    flashButton.setImage(flashOff, for: UIControlState())
                    device?.torchMode = AVCaptureTorchMode.off
                } else {
                    flashButton.setImage(flashOn, for: UIControlState())
                    device?.torchMode = AVCaptureTorchMode.on
                }
                device?.unlockForConfiguration()
            } catch {
                print(error)
            }
        }
    }
    @IBAction func flipCameraButtonPressed(_ sender: UIButton) {
        var backCameraDevice:AVCaptureDevice?
        var frontCameraDevice:AVCaptureDevice?
        var rearCamera: AVCaptureInput?
        var frontCamera: AVCaptureInput?
        let availableCameraDevices = AVCaptureDevice.devices()
        let audioDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeAudio) as AVCaptureDevice

        for device in availableCameraDevices as! [AVCaptureDevice] {
            if device.position == .back {
                backCameraDevice = device
            }
            else if device.position == .front {
                frontCameraDevice = device
            }
        }
        
        do {
            let audioDeviceIput = try AVCaptureDeviceInput(device: audioDevice)
            cameraSession.beginConfiguration()
            var newCamera: AVCaptureDevice?
            if let validVideoFrontDevice = frontCameraDevice {
                frontCamera = try AVCaptureDeviceInput(device: validVideoFrontDevice)
            }
            if let validVideoBackDevice = backCameraDevice {
                rearCamera = try AVCaptureDeviceInput(device: validVideoBackDevice)
            }
            for ii in cameraSession.inputs {
                cameraSession.removeInput(ii as! AVCaptureInput)
            }
            if cameraSession.canAddInput(audioDeviceIput) {
                cameraSession.addInput(audioDeviceIput)
            }
            if currentCameraDevice!.position == AVCaptureDevicePosition.back {
                newCamera = frontCameraDevice
                if self.hasFrontCamera {
                    if let validFrontDevice = frontCamera {
                        if cameraSession.canAddInput(validFrontDevice) {
                            cameraSession.addInput(validFrontDevice)
                        }
                    }
                }
            } else {
                newCamera = backCameraDevice
                if let validRearDevice = rearCamera {
                    if cameraSession.canAddInput(validRearDevice) {
                        cameraSession.addInput(validRearDevice)
                    }
                }
            }
            
            
            cameraSession.commitConfiguration()
            currentCameraDevice! = newCamera!
        }
        catch let error as NSError {
            NSLog("\(error), \(error.localizedDescription)")
        }
        
    }
}

extension CameraViewController {
    func fetchPhotoAtIndexFromEnd() {
        
        let imgManager = PHImageManager.default()
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = true
        
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key:"creationDate", ascending: false)]
        
        let fetchResult: PHFetchResult = PHAsset.fetchAssets(with: PHAssetMediaType.video, options: fetchOptions)
        if fetchResult.count > 0, let fetch = fetchResult.firstObject {
            imgManager.requestImage(for: fetch, targetSize: CGSize(width: 100, height: 100), contentMode: PHImageContentMode.aspectFill, options: requestOptions, resultHandler: { (image, _) in
                if let image = image {
                    DispatchQueue.main.async(execute: {
                        self.previousButton.setImage(image, for: UIControlState())
                    })
                }
            })
        }
    }
}

extension CameraViewController {
    // Retreive the managedObjectContext from AppDelegate
    
    func checkIfStaticFilters() {
        let filePath = Bundle.main.path(forResource: "StaticFilters",ofType:"json")
        var readError:NSError?
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: filePath!), options:NSData.ReadingOptions.uncached)
            let json = JSON(data: data)
            for (_, subJson) in json {
                fetchFilters()
                if let filterName = subJson["filterName"].string{
                    let testEntity = checkIfEntityExist(filterName)
                    if !testEntity {
                        var filter = [String: Float]()
                        for (key, value) in subJson {
                            filter[key] = value.float
                        }
                        let orginalImage = GPUImagePicture(image: UIImage(named: "filterimage.png"))
                        var groupFilters = [GPUImageOutput]()
                        if let contrast = subJson["contrast"].float {
                            var tempVal: CGFloat = 0
                            if contrast > 0.99 {
                                tempVal = CGFloat(contrast) * 50.0
                            } else {
                                tempVal = (CGFloat(contrast) - 0.5) * 100.0
                            }
                            filterOperations[0].updateBasedOnSliderValue(tempVal)
                            groupFilters.append(filterOperations[0].filter)
                        }
                        if let brightness = subJson["brightness"].float {
                            filterOperations[1].updateBasedOnSliderValue((CGFloat(brightness) + 0.3) * 167.0)
                            groupFilters.append(filterOperations[1].filter)
                        }
                        if let temp = subJson["temperature"].float {
                            filterOperations[2].updateBasedOnSliderValue((CGFloat(temp) - 4000.0) / 1000.0 * 50.0)
                            groupFilters.append(filterOperations[2].filter)
                        }
                        if let saturation = subJson["saturation"].float {
                            filterOperations[3].updateBasedOnSliderValue(CGFloat(saturation) * 50.0)
                            groupFilters.append(filterOperations[3].filter)
                        }
                        if let sharp = subJson["sharp"].float {
                            filterOperations[4].updateBasedOnSliderValue((CGFloat(sharp) + 4.0) * 12.5)
                            groupFilters.append(filterOperations[4].filter)
                        }
                        if let tilt = subJson["tiltShift"].float {
                            filterOperations[5].updateBasedOnSliderValue(CGFloat(1 - tilt))
                            groupFilters.append(filterOperations[5].filter)
                        }
                        if let vign = subJson["vignette"].float {
                            filterOperations[6].updateBasedOnSliderValue((CGFloat(vign) - 1.5) * -98.95)
                            groupFilters.append(filterOperations[6].filter)
                        }
                        
                        /*LEVELS*/
                        var isAddedRBG = false
                        let (levelsR, rAdd) = levelsIdentity(subJson["levelsRBlack"].float, gamma: subJson["levelsRGamma"].float, white: subJson["levelsRWhite"].float, min: subJson["levelsRMin"].float, max: subJson["levelsRMax"].float)
                        if rAdd {
                            filterOperations[8].updateLelvelsSliderValue(1, min: levelsR[0], gamma: levelsR[1], max: levelsR[2], minOut: levelsR[3], maxOut: levelsR[4])
                            groupFilters.append(filterOperations[8].filter)
                            isAddedRBG = true
                        } else {
                            filterOperations[8].updateLelvelsSliderValue(1, min:0, gamma:0.5, max:1.0, minOut:0.0, maxOut:1.0)
                        }
                        let (levelsG, gAdd) = levelsIdentity(subJson["levelsGBlack"].float, gamma: subJson["levelsGGamma"].float, white: subJson["levelsGWhite"].float, min: subJson["levelsGMin"].float, max: subJson["levelsGMax"].float)
                        if gAdd {
                            filterOperations[8].updateLelvelsSliderValue(2, min: levelsG[0], gamma: levelsG[1], max: levelsG[2], minOut: levelsG[3], maxOut: levelsG[4])
                            if !isAddedRBG {
                                groupFilters.append(filterOperations[8].filter)
                                isAddedRBG = true
                            }
                        } else {
                            filterOperations[8].updateLelvelsSliderValue(2, min:0, gamma:0.5, max:1.0, minOut:0.0, maxOut:1.0)
                        }
                        let (levelsB, bAdd) = levelsIdentity(subJson["levelsBBlack"].float, gamma: subJson["levelsBGamma"].float, white: subJson["levelsBWhite"].float, min: subJson["levelsBMin"].float, max: subJson["levelsBMax"].float)
                        if bAdd {
                            filterOperations[8].updateLelvelsSliderValue(3, min: levelsB[0], gamma: levelsB[1], max: levelsB[2], minOut: levelsB[3], maxOut: levelsB[4])
                            if !isAddedRBG {
                                groupFilters.append(filterOperations[8].filter)
                                isAddedRBG = true
                            }
                        } else {
                            filterOperations[8].updateLelvelsSliderValue(3, min:0, gamma:0.5, max:1.0, minOut:0.0, maxOut:1.0)
                        }
                        
                        let (levelsRGB, rgbAdd) = levelsIdentity(subJson["levelsRGBBlack"].float, gamma: subJson["levelsRGBGamma"].float, white: subJson["levelsRGBWhite"].float, min: subJson["levelsRGBMin"].float, max: subJson["levelsRGBMax"].float)
                        if rgbAdd {
                            filterOperations[9].updateLelvelsSliderValue(0, min: levelsRGB[0], gamma: levelsRGB[1], max: levelsRGB[2], minOut: levelsRGB[3], maxOut: levelsRGB[4])
                            groupFilters.append(filterOperations[9].filter)
                        } else {
                            filterOperations[9].updateLelvelsSliderValue(0, min:0, gamma:0.5, max:1.0, minOut:0.0, maxOut:1.0)
                        }
                        if groupFilters.count < 1 {
                            groupFilters.append(filterOperations[7].filter)
                        }
                        orginalImage?.addTarget(groupFilters[0] as! GPUImageInput)
                        for i in 1 ..< groupFilters.count {
                            groupFilters[i - 1].addTarget(groupFilters[i] as! GPUImageInput)
                        }
                        groupFilters[groupFilters.count - 1].useNextFrameForImageCapture()
                        orginalImage?.processImage()
                        let image = groupFilters[groupFilters.count - 1].imageFromCurrentFramebuffer()
                        let dataForPNGFile = UIImagePNGRepresentation(image!)
                        orginalImage?.removeAllTargets()
                        for i in 0 ..< groupFilters.count {
                            groupFilters[i].removeAllTargets()
                        }
                        saveNewItem(filterName, imgData:dataForPNGFile!, filterArray: filter)
                    }
                }
            }
            updateFetch = false
        }  catch let error as NSError {
            readError = error
        }
        if readError != nil {print("\(readError)")}
    }
    func extractTagFromFilter(_ filter: GPUImageOutput) -> Int{
        var tag:Int!
        for tagfilter in filterOperations {
            if tagfilter.filter == filter {
                tag = tagfilter.tag
                return tag
            }
        }
        return tag
    }
    func levelsIdentity(_ black:Float?,gamma:Float?,white:Float?,min:Float?,max:Float?) -> ([CGFloat],Bool) {
        var temp = [CGFloat]()
        var adLevels = false
        if let bla = black {
            temp.append(CGFloat(bla))
            adLevels = true
        } else {
            temp.append(0.0)
        }
        if let gam = gamma {
            temp.append(CGFloat(gam))
            adLevels = true
        } else {
            temp.append(0.5)
        }
        if let whi = white {
            temp.append(CGFloat(whi))
            adLevels = true
        } else {
            temp.append(1.0)
        }
        if let m = min {
            temp.append(CGFloat(m))
            adLevels = true
        } else {
            temp.append(0.0)
        }
        if let i = max {
            temp.append(CGFloat(i))
            adLevels = true
        } else {
            temp.append(1.0)
        }
        return (temp, adLevels)
    }
    func checkIfEntityExist(_ name:String) -> Bool {
        for entity in filterItems {
            if name == entity.filterName {
                return true
            }
        }
        return false
    }
    func saveNewItem(_ filterName: String, imgData:Data, filterArray:Dictionary<String, Float>) {
        if let moc = self.managedObjectContext {
            _ = Custom_Filters.createInManagedObjectContext(moc, id:filterItems.count + 1, custom:false, filter: filterName, filterImage:imgData, filterValues:filterArray)
            saveNew()
        }
        
    }
    func saveNew() {
        if managedObjectContext!.hasChanges {
            do {
                try managedObjectContext!.save()
            } catch {
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }
    func fetchFilters() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Custom_Filters")
        // Create a sort descriptor object that sorts on the "title"
        // property of the Core Data object
        //let sortDescriptor = NSSortDescriptor(key: "date", ascending: true)
        // Set the list of sort descriptors in the fetch request,
        // so it includes the sort descriptor
        //fetchRequest.sortDescriptors = [sortDescriptor]
        if let fetchResults = (try? managedObjectContext!.fetch(fetchRequest)) as? [Custom_Filters] {
            filterItems = fetchResults
        }
    }
}
