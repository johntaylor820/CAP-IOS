//
//  EditsViewController.swift
//  CAPTURE
//
//  Created by The CAPTURE Team.
//  Copyright (c) 2016 Josh Hill. All rights reserved.
//

import UIKit
import GPUImage
import Photos
import CoreData
import MediaPlayer


class EditsViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UIAlertViewDelegate, UITextFieldDelegate, UpdateGroupFiltersDelegate, RevertViewDelegate {
    let screenWidth = UIScreen.main.bounds.width
    var screenHeight = UIScreen.main.bounds.height
    let reuseIdentifier = "filterCell"
    //Gpuimage
    var movieFile:GPUImageMovie!
    var movieView:GPUImageView!
    let editHandler = EditFilterGroup()
    var audioFile:URL?
    
    // Create an empty array of LogItem's
    var filterItems = [Custom_Filters]()
    
    // Retreive the managedObjectContext from AppDelegate
    let managedObjectContext:NSManagedObjectContext! = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
    
    let defualtFilters = 15
    
    
    @IBOutlet var sliderView: RangeSliderView!
    @IBOutlet var levelsView: LevelsView!
    @IBOutlet var rgbLevelsButtonView: UIView!
    @IBOutlet var revertView: RevertView!
    @IBOutlet weak var musicView: MusicView!
    @IBOutlet weak var volumeView: UIView!
    @IBOutlet weak var clipsView: UIView!
    @IBOutlet weak var navItem: UINavigationItem!

    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var playerView: UIView!
    var avPlayer: AVPlayer!
    @IBOutlet weak var playAndPauseButton: UIButton!
    var timeObserver: AnyObject!
    @IBOutlet weak var timeRemainingLabel: UILabel!
    @IBOutlet weak var totalTimeLabel: UILabel!
    var playerRateBeforeSeek: Float = 0
    @IBOutlet weak var seekSlider: UISlider!
    var isProccesing = false
    var lookUpRow: Int?
    
    
    //Filter
    var transform1:GPUImageTransformFilter!
    var cropFilter:GPUImageCropFilter!
    var groupEditsFilter = [GPUImageOutput]()
    @IBOutlet var filterCollectionView: UICollectionView!
    
    @IBOutlet weak var musicCollectionView: UICollectionView!
    @IBOutlet weak var videoVolumeSlider: UISlider!
    @IBOutlet weak var musicVolumeSlider: UISlider!
    /*var offSet:CGPoint!
    @IBOutlet weak var waveFormDragViewCenterConstraint: NSLayoutConstraint!
    @IBOutlet weak var waveFormDragViewWidhtConstraint: NSLayoutConstraint!
    @IBOutlet weak var waveFormDragView: UIView!*/
    var trackTime:Float = 0.0
    var musicTime:TimeInterval = 0.0
    let mediaPickerController = MPMediaPickerController(mediaTypes: .anyAudio)
    
    //Passed info
    var orientation:GPUImageRotationMode!
    var videoAsset:URL!
    //info to be passed
    

    var music = [Music]()
    let musicInfo = [["name": "My Music", "image":"mymusic"],["name": "Country", "image":"country", "song": "Country"],["name": "Electronic", "image":"electronic", "song": "Electronic"],["name": "Hip-Hop", "image":"hip-hop", "song": "Hip Hop"],["name": "Jazz", "image":"jazz", "song": "Jazz"],["name": "Pop", "image":"pop", "song": "Pop"],["name": "Reggae", "image":"reggae", "song": "Reggae"],["name": "Rock", "image":"rock", "song": "Rock"]]
    var musicPlayer: AVAudioPlayer?
    var musicURL:URL?
    
    //Bool
    var RnGnBIsActive = [String]()
    var selectStart = true
    var isFilter:Bool = false
    var isLevelsRGB = false
    var isLevelsOther = false
    
    var changesMade = [String:Float]()
    
    @IBOutlet weak var saveFilterButton: UIButton!
    var saveFilterButtonEnabled = false
    var scrollHeight:CGFloat = 114.0
    var filteredImages = [UIImage]()
    
    var sliderFilters = [Int]()
    var menuHidden:Bool = false
    var croppingFrame:CGRect!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        music = musicInfo.map({Music(dictionary: $0 as [String : AnyObject])})
        
        navigationController?.navigationBar.barTintColor = UIColor.black
        navigationController?.navigationBar.alpha = 0.9
        navItem.title = "Clips"
        navigationController?.navigationBar.titleTextAttributes = [
            NSFontAttributeName: UIFont(name: "HelveticaNeue-Light", size: 20)!,
            NSForegroundColorAttributeName: UIColor.white
        ]
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.barStyle = UIBarStyle.default
        navItem.leftBarButtonItem?.tintColor = UIColor.white
        navItem.rightBarButtonItem?.tintColor = UIColor.white

        self.navigationController!.interactivePopGestureRecognizer!.isEnabled = false
        fetchFilters()
        seekSlider.setThumbImage(UIImage(named: "thumb"), for: UIControlState())
        
        movieView = GPUImageView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenWidth))
        let playerItem = AVPlayerItem(url: videoAsset)
        avPlayer = AVPlayer(playerItem: playerItem)
        movieFile = GPUImageMovie(playerItem: playerItem)
        movieFile.playAtActualSpeed = true
        transform1 = GPUImageTransformFilter()
        transform1.setInputRotation(orientation, at: 0)
        cropFilter = GPUImageCropFilter(cropRegion: croppingFrame)
        movieFile.addTarget(transform1)
        transform1.addTarget(cropFilter)
        cropFilter.addTarget(movieView)
        videoView.addSubview(movieView)
        setupControllers()
        
        seekSlider.minimumValue = 0
        seekSlider.value = 0
        seekSlider.maximumValue = 1

        avPlayer.volume = 0.5
        videoVolumeSlider.value = 0.5
        rgbLevelsButtonView.layer.borderColor = UIColor(red: 102/255, green: 102/255, blue: 102/255, alpha: 1.0).cgColor
        rgbLevelsButtonView.layer.borderWidth = 1.0
        setLevelsTarget(levelsView.rgbLevelsControl, max: levelsView.rgbLevelsMax)
        setLevelsTarget(levelsView.redLevelsControl, max: levelsView.redLevelsMax)
        setLevelsTarget(levelsView.blueLevelsControl, max: levelsView.blueLevelsMax)
        setLevelsTarget(levelsView.greenLevelsControl, max: levelsView.greenLevelsMax)
        filterCollectionView.selectItem(at: IndexPath(row: 0, section: 0), animated: false, scrollPosition: UICollectionViewScrollPosition())
        let doubleTapToDelete = UITapGestureRecognizer(target: self, action: #selector(EditsViewController.showFilterCellDeleteMenu(_:)))
        doubleTapToDelete.numberOfTapsRequired = 2
        doubleTapToDelete.numberOfTouchesRequired = 1
        filterCollectionView.addGestureRecognizer(doubleTapToDelete)
        sliderView.updateDelegate = self
        revertView.revertDelegate = self
        revertView.setTableViewBG()
        NotificationCenter.default.addObserver(self, selector: #selector(EditsViewController.rangeTrackingDidEnd(_:)), name: NSNotification.Name(rawValue: "rangeTrackingHasEnded"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(EditsViewController.levelsTrackingDidEnd(_:)), name: NSNotification.Name(rawValue: "levelsTrackingHasEnded"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(EditsViewController.playerDidFinishPlaying(_:)),name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: avPlayer.currentItem)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func setupControllers() {
        playerView.makeBlur(playerView)
        let invisibleButton = UITapGestureRecognizer(target: self, action: #selector(invisibleButtonTapped(_:)))
        invisibleButton.numberOfTapsRequired = 1
        videoView.addGestureRecognizer(invisibleButton)
        
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !isProccesing {
            isProccesing = true
            let time = CMTimeGetSeconds(avPlayer.currentItem!.duration)
            trackTime = Float(time)
            seekSlider.maximumValue = Float(time)
            totalTimeLabel.text = String(format: "-%01d:%02d", ((lround(time) / 60) % 60), lround(time) % 60)
            let timeInterval: CMTime = CMTimeMakeWithSeconds(0.01, 1000)
            timeObserver = avPlayer.addPeriodicTimeObserver(forInterval: timeInterval,queue: DispatchQueue.main) {
                (elapsedTime: CMTime) -> Void in
                self.observeTime(elapsedTime)
            } as AnyObject!
            movieFile.startProcessing()
            avPlayer.play()
            let indexPath = filterCollectionView.indexPathForItem(at: CGPoint(x: 20, y: 20))
            filterCollectionView.selectItem(at: indexPath, animated: true, scrollPosition: UICollectionViewScrollPosition())
        } else {
            resumeVideo()
        }
    }
    
    func setLevelsTarget(_ control:LevelsControl, max: MaxAndMinControl) {
        control.addTarget(self, action: #selector(EditsViewController.setLevelsValues), for: .valueChanged)
        max.addTarget(self, action: #selector(EditsViewController.setLevelsValues), for: .valueChanged)
    }
    func invisibleButtonTapped(_ sender: UIGestureRecognizer) {
        changePLayPause()
    }
    @IBAction func playOrPause(_ sender: AnyObject) {
        changePLayPause()
    }
    func changePLayPause() {
        let playerIsPlaying = avPlayer.rate > 0
        if (playerIsPlaying) {
            avPlayer.pause();
            if let player = musicPlayer {
                player.pause()
            }
            playAndPauseButton.isSelected = false
        } else {
            avPlayer.play();
            if let player = musicPlayer {
                player.play()
            }
            playAndPauseButton.isSelected = true
        }
    }
    func playerDidFinishPlaying(_ note: Notification) {
        resetPlayers()
    }
    func resetPlayers() {
        avPlayer.seek(to: CMTimeMakeWithSeconds(0.0, 1000), completionHandler: { (completed: Bool) -> Void in
            if (self.avPlayer.rate == 0) {
                self.avPlayer.play()
            }
        }) 
        if let player = self.musicPlayer {
            player.currentTime = musicTime
            player.play()
        }
    }
    fileprivate func updateTimeLabel(_ time: Float64) {
        seekSlider.value = Float(time)
        timeRemainingLabel.text = String(format: "%01d:%02d", ((lround(time) / 60) % 60), lround(time) % 60)
    }
    fileprivate func observeTime(_ elapsedTime: CMTime) {
        let time = CMTimeGetSeconds(elapsedTime)
        updateTimeLabel(time)
    }
    
    @IBAction func sliderBeganTracking(_ sender: UISlider) {
        playerRateBeforeSeek = avPlayer.rate
        self.avPlayer.pause()
    }
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        let elapsedTime: Float64 = Float64(seekSlider.value)
        updateTimeLabel(elapsedTime)
        
        avPlayer.seek(to: CMTimeMakeWithSeconds(elapsedTime, 1000), completionHandler: { (completed: Bool) -> Void in}) 
    }
    
    @IBAction func sliderEndedTracking(_ sender: UISlider) {
        let elapsedTime: Float64 = Float64(seekSlider.value)
        updateTimeLabel(elapsedTime)
        
        avPlayer.seek(to: CMTimeMakeWithSeconds(elapsedTime, 1000), completionHandler: { (completed: Bool) -> Void in
            if (self.playerRateBeforeSeek > 0) {
                self.avPlayer.play()
            }
        }) 
    }

    func resumeVideo() {
        changePLayPause()
    }

    override func viewDidDisappear(_ animated: Bool) {
        avPlayer.pause()
        if let player = musicPlayer {
            player.pause()
        }
        super.viewDidDisappear(animated)
    }
    @IBOutlet var menuViews: UIView!
    @IBOutlet var menuButtonViews: UIView!
    // MARK: - Navigation
    @IBAction func saveChanges(_ sender: UIButton) {
        if let _: AnyClass = NSClassFromString("UIAlertController") {
            //make and use a UIAlertController
            if isFilter {
                performSegue(withIdentifier: "saveView", sender: nil)
            } else {
                    let actionSheetController: UIAlertController = UIAlertController(title: "Hey!", message: "Put some awesome filter on the video first", preferredStyle: .alert)
                    let cancelAction: UIAlertAction = UIAlertAction(title: "Ok", style: .cancel) { action -> Void in
                    }
                    actionSheetController.addAction(cancelAction)
                    self.present(actionSheetController, animated: true, completion: nil)
            }
        }
    }
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "captionView" {
            let vc: PublishViewController = segue.destination as! PublishViewController
            
            if let url = musicURL {
                vc.musicUrl = url
                vc.videoVolume = videoVolumeSlider.value
                vc.musicVolume = musicVolumeSlider.value
                vc.musicStartTime = musicTime
            }
            avPlayer.pause()
            if let player = musicPlayer {
                player.pause()
            }
            vc.filterArray = groupEditsFilter
            vc.movieURL = videoAsset
            vc.orientation = orientation
            vc.cropping = croppingFrame
            vc.lookUpRow = lookUpRow
            isProccesing = false
            movieFile.endProcessing()
            movieFile.removeAllTargets()
            transform1.removeAllTargets()
            if let lookUpRow = lookUpRow {
                filterOperations[lookUpRow].lookUpImage!.removeAllTargets()
            }

            for filter in groupEditsFilter {
                filter.removeAllTargets()
            }
        }
    }
    // MARK: - UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == filterCollectionView {
            return filterItems.count + defualtFilters
        } else {
            return music.count
        }
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == filterCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! FilterCollectionViewCell
            cell.layer.shouldRasterize = true
            cell.layer.rasterizationScale = UIScreen.main.scale
            if (indexPath as NSIndexPath).row == 0 {
                cell.label = filterOperations[7].titleName
                cell.image = filterOperations[7].image!
            } else if filterItems.count >= (indexPath as NSIndexPath).row {
                cell.label = filterItems[(indexPath as NSIndexPath).row - 1].filterName
                DispatchQueue.global(qos: .background).async {
                    let image = UIImage(data:self.filterItems[(indexPath as NSIndexPath).row - 1].image as Data)!
                    DispatchQueue.main.sync(execute: {
                        cell.image = image
                    })
                }
            } else {
                let lookUpRow = ((indexPath as NSIndexPath).row - filterItems.count) + 7
                
                cell.label = filterOperations[lookUpRow].titleName
                cell.image = filterOperations[lookUpRow].image!
            }
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "musicCell", for: indexPath) as! MusicCollectionViewCell
            cell.layer.shouldRasterize = true
            cell.layer.rasterizationScale = UIScreen.main.scale
            let mus = music[(indexPath as NSIndexPath).row]
            cell.name = mus.name
            cell.image = mus.image
            cell.song = mus.song
            return cell
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        /*if collectionView == filterCollectionView {
            return CGSizeMake(88, collectionView.frame.size.height)
        } else {
            return CGSizeMake(78, collectionView.frame.size.height)
        }*/
        return CGSize(width: 88, height: collectionView.frame.size.height)
    }
    // MARK: - UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        for paths in collectionView.indexPathsForSelectedItems! {
            collectionView.deselectItem(at: paths, animated: false)
        }
        if collectionView == filterCollectionView {
            resetAllSliders()
            revertView.listOfItems = [(type:"As Shot", value:(black:0, gamma:0, white:0, min:0, max:0), valueText:"", id:79335)]
            revertView.tableView.reloadData()
            isLevelsOther = false
            isLevelsRGB = false
            if (indexPath as NSIndexPath).row == 0 {
                groupEditsFilter = [filterOperations[7].filter]
                isFilter = false
                lookUpRow = nil
                levelsView.showActiveView("RGB")
                resetRGBLevelsButtons(RGBButtons[0])
            } else if filterItems.count >= (indexPath as NSIndexPath).row {
                isFilter = true
                lookUpRow = nil
                groupEditsFilter = editHandler.fetchStaticFilters(filterItems[indexPath.row - 1])
                updateSliders((indexPath as NSIndexPath).row - 1, levelsVals:[6:(black:6, gamma:6, white:6, min:6, max:6)])
            } else {
                lookUpRow = ((indexPath as NSIndexPath).row - filterItems.count) + 7
                isFilter = true
                editHandler.groupEditsFilter.removeAll()
                groupEditsFilter = editHandler.addFilter(filterOperations[lookUpRow!].filter)
                lookUpRow = nil
                levelsView.showActiveView("RGB")
                resetRGBLevelsButtons(RGBButtons[0])
            }
            updateFilterChain()
            saveFilterButtonEnabled = false
            saveFilterButton.isEnabled = false
            saveFilterButton.alpha = 0
            collectionView.selectItem(at: indexPath, animated: true, scrollPosition: UICollectionViewScrollPosition.centeredHorizontally)
        } else {
            if (indexPath as NSIndexPath).row == 0 {
                mediaPickerController.delegate = self
                present(mediaPickerController, animated: true, completion: nil)
            } else {
                let cell = collectionView.cellForItem(at: indexPath) as! MusicCollectionViewCell
                if let song = cell.song {
                    let url = URL(fileURLWithPath: Bundle.main.path(forResource: song, ofType: "wav")!)
                    playSong(url)
                }
                collectionView.selectItem(at: indexPath, animated: true, scrollPosition: UICollectionViewScrollPosition.centeredHorizontally)
            }
        }
        
    }
    
    func updateRevertView(_ array:[GPUImageOutput],value:[Int:(black:Float, gamma:Float, white:Float, min:Float, max:Float)]) {
        resetAllSliders()
        isLevelsOther = false
        isLevelsRGB = false
        groupEditsFilter = array
        if !array.isEmpty {
            isFilter = true
        }
        editHandler.groupEditsFilter = array
        updateFilterChain()
        updateSliders(0, isCustom:false, levelsVals:value)
        
    }
    func isUpdating() {
        if (self.avPlayer.rate == 0) {
            self.avPlayer.play()
        }
    }
    func updateSliders(_ num:Int, isCustom:Bool = true, levelsVals:[Int:(black:Float, gamma:Float, white:Float, min:Float, max:Float)]) {
        var tempArray = [Int]()
        for filter in groupEditsFilter {
            let tag = extractTagFromFilter(filter)
            tempArray.append(tag)
        }
        
        if tempArray.contains(0) {
            if isCustom {
                if let contVal = filterItems[num].contrast {
                    var tempVal: CGFloat = 0
                    if contVal > 0.99 {
                        tempVal = CGFloat(contVal) * 50.0
                    } else {
                        tempVal = (CGFloat(contVal) - 0.5) * 100.0
                    }
                    sliderView.contrast.value = Float(tempVal)
                    filterOperations[0].updateBasedOnSliderValue(tempVal)
                }
            } else {
                var tempVal: CGFloat = 0
                let filter = filterOperations[0].filter as! GPUImageContrastFilter
                if filter.contrast > 0.99 {
                    tempVal = filter.contrast * 50.0
                } else {
                    tempVal = (filter.contrast - 0.5) * 100.0
                }
                
                sliderView.contrast.value = Float(tempVal)
            }
            sliderView.contrast.thumbLayer.highlighted = true
        }
        if tempArray.contains(1) {
            if isCustom {
                let value = (Float(filterItems[num].brightness!) + 0.3) * 167.0
                sliderView.brightness.value = value
                filterOperations[1].updateBasedOnSliderValue(CGFloat(value))
            } else {
                let filter = filterOperations[1].filter as! GPUImageBrightnessFilter
                sliderView.brightness.value = (Float(filter.brightness) + 0.3) * 167.0
            }
            sliderView.brightness.thumbLayer.highlighted = true
        }
        if tempArray.contains(2) {
            if isCustom {
                let value = (Float(filterItems[num].temperature!) - 4000.0) / 1000.0 * 50.0
                sliderView.temp.value = value
                filterOperations[2].updateBasedOnSliderValue(CGFloat(value))
            } else {
                let filter = filterOperations[2].filter as! GPUImageWhiteBalanceFilter
                sliderView.temp.value = (Float(filter.temperature) - 4000.0) / 1000.0 * 50.0
            }
            sliderView.temp.thumbLayer.highlighted = true
        }
        if tempArray.contains(3) {
            if isCustom {
                let value = Float(filterItems[num].saturation!) * 50.0
                sliderView.saturation.value = value
                filterOperations[3].updateBasedOnSliderValue(CGFloat(value))
            } else {
                let filter = filterOperations[3].filter as! GPUImageSaturationFilter
                sliderView.saturation.value = Float(filter.saturation) * 50.0
            }
            sliderView.saturation.thumbLayer.highlighted = true
        }
        if tempArray.contains(4) {
            if isCustom {
                let value = (Float(filterItems[num].sharp!) + 4.0) * 12.5
                sliderView.sharp.value = value
                filterOperations[4].updateBasedOnSliderValue(CGFloat(value))
            } else {
                let filter = filterOperations[4].filter as! GPUImageSharpenFilter
                sliderView.sharp.value = (Float(filter.sharpness) + 4.0) * 12.5
            }
            sliderView.sharp.thumbLayer.highlighted = true
        }
        if tempArray.contains(5) {
            if isCustom {
                let value = 1 - Float(filterItems[num].tiltShift!)
                sliderView.tiltShift.value = value
                filterOperations[5].updateBasedOnSliderValue(CGFloat(value))
            } else {
                let filter = filterOperations[5].filter as! GPUImageGaussianSelectiveBlurFilter
                sliderView.tiltShift.value = 1 - Float(filter.excludeCircleRadius)
            }
            sliderView.tiltShift.thumbLayer.highlighted = true
        }
        if tempArray.contains(6) {
            if isCustom {
                let value = (Float(filterItems[num].vignette!) - 1.5) * -98.95
                sliderView.vignette.value = value
                filterOperations[6].updateBasedOnSliderValue(CGFloat(value))
            } else {
                let filter = filterOperations[6].filter as! GPUImageVignetteFilter
                sliderView.vignette.value = (Float(filter.vignetteEnd) - 1.5) * -98.95
            }
            sliderView.vignette.thumbLayer.highlighted = true
        }
        if tempArray.contains(32) {
            var activateBlue = false
            if isCustom {
                if let levelsBGamma = filterItems[num].levelsBGamma {
                    levelsView.blueLevelsControl.gamma = CGFloat(levelsBGamma)
                    activateBlue = true
                }
                if let levelsBBlack = filterItems[num].levelsBBlack {
                    levelsView.blueLevelsControl.black = CGFloat(levelsBBlack)
                    activateBlue = true
                }
                if let levelsBWhite = filterItems[num].levelsBWhite {
                    levelsView.blueLevelsControl.white = CGFloat(levelsBWhite)
                    activateBlue = true
                }
                if let levelsBMax = filterItems[num].levelsBMax {
                    levelsView.blueLevelsMax.maxOut = CGFloat(levelsBMax)
                    activateBlue = true
                }
                if let levelsBMin = filterItems[num].levelsBMin {
                    levelsView.blueLevelsMax.minOut = CGFloat(levelsBMin)
                    activateBlue = true
                }
            } else {
                if let vals = levelsVals[3] {
                    levelsView.blueLevelsControl.gamma = CGFloat(vals.gamma)
                    levelsView.blueLevelsControl.black = CGFloat(vals.black)
                    levelsView.blueLevelsControl.white = CGFloat(vals.white)
                    levelsView.blueLevelsMax.maxOut = CGFloat(vals.max)
                    levelsView.blueLevelsMax.minOut = CGFloat(vals.min)
                    activateBlue = true
                }
            }
            if activateBlue {
                if !isCustom {
                    isLevelsOther = true
                }
                levelsView.showActiveView("B")
                setLevelsValues()
                isLevelsOther = true
                resetRGBLevelsButtons(RGBButtons[3])
            }
            var activateGreen = false
            if isCustom {
                if let levelsGGamma = filterItems[num].levelsGGamma {
                    levelsView.greenLevelsControl.gamma = CGFloat(levelsGGamma)
                    activateGreen = true
                }
                if let levelsGBlack = filterItems[num].levelsGBlack {
                    levelsView.greenLevelsControl.black = CGFloat(levelsGBlack)
                    activateGreen = true
                }
                if let levelsGWhite = filterItems[num].levelsGWhite {
                    levelsView.greenLevelsControl.white = CGFloat(levelsGWhite)
                    activateGreen = true
                }
                if let levelsGMax = filterItems[num].levelsGMax {
                    levelsView.greenLevelsMax.maxOut = CGFloat(levelsGMax)
                    activateGreen = true
                }
                if let levelsGMin = filterItems[num].levelsGMin {
                    levelsView.greenLevelsMax.minOut = CGFloat(levelsGMin)
                    activateGreen = true
                }
            } else {
                if let vals = levelsVals[2] {
                    levelsView.greenLevelsControl.gamma = CGFloat(vals.gamma)
                    levelsView.greenLevelsControl.black = CGFloat(vals.black)
                    levelsView.greenLevelsControl.white = CGFloat(vals.white)
                    levelsView.greenLevelsMax.maxOut = CGFloat(vals.max)
                    levelsView.greenLevelsMax.minOut = CGFloat(vals.min)
                    activateGreen = true
                }
            }
            if activateGreen {
                if !isCustom {
                    isLevelsOther = true
                }
                levelsView.showActiveView("G")
                setLevelsValues()
                isLevelsOther = true
                resetRGBLevelsButtons(RGBButtons[2])
            }
            var activateRed = false
            if isCustom {
                if let levelsRGamma = filterItems[num].levelsRGamma {
                    levelsView.redLevelsControl.gamma = CGFloat(levelsRGamma)
                    activateRed = true
                }
                if let levelsRBlack = filterItems[num].levelsRBlack {
                    levelsView.redLevelsControl.black = CGFloat(levelsRBlack)
                    activateRed = true
                }
                if let levelsRWhite = filterItems[num].levelsRWhite {
                    levelsView.redLevelsControl.white = CGFloat(levelsRWhite)
                    activateRed = true
                }
                if let levelsRMax = filterItems[num].levelsRMax {
                    levelsView.redLevelsMax.maxOut = CGFloat(levelsRMax)
                    activateRed = true
                }
                if let levelsRMin = filterItems[num].levelsRMin {
                    levelsView.redLevelsMax.minOut = CGFloat(levelsRMin)
                    activateRed = true
                }
            } else {
                if let vals = levelsVals[1] {
                    levelsView.redLevelsControl.gamma = CGFloat(vals.gamma)
                    levelsView.redLevelsControl.black = CGFloat(vals.black)
                    levelsView.redLevelsControl.white = CGFloat(vals.white)
                    levelsView.redLevelsMax.maxOut = CGFloat(vals.max)
                    levelsView.redLevelsMax.minOut = CGFloat(vals.min)
                    activateRed = true
                }
            }
            if activateRed {
                if !isCustom {
                    isLevelsOther = true
                }
                levelsView.showActiveView("R")
                setLevelsValues()
                isLevelsOther = true
                resetRGBLevelsButtons(RGBButtons[1])
            }
        }
        if tempArray.contains(33) {
            var activateRGB = false
            if isCustom {
                if let levelsRGBGamma = filterItems[num].levelsRGBGamma {
                    levelsView.rgbLevelsControl.gamma = CGFloat(levelsRGBGamma)
                    activateRGB = true
                }
                if let levelsRGBBlack = filterItems[num].levelsRGBBlack {
                    levelsView.rgbLevelsControl.black = CGFloat(levelsRGBBlack)
                    activateRGB = true
                }
                if let levelsRGBWhite = filterItems[num].levelsRGBWhite {
                    levelsView.rgbLevelsControl.white = CGFloat(levelsRGBWhite)
                    activateRGB = true
                }
                if let levelsRGBMax = filterItems[num].levelsRGBMax {
                    levelsView.rgbLevelsMax.maxOut = CGFloat(levelsRGBMax)
                    activateRGB = true
                }
                if let levelsRGBMin = filterItems[num].levelsRGBMin {
                    levelsView.rgbLevelsMax.minOut = CGFloat(levelsRGBMin)
                    activateRGB = true
                }
            }else {
                if let vals = levelsVals[0] {
                    levelsView.rgbLevelsControl.gamma = CGFloat(vals.gamma)
                    levelsView.rgbLevelsControl.black = CGFloat(vals.black)
                    levelsView.rgbLevelsControl.white = CGFloat(vals.white)
                    levelsView.rgbLevelsMax.maxOut = CGFloat(vals.max)
                    levelsView.rgbLevelsMax.minOut = CGFloat(vals.min)
                    activateRGB = true
                }
            }
            if activateRGB {
                if !isCustom {
                    isLevelsRGB = true
                }
                levelsView.showActiveView("RGB")
                setLevelsValues()
                isLevelsRGB = true
                resetRGBLevelsButtons(RGBButtons[0])
            }
        }
    }
    
    dynamic func rangeTrackingDidEnd(_ notification: Notification) {
        let slider = notification.object as! RangeSlider
        if slider.value != 0.5 {
            saveFilterButtonEnabled = true
        }
        revertView.addEditToList(slider.filterOperation!.titleName, value: (black:slider.value, gamma:0, white:0, min:0, max:0), valueText: slider.increased, id:slider.id!)
    }
    func addFilterToGroup(_ filter:FilterOperationInterface) {
        if sliderFilters.contains(filter.tag) == false {
            filterOperation = filter
            sliderFilters.append(filter.tag)
        }
        for paths in filterCollectionView.indexPathsForSelectedItems! {
            filterCollectionView.deselectItem(at: paths, animated: false)
        }
        //saveFilterButtonEnabled = true
    }
    func removeFilterFromGroup(_ filter:FilterOperationInterface) {
        sliderFilters.remove(at: sliderFilters.index(of: filter.tag)!)
        groupEditsFilter = editHandler.removeFilter(filter.filter)
        updateFilterChain()
    }
    func updateFilterChain() {
        movieFile.removeAllTargets()
        transform1.removeAllTargets()
        cropFilter.removeAllTargets()
        movieFile.addTarget(transform1)
        transform1.addTarget(cropFilter)
        transform1.setInputRotation(orientation, at: 0)
        transform1.addTarget(cropFilter)
        for filter in groupEditsFilter {
            filter.removeAllTargets()
        }
        var picture: GPUImagePicture?
        if let lookUpRow = lookUpRow {
            groupEditsFilter.insert(filterOperations[lookUpRow].filter, at: 0)
            picture = filterOperations[lookUpRow].lookUpImage
        }
        
        if groupEditsFilter.isEmpty {
            cropFilter.addTarget(movieView)
            isFilter = false
        } else {
            cropFilter.addTarget(groupEditsFilter[0] as! GPUImageInput)
            if let picture = picture {
                picture.addTarget(groupEditsFilter[0] as! GPUImageInput)
                picture.processImage()
            }
            for i in 1 ..< groupEditsFilter.count {
                groupEditsFilter[i - 1].addTarget(groupEditsFilter[i] as! GPUImageInput)
            }
            groupEditsFilter[groupEditsFilter.count - 1].addTarget(movieView)
            if (self.avPlayer.rate == 0) {
                self.avPlayer.play()
            }
        }
        sliderFilters.removeAll(keepingCapacity: false)
        var tempArray = [Int]()
        for filter in groupEditsFilter {
            let tag = extractTagFromFilter(filter)
            tempArray.append(tag)
        }
        sliderFilters = tempArray
        if sliderFilters.isEmpty {
            saveFilterButtonEnabled = false
        }
    }
    
    func addFilterToChain(_ currentConf:FilterOperationInterface) {
        groupEditsFilter = editHandler.addFilter(currentConf.filter)
        updateFilterChain()
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
    func resetAllSliders() {
        sliderFilters.removeAll(keepingCapacity: false)
        for filter in groupEditsFilter {
            filter.removeAllTargets()
        }
        groupEditsFilter.removeAll(keepingCapacity: false)
        sliderView.reset()
        editHandler.groupEditsFilter.removeAll(keepingCapacity: false)
        isLevelsOther = true
        isLevelsRGB = true
        isFilter = false
        isLevelsRGB = false
        isLevelsOther = false
        sliderView.reset()
        levelsView.resetAllViews()
        saveFilterButtonEnabled = false
    }
    var filterOperation: FilterOperationInterface? {
        didSet {
            self.configureView()
        }
    }
    func configureView() {
        isFilter = true
        if let currentFilterConfiguration = self.filterOperation {
            if currentFilterConfiguration.tag == 7 {
                isFilter = false
                isLevelsRGB = false
                isLevelsOther = false
            }
            if !groupEditsFilter.contains(currentFilterConfiguration.filter) {
                addFilterToChain(currentFilterConfiguration)
            }
        }
    }
    
    // MARK: - Toolbar actions
    
    //Outlets
    @IBOutlet var toolbarButton: [UIButton]!
    
    //Clips
    @IBAction func showClips(_ sender: UIButton) {
        resetButtons(sender, settings:2)
        navItem.title = "Clips"
//        navigationItem.title = "Clips"

    }
    
    //Actions
    @IBAction func showFilter(_ sender: UIButton) {
        resetButtons(sender, settings: 1)
        navItem.title = "Filters"

    }
    @IBAction func showMusic(_ sender: UIButton) {
        resetButtons(sender, settings: 6)
        navItem.title = "Music"

    }
    @IBAction func showSliders(_ sender: UIButton) {
        resetButtons(sender, settings: 3)
        navItem.title = "Lab"

    }
    @IBAction func showCurves(_ sender: UIButton) {
        resetButtons(sender, settings: 4)
        navItem.title = "Volume"

    }
    @IBAction func showRevert(_ sender: UIButton) {
        resetButtons(sender, settings: 5)
    }
    //Helpers
    func resetButtons(_ sender: UIButton, settings:Int) {
        if !sender.isSelected {
            resetToolBarButtons()
            sender.isSelected = true
//            sender.backgroundColor = UIColor.white
            resetControlls(settings)
        }
    }
    func resetToolBarButtons() {
        for button in toolbarButton {
            button.isSelected = false
            button.backgroundColor = UIColor.clear
        }
    }
    func resetControlls(_ setting: Int) {
        filterCollectionView.alpha = 0
        filterCollectionView.isUserInteractionEnabled = false
        sliderView.alpha = 0
        sliderView.isUserInteractionEnabled = false
        revertView.alpha = 0
        revertView.isUserInteractionEnabled = false
        saveFilterButton.alpha = 0
        saveFilterButton.isEnabled = false
        //levelsView.userInteractionEnabled = false
        //levelsView.alpha = 0
        volumeView.isHidden = true
        musicView.isHidden = true
        clipsView.isHidden = true
        switch setting {
        case 1:
            //Show filter
            filterCollectionView.alpha = 1
            filterCollectionView.isUserInteractionEnabled = true
            if saveFilterButtonEnabled {
                saveFilterButton.alpha = 1
                saveFilterButton.isEnabled = true
            }
        case 2:
            //Show clips
            clipsView.isHidden = false
        case 3:
            //Show Sliders
            sliderView.alpha = 1
            sliderView.isUserInteractionEnabled = true
        case 4:
            //Show Levels
            volumeView.isHidden = false
            //levelsView.alpha = 1
            //levelsView.userInteractionEnabled = true
        case 5:
            //Show Revert
            revertView.alpha = 1
            revertView.isUserInteractionEnabled = true
        case 6:
            //Show Music
            musicView.isHidden = false
        default:
            break
        }
    }
    /*
     LEVELS!
     */
    func addLevelsFilter(_ i:Int) {
        filterOperation = filterOperations[i]
    }
    @IBOutlet var RGBButtons: [UIButton]!
    @IBAction func RGBButtonPressed(_ sender: UIButton) {
        resetRGBLevelsButtons(sender)
        levelsView.showActiveView("RGB")
    }
    @IBAction func RedButtonPressed(_ sender: UIButton) {
        resetRGBLevelsButtons(sender)
        levelsView.showActiveView("R")
    }
    @IBAction func GreenButtonPressed(_ sender: UIButton) {
        resetRGBLevelsButtons(sender)
        levelsView.showActiveView("G")
    }
    @IBAction func BlueButtonPressed(_ sender: UIButton) {
        resetRGBLevelsButtons(sender)
        levelsView.showActiveView("B")
    }
    @IBAction func resetLevelsSlider(_ sender: UIButton) {
        for paths in filterCollectionView.indexPathsForSelectedItems! {
            filterCollectionView.deselectItem(at: paths, animated: false)
        }
        levelsView.resetActiveView()
        let activeView = levelsView.activeView
        var typeName = ""
        var id:Int = 27
        switch activeView {
        case "RGB":
            isLevelsRGB = false
            typeName = "Levels RGB"
            id = 27
        case "R","G", "B":
            let index = RnGnBIsActive.index(of: activeView)
            if index != nil {
                RnGnBIsActive.remove(at: index!)
            }
            if activeView == "R" {
                typeName = "Levels Red"
                id = 28
            } else if activeView == "G" {
                typeName = "Levels Green"
                id = 29
            } else {
                typeName = "Levels Blue"
                id = 30
            }
        default:
            break
        }
        if RnGnBIsActive.isEmpty || activeView == "RGB" {
            _ = editHandler.removeFilter(levelsView.activefilterOperation.filter)
            if RnGnBIsActive.isEmpty {
                isLevelsOther = false
            }
        }
        revertView.addEditToList(typeName, value: (black:Float(levelsView.activeLevels.black), gamma:Float(levelsView.activeLevels.gamma), white:Float(levelsView.activeLevels.white), min:Float(levelsView.activeMaxAndMin.minOut), max:Float(levelsView.activeMaxAndMin.maxOut)), valueText: "Reset", id:id)
    }
    func resetRGBLevelsButtons(_ sender:UIButton) {
        for button in RGBButtons {
            button.alpha = 0.5
            button.setTitleColor( UIColor(red: 102/255.0, green: 102/255.0, blue: 102/255.0, alpha: 1.0), for: UIControlState())
            button.backgroundColor = UIColor.clear
        }
        sender.alpha = 1.0
        sender.setTitleColor( UIColor.white, for: UIControlState())
        sender.backgroundColor = UIColor(red: 102/255.0, green: 102/255.0, blue: 102/255.0, alpha: 1.0)
    }
    func setLevelsValues() {
        if levelsView.activeView == "RGB" {
            if !isLevelsRGB {
                addFilterToGroup(filterOperations[filterOperations.count - 1])
                isLevelsRGB = true
            }
        } else {
            if !isLevelsOther {
                addFilterToGroup(filterOperations[filterOperations.count - 2])
                isLevelsOther = true
            }
            RnGnBIsActive.append(levelsView.activeView)
        }
        levelsView.activefilterOperation.updateLelvelsSliderValue(levelsView.activeLevels.color, min: levelsView.activeLevels.black, gamma: levelsView.activeLevels.gamma, max: levelsView.activeLevels.white, minOut: levelsView.activeMaxAndMin.minOut, maxOut: levelsView.activeMaxAndMin.maxOut)
        //saveFilterButtonEnabled = true
        if (self.avPlayer.rate == 0) {
            self.avPlayer.play()
        }
    }
    dynamic func levelsTrackingDidEnd(_ notification: Notification) {
        var typeName = ""
        var id:Int = 27
        switch levelsView.activeView {
        case "RGB":
            typeName = "Levels RGB"
            id = 27
        case "R":
            typeName = "Levels Red"
            id = 28
        case "G":
            typeName = "Levels Green"
            id = 29
        case "B":
            typeName = "Levels Blue"
            id = 30
        default:
            break
        }
        revertView.addEditToList(typeName, value: (black:Float(levelsView.activeLevels.black), gamma:Float(levelsView.activeLevels.gamma), white:Float(levelsView.activeLevels.white), min:Float(levelsView.activeMaxAndMin.minOut), max:Float(levelsView.activeMaxAndMin.maxOut)), valueText: "Changed", id:id)
    }
    
    @IBOutlet weak var customBackgroundView: UIView!
    @IBOutlet weak var customImageView: UIImageView!
    @IBOutlet weak var customTextField: UITextField!
    var inputAccView:UIView?
    var saveButton:UIButton!
    var dissmissButton:UIButton!
    
    var deleteView:UIView?
    var deleteCellIndexPath:IndexPath?
    
    @IBOutlet weak var customImageTopContraint: NSLayoutConstraint!
    @IBOutlet weak var customImageXConstraint: NSLayoutConstraint!
    
    
    func showFilterCellDeleteMenu(_ sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            let point = sender.location(in: filterCollectionView)
            let indexPath = filterCollectionView.indexPathForItem(at: point)
            if let path = indexPath {
                if (path as NSIndexPath).row != 0 {
                    let filter = filterItems[(path as NSIndexPath).row-1]
                    if filter.isCustom {
                        showDeleteMenu(path)
                        deleteCellIndexPath = path
                    }
                }
            }
        }
    }
    func showDeleteMenu(_ indexPath:IndexPath) {
        if deleteView == nil {
            deleteView = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight))
        }
        if let delView = deleteView {
            let cell = filterCollectionView.layoutAttributesForItem(at: indexPath)
            let calcY = (screenHeight - cell!.frame.height) - cell!.frame.height / 2
            let subview = UIView(frame: CGRect(x: 40, y: calcY + 100, width: screenWidth - 80, height: 110))
            subview.backgroundColor = UIColor(red: 31/255, green: 31/255, blue: 31/255, alpha: 1)
            subview.layer.cornerRadius = 5
            delView.addSubview(subview)
            
            delView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.4)
            let tapExit = UITapGestureRecognizer(target: self, action: #selector(EditsViewController.dissmissDeleteMenu))
            tapExit.numberOfTapsRequired = 1
            delView.addGestureRecognizer(tapExit)
            //Buttons
            let deleteFilterButton = UIButton(frame: CGRect(x: 4, y: 4, width: subview.frame.size.width - 8, height: subview.frame.size.height/2 - 6))
            deleteFilterButton.layer.cornerRadius = 5
            deleteFilterButton.backgroundColor = UIColor(red: 242/255, green: 85/255, blue: 85/255, alpha: 1)
            deleteFilterButton.setTitle("DELETE FILTER", for: UIControlState())
            deleteFilterButton.addTarget(self, action: #selector(EditsViewController.deleteCustomFilter(_:)), for: .touchUpInside)
            
            
            let dissmissDeleteViewButton = UIButton(frame: CGRect(x: 4, y: subview.frame.size.height / 2 + 2, width: subview.frame.size.width - 8, height: subview.frame.size.height/2 - 6))
            dissmissDeleteViewButton.layer.cornerRadius = 5
            dissmissDeleteViewButton.backgroundColor = UIColor(red: 70/255, green: 70/255, blue: 70/255, alpha: 1)
            dissmissDeleteViewButton.setTitle("DISSMISS", for: UIControlState())
            dissmissDeleteViewButton.addTarget(self, action: #selector(EditsViewController.dissmissDeleteMenu), for: .touchUpInside)
            
            
            subview.addSubview(deleteFilterButton)
            subview.addSubview(dissmissDeleteViewButton)
            
            view.addSubview(delView)
        }
    }
    func dissmissDeleteMenu() {
        deleteView?.removeFromSuperview()
    }
    func deleteCustomFilter(_ sender: UIButton) {
        if let moc = self.managedObjectContext {
            dissmissDeleteMenu()
            let selectedItemPath = filterCollectionView.indexPathsForSelectedItems! as [IndexPath]
            moc.delete(filterItems[(deleteCellIndexPath! as NSIndexPath).row - 1])
            filterItems.remove(at: (deleteCellIndexPath! as NSIndexPath).row - 1)
            do {
                try moc.save()
            } catch _ {
            }
            filterCollectionView.deleteItems(at: [deleteCellIndexPath!])
            if selectedItemPath.index(of: deleteCellIndexPath!) != nil {
                filterCollectionView.selectItem(at: IndexPath(item: 0, section: 0), animated: false, scrollPosition: UICollectionViewScrollPosition())
                resetAllSliders()
                isLevelsOther = false
                isLevelsRGB = false
                groupEditsFilter = [filterOperations[7].filter]
                updateFilterChain()
            }
        }
    }
    func createAccesoriView() {
        inputAccView = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 40))
        inputAccView!.backgroundColor = UIColor.clear
        let buttonWidth = screenWidth / 2 - 7.5
        saveButton = UIButton(frame: CGRect(x: screenWidth - buttonWidth - 2.5, y: -2.5, width: buttonWidth, height: 40))
        saveButton.setTitleColor(UIColor.white, for: UIControlState())
        saveButton.setTitleColor(UIColor.gray, for: .highlighted)
        saveButton.setTitle("Save", for: UIControlState())
        saveButton.titleLabel?.font = UIFont(name: "HelveticaNeue", size: 16)
        saveButton.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.9)
        saveButton.layer.cornerRadius = 5.0
        saveButton.alpha = 0.3
        saveButton.isEnabled = false
        saveButton.addTarget(self, action: #selector(EditsViewController.createAndSaveFilter(_:)), for: .touchUpInside)
        
        dissmissButton = UIButton(frame: CGRect(x: 2.5, y: -2.5, width: buttonWidth, height: 40))
        dissmissButton.setTitleColor(UIColor.white, for: UIControlState())
        dissmissButton.setTitleColor(UIColor.gray, for: .highlighted)
        dissmissButton.setTitle("Dissmiss", for: UIControlState())
        dissmissButton.titleLabel?.font = UIFont(name: "HelveticaNeue", size: 16)
        dissmissButton.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.9)
        dissmissButton.layer.cornerRadius = 5.0
        dissmissButton.addTarget(self, action: #selector(EditsViewController.dissmissSaveFilter(_:)), for: .touchUpInside)
        
        inputAccView!.addSubview(saveButton)
        inputAccView!.addSubview(dissmissButton)
    }
    
    @IBAction func saveFilter(_ sender: UIButton) {
        let image = makeImage()
        customImageView.image = image
        customBackgroundView.alpha = 1
        saveFilterButtonEnabled = false
        saveFilterButton.isEnabled = false
        saveFilterButton.alpha = 0
        customBackgroundView.isUserInteractionEnabled = true
        customTextField.tintColor = UIColor.white
        customTextField.text = ""
        if inputAccView == nil {
            createAccesoriView()
        }
        customTextField.inputAccessoryView = inputAccView!
        customImageTopContraint.constant = screenHeight
        view.layoutIfNeeded()
        customTextField.becomeFirstResponder()
        UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 0.6, initialSpringVelocity: 3.0, options: UIViewAnimationOptions(), animations: {
            self.customImageTopContraint.constant = self.screenHeight / 5
            self.view.layoutIfNeeded()
            },
                                   completion: nil)
    }
    @IBAction func textFieldtextChanged(_ sender: UITextField) {
        if sender.text != "" {
            if saveButton.isEnabled == false {
                saveButton.alpha = 1.0
                saveButton.isEnabled = true
            }
        } else {
            if saveButton.isEnabled == true {
                saveButton.alpha = 0.3
                saveButton.isEnabled = false
            }
        }
    }
    func dissmissSaveFilter(_ sender: UIButton) {
        customBackgroundView.isUserInteractionEnabled = false
        customTextField.resignFirstResponder()
        saveFilterButtonEnabled = true
        saveFilterButton.isEnabled = true
        saveFilterButton.alpha = 1
        UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 0.6, initialSpringVelocity: 3.0, options: UIViewAnimationOptions(), animations: {
            self.customImageTopContraint.constant = self.screenHeight
            self.view.layoutIfNeeded()
            },
                                   completion: {
                                    value in
                                    self.customBackgroundView.alpha = 0
        })
    }
    func createAndSaveFilter(_ sender: UIButton) {
        let dataForPNGFile = UIImagePNGRepresentation(customImageView.image!)
        let filterDic = retriveValuesForFilter()
        
        //todo!
        
        //filterCollectionView.reloadData()
        customBackgroundView.isUserInteractionEnabled = false
        filterCollectionView.contentOffset.x = 0
        customTextField.resignFirstResponder()
        
        self.customBackgroundView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
        let cell = filterCollectionView.layoutAttributesForItem(at: IndexPath(row: 1, section: 0))
        let xCalc = (screenWidth - customImageView.frame.width) / 2 - cell!.frame.origin.x
        let calc = cell!.frame.height / 2 + 45
        self.saveNewItem(self.customTextField.text!, imgData: dataForPNGFile!, filterArray: filterDic)
        let newCell = filterCollectionView.cellForItem(at: IndexPath(row: 1, section: 0))
        newCell!.alpha = 0
        view.layoutIfNeeded()
        UIView.animate(withDuration: 0.4, delay: 0.5, usingSpringWithDamping: 0.6, initialSpringVelocity: 3.0, options: UIViewAnimationOptions(), animations: {
            self.customImageTopContraint.constant = self.screenHeight - calc
            self.customImageXConstraint.constant = xCalc
            self.view.layoutIfNeeded()
            },
               completion: {
                value in
                self.customBackgroundView.alpha = 1
                //self.filterCollectionView.reloadData()
                self.customBackgroundView.alpha = 0
                self.customBackgroundView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.7)
                self.customImageXConstraint.constant = 0
                self.view.layoutIfNeeded()
                newCell!.alpha = 1
                self.filterCollectionView.selectItem(at: IndexPath(row: 1, section: 0), animated: false, scrollPosition: UICollectionViewScrollPosition())
        })
    }
    
    
    func checkIfEntityExist(_ name:String) -> Bool {
        for entity in filterItems {
            if name == entity.filterName {
                return true
            }
        }
        return false
    }
    
    
    func makeImage() -> UIImage {
        movieFile.removeAllTargets()
        transform1.removeAllTargets()
        cropFilter.removeAllTargets()
        for filter in groupEditsFilter {
            filter.removeAllTargets()
        }
        let orginalImage = GPUImagePicture(image: UIImage(named: "filterimage.png"))
        var filters = groupEditsFilter
        orginalImage?.addTarget(filters[0] as! GPUImageInput)
        for i in 1 ..< filters.count {
            filters[i - 1].addTarget(filters[i] as! GPUImageInput)
        }
        filters[filters.count - 1].useNextFrameForImageCapture()
        orginalImage?.processImage()
        let image = filters[filters.count - 1].imageFromCurrentFramebuffer()
        
        transform1.setInputRotation(orientation, at: 0)
        movieFile.addTarget(transform1)
        transform1.addTarget(cropFilter)
        
        cropFilter.addTarget(groupEditsFilter[0] as! GPUImageInput)
        for i in 1 ..< groupEditsFilter.count {
            groupEditsFilter[i - 1].addTarget(groupEditsFilter[i] as! GPUImageInput)
        }
        groupEditsFilter[groupEditsFilter.count - 1].addTarget(movieView)
        return image!
    }
    func saveNewItem(_ filterName: String, imgData:Data, filterArray:Dictionary<String, Float>) {
        if let moc = self.managedObjectContext {
            _ = Custom_Filters.createInManagedObjectContext(moc, id:filterItems.count + 1, custom:true, filter: filterName, filterImage:imgData, filterValues:filterArray)
            fetchFilters()
            let newFilterIndexPath = IndexPath(row: 1, section: 0)
            UIView.animate(withDuration: 0.5, animations: {
                self.filterCollectionView.insertItems(at: [newFilterIndexPath])
            })
            saveNew()
        }
    }
    func saveNew() {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
        /* let error : NSError?
         if(managedObjectContext!.save() ) {
         print(error?.localizedDescription)
         }*/
    }
    func fetchFilters() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Custom_Filters")
        // Create a sort descriptor object that sorts on the "title"
        // property of the Core Data object
        let sortDescriptor = NSSortDescriptor(key: "id", ascending: false)
        // Set the list of sort descriptors in the fetch request,
        // so it includes the sort descriptor
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchRequest.returnsObjectsAsFaults = false
        if let fetchResults = (try? managedObjectContext!.fetch(fetchRequest)) as? [Custom_Filters] {
            filterItems = fetchResults
        }
    }
    func retriveValuesForFilter() ->  Dictionary<String, Float> {
        let filterDictionary = editHandler.retriveValuesForFilter(levelsView)
        return filterDictionary
    }
    @IBAction func backButtonPressed(_ sender: AnyObject) {
        _ = navigationController?.popViewController(animated: true)
        navigationController?.navigationBar.barTintColor = UIColor.white
        navigationController?.navigationBar.alpha = 1

    }
}

extension EditsViewController {
    func playSong(_ url: URL) {
        do {
            musicURL = url
            self.musicPlayer =  try AVAudioPlayer(contentsOf: musicURL!)
            if let player = self.musicPlayer {
                player.volume = musicVolumeSlider.value
                //let time = Float(player.duration)
                //calcWidth(time)
                player.play()
            }
        } catch {
            print("Error")
        }
    }
    /*@IBAction func effectButtonPressed(sender: MusicButton) {
        hideAllMusicViews()
        effectView.hidden = false
        effectButton.selected = true

    }
    
    @IBAction func musicButtonPressed(sender: MusicButton) {
        hideAllMusicViews()
        musicCollectionView.hidden = false
        musicButton.selected = true

    }
    
    @IBAction func volumeButtonPressed(sender: MusicButton) {
        hideAllMusicViews()
        volumeView.hidden = false
        volumeButton.selected = true

    }
 
    func hideAllMusicViews() {
        musicCollectionView.hidden = true
        effectView.hidden = true
        volumeView.hidden = true
        effectButton.selected = false
        musicButton.selected = false
        volumeButton.selected = false
    }*/
    @IBAction func videoVolumeChanged(_ sender: UISlider) {
        avPlayer.volume = sender.value
    }
    @IBAction func musicVolumeChanged(_ sender: UISlider) {
        if let player = self.musicPlayer {
            player.volume = sender.value
        }
    }
    
    /*@IBAction func waveFormViewDidDrag(gestureRecognizer: UIPanGestureRecognizer) {
        view.layoutIfNeeded()
        let translation = gestureRecognizer.translationInView(self.waveFormView)
        switch (gestureRecognizer.state) {
        case .Began:
            offSet = CGPoint(x: waveFormDragViewCenterConstraint.constant, y: 0)
        case .Changed:
            let change = offSet.x + translation.x
            let halfDrag = waveFormDragView.frame.size.width/2
            let calc = (view.frame.size.width/2 + change) - halfDrag
            let vaweFrame = waveFormView.frame
            if calc > vaweFrame.origin.x && calc < vaweFrame.size.width + vaweFrame.origin.x {
                waveFormDragViewCenterConstraint.constant = change
            }
            view.layoutIfNeeded()
        case .Ended:
            musicTime = Double(waveFormDragView.frame.origin.x - waveFormView.frame.origin.x)
            resetPlayers()
            break
        default:
            break
        }
    }
    
    func calcWidth(duration: Float) {
        let aspectToSong = trackTime / duration
        waveFormDragView.hidden = false
        waveFormDragViewWidhtConstraint.constant = CGFloat(aspectToSong) * waveFormView.frame.size.width
        waveFormDragViewCenterConstraint.constant = -waveFormView.frame.size.width/2 + waveFormDragViewWidhtConstraint.constant/2
        view.layoutIfNeeded()
        musicTime = Double(waveFormDragView.frame.origin.x - waveFormView.frame.origin.x)
        resetPlayers()
    }*/
}
extension EditsViewController: MPMediaPickerControllerDelegate {
    func mediaPicker(_ mediaPicker: MPMediaPickerController, didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
        let selectedSongs = mediaItemCollection.items
        if selectedSongs.count > 0 {
            let song = selectedSongs[0]
            if let url = song.value(forProperty: MPMediaItemPropertyAssetURL) as? URL {
                playSong(url)
                mediaPicker.dismiss(animated: true, completion: nil)
            } else {
                mediaPicker.dismiss(animated: true, completion: nil)
                let alert = UIAlertController(title: "Audio Not Available", message: "Make sure to download it from iTunes correctly", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler:nil))
                mediaPicker.present(alert, animated: true, completion: nil)
            }
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    func mediaPickerDidCancel(_ mediaPicker: MPMediaPickerController) {
        mediaPicker.dismiss(animated: true, completion: nil)
    }
}













