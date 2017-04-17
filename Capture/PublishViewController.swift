//
//  PublishViewController.swift
//  Capture
//
//  Created by Mathias Palm on 2016-04-17.
//  Copyright © 2016 capture. All rights reserved.
//

import UIKit
import AVFoundation
import Foundation
import GPUImage
import Social
import Photos


class PublishViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UITextViewDelegate, LocationDelegate, CLLocationManagerDelegate {
    
    //Passed info
    var filterArray = [GPUImageOutput]()
    var lookUpRow: Int?
    var movieURL:URL!
    var rotated = false
    var circularProgress: CircularProgress!
    var photosAsset: PHFetchResult<AnyObject>!
    var collection: PHAssetCollection!
    var assetCollectionPlaceholder: PHObjectPlaceholder!
    
    @IBOutlet weak var locationButton: UIButton!
    let screenWidth = UIScreen.main.bounds.width
    var screenHeight = UIScreen.main.bounds.height
    var saved = false
    var newURL:URL!
    var locationName:String?
    
    
    var users: [User] = []
    var tags: [Tag] = []
    var page: Int = 0
    
    var postID: Int?
    let locationManager = CLLocationManager()
    var locationCoordinate:CLLocationCoordinate2D?
    
    @IBOutlet weak var captionTextView: UITextView!
    @IBOutlet weak var cirlceFrame: UIView!
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var utillityView: UIView!
    @IBOutlet weak var utilInfoLabel: UILabel!
    
    let userInfo = ["Start typing a tag...", "Start typing a name..."]
    
    @IBOutlet weak var searchCollectionView: UICollectionView!
    
    var musicUrl:URL?
    var videoVolume:Float?
    var musicVolume:Float?
    var musicStartTime:Double?
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var loadingLabel: UILabel!
    
    //Writer
    var movieWriter:GPUImageMovieWriter!
    var movieFile:GPUImageMovie!
    var transform:GPUImageTransformFilter!
    var crop:GPUImageCropFilter!
    var timer:Timer!
    var cropping:CGRect!
    var orientation:GPUImageRotationMode!
    
    @IBOutlet var chopperHeights: [NSLayoutConstraint]!
    
    
    override func viewDidLoad() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled(){
            locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
            locationManager.requestLocation()
        }
        super.viewDidLoad()
        
        navigationController?.navigationBar.barTintColor = UIColor.white
        navigationController?.navigationBar.alpha = 1

        for chopperHeight in chopperHeights {
            chopperHeight.constant = 1/UIScreen.main.scale
        }
        view.layoutIfNeeded()
        let ch = cirlceFrame.frame.size.height
        let cx = (cirlceFrame.frame.size.width - ch) / 4
        circularProgress = CircularProgress(frame: CGRect(x: cx, y: 0, width: ch, height: ch))
        cirlceFrame.addSubview(circularProgress)
        circularProgress.translatesAutoresizingMaskIntoConstraints = false
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let date = Date()
        let dateString = "\(date)"
        let separationCharacters = CharacterSet(charactersIn: " ")
        let wordArray = dateString.components(separatedBy: separationCharacters)
        var compactDateString = ""
        for word in wordArray {
            compactDateString += word
        }
        let pathToMovie = documentsURL.appendingPathComponent("capture_video\(compactDateString).m4v")
        captionTextView.delegate = self
        newURL = URL(fileURLWithPath: pathToMovie.path)
        
        if let url = musicUrl, let videoVolume = videoVolume, let musicVolume = musicVolume, let musicStartTime = musicStartTime {
            mergeVideoAndMusicWithVolume(movieURL, audioURL: url, startAudioTime: musicStartTime, volumeVideo: videoVolume, volumeAudio: musicVolume, complete: {url in
                if let url = url {
                    self.movieURL = url
                }
                self.startProcess()
            })
        } else {
            startProcess()
        }

    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse && locationCoordinate == nil {
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationManager.stopUpdatingLocation()
        if let location = locations.first {
            locationCoordinate = location.coordinate
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error:: \(error)")
    }
    
    func startProcess() {
        let asset = AVURLAsset(url: movieURL, options: nil)
        if asset.tracks.count > 0 {
            movieWriter = GPUImageMovieWriter(movieURL: newURL, size: CGSize(width: 480,  height: 480))
            movieFile = GPUImageMovie(url: movieURL)
            let audio = asset.tracks(withMediaType: AVMediaTypeAudio)
            if audio.count > 0 {
                movieWriter.shouldPassthroughAudio = true
                movieFile.audioEncodingTarget = movieWriter
            }
            transform = GPUImageTransformFilter()
            transform.setInputRotation(orientation, at: 0)
            crop = GPUImageCropFilter()
            crop.forceProcessing(at: CGSize(width: 480, height: 480))
            crop.cropRegion = cropping
            movieFile.addTarget(transform)
            transform.addTarget(crop)
            
            var picture: GPUImagePicture?
            if let lookUpRow = lookUpRow {
                picture = filterOperations[lookUpRow].lookUpImage
                filterArray[0] = GPUImageLookupFilter()
            }
            if filterArray.isEmpty {
                crop.addTarget(movieWriter)
            } else {
                crop.addTarget(filterArray[0] as! GPUImageInput)
                if let picture = picture {
                    picture.addTarget(filterArray[0] as! GPUImageInput, atTextureLocation:1)
                    picture.processImage()
                }
                for i in 1 ..< filterArray.count {
                    filterArray[i - 1].addTarget(filterArray[i] as! GPUImageInput)
                }
                filterArray[filterArray.count - 1].addTarget(movieWriter)
            }
            movieFile.enableSynchronizedEncoding(using: movieWriter)
            movieWriter.startRecording()
            movieFile.startProcessing()
            timer = Timer.scheduledTimer(timeInterval: 0.03, target: self, selector: #selector(PublishViewController.updateProgress), userInfo: nil, repeats: true)
        } else {
            DispatchQueue.main.async(execute: {
                self.startProcess()
            })
        }
    }
    
    func resolutionSizeForLocalVideo(_ url:URL) -> CGSize? {
        guard let track = AVAsset(url: url).tracks(withMediaType: AVMediaTypeVideo).first else { return nil }
        let size = track.naturalSize.applying(track.preferredTransform)
        return CGSize(width: size.width, height: size.height)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func delay(_ delay:Double, closure:@escaping ()->()) {
        DispatchQueue.main.asyncAfter(
            deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
    }

    func completeEndcoding() {
        delay(0.1, closure: {
            self.timer.invalidate()
            if !self.filterArray.isEmpty {
                self.filterArray[self.filterArray.count - 1].removeTarget(self.movieWriter)
            }
            self.movieWriter.finishRecording()
            self.movieFile.endProcessing()
            self.navigationItem.rightBarButtonItem?.isEnabled = true
            // TODO REMOVE!
            self.saveVideo(self.newURL)
            self.startUpload()
            if let image = self.thumbnailForVideoAtURL(self.newURL) {
                self.handleImage(image)
            }
            self.locationButton.isEnabled = true
            self.movieFile.removeAllTargets()
            self.movieWriter = nil
            self.movieFile = nil
        })
    }
    func handleImage(_ image:UIImage) {
        let frame = CGRect(x: 0, y: 0, width: self.videoView.frame.size.width, height: self.videoView.frame.size.height)
        let imageView = UIImageView(frame: frame)
        imageView.image = image
        self.cirlceFrame.removeFromSuperview()
        self.videoView.addSubview(imageView)
    }
    fileprivate func thumbnailForVideoAtURL(_ url: URL) -> UIImage? {
        let asset = AVAsset(url: url)
        let assetImageGenerator = AVAssetImageGenerator(asset: asset)
        var time = asset.duration
        time.value = min(time.value, 2)
        do {
            let imageRef = try assetImageGenerator.copyCGImage(at: time, actualTime: nil)
            return UIImage(cgImage: imageRef)
        } catch {
            debugPrint("error could not make image")
            return nil
        }
    }
    func saveVideo(_ url:URL) {
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", "Capture")
        self.collection = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions).firstObject
        if self.collection == nil {
            createAlbum(url)
        } else {
            saveToAlbum(url)
        }
    }
    func saveToAlbum(_ url:URL) {
        //save the video to Photos
        PHPhotoLibrary.shared().performChanges({
            let assetRequest = PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url)
            self.photosAsset = PHAsset.fetchAssets(in: self.collection, options: nil) as? PHFetchResult<AnyObject>
            let albumChangeRequest = PHAssetCollectionChangeRequest(for: self.collection, assets: self.photosAsset as! PHFetchResult<PHAsset>)
            if let placeholder = assetRequest!.placeholderForCreatedAsset, let albumChangeRequest = albumChangeRequest {
                let fastEnumeration = NSArray(array: [placeholder] as [PHObjectPlaceholder])
                albumChangeRequest.addAssets(fastEnumeration)
            }
            }, completionHandler: { success, error in
                if success {
                    debugPrint("added video to album")
                }else if error != nil{
                    debugPrint("handle error since couldn't save video")
                }
                
        })
    }
    func createAlbum(_ url:URL) {
        PHPhotoLibrary.shared().performChanges({
            let createAlbumRequest : PHAssetCollectionChangeRequest = PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: "Capture")
            self.assetCollectionPlaceholder = createAlbumRequest.placeholderForCreatedAssetCollection
            }, completionHandler: { success, error in
                if success {
                    let collectionFetchResult = PHAssetCollection.fetchAssetCollections(withLocalIdentifiers: [self.assetCollectionPlaceholder.localIdentifier], options: nil)
                    self.collection = collectionFetchResult.firstObject
                    self.saveToAlbum(url)
                }
        })
    }
    @IBAction func locationButtonPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "location", sender: nil)
    }
    func updateProgress() {
        if movieFile.progress == 1.0  && !saved{
            saved = true
            completeEndcoding()
        }
        circularProgress.progress = Double(movieFile.progress)
    }
    override func viewDidDisappear(_ animated: Bool) {
        crop = nil
        transform = nil
        movieFile = nil
        movieWriter = nil
        super.viewDidDisappear(animated)
    }
    // MARK: - Navigation
    
    func addedLocation(_ coordinate: CLLocationCoordinate2D?, name: String?) {
        if let n = name {
            locationCoordinate = coordinate
            locationButton.setTitle("  Location: \(n)", for: UIControlState())
            locationName = n
        }
    }
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "location" {
            let vc = segue.destination as? LocationViewController
            vc?.delegate = self
            if let name = locationName {
                vc?.locationName = name
            }
        }
    }
    
    func startUpload() {
        if let image = videoSnapshot(newURL) {
            if let videoData = try? Data(contentsOf: newURL) {
                let id = UserManager.sharedInstance.user!.id

                FeedManager.sharedInstance.startUploadPost(id, video: videoData, thumb: image, progressLabel: loadingLabel, completion: {id, error in
                    if let id = id {
                        self.postID = id
                        if self.loadingView.isHidden == false {
                            DispatchQueue.main.async(execute: {
                                if self.captionTextView.isFirstResponder {
                                    self.captionTextView.resignFirstResponder()
                                }
                                self.doPost()
                            })
                        }
                    } else {
                        self.errorView.isUserInteractionEnabled = true
                        self.errorView.isHidden = false
                    }
                })
            }
        }
        
    }
    func videoSnapshot(_ vidURL: URL) -> UIImage? {
        let asset = AVURLAsset(url: vidURL)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        let duration = asset.duration.seconds / 2
        let timestamp = CMTimeMake(Int64(duration), 1)
        do {
            let imageRef = try generator.copyCGImage(at: timestamp, actualTime: nil)
            return UIImage(cgImage: imageRef)
        }
        catch _ as NSError
        {
            return nil
        }
    }
    @IBOutlet weak var acitivtyView: UIView!
    @IBOutlet weak var acitivity: UIActivityIndicatorView!

    
    @IBAction func postButtonIsPressed(_ sender: UIBarButtonItem) {
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        self.navigationItem.leftBarButtonItem?.isEnabled = false
//        let id = UserManager.sharedInstance.user!.id
//        self.postID = id
        
        if let _ = postID {
            acitivtyView.isHidden = false
            acitivity.startAnimating()
            if captionTextView.isFirstResponder {
                captionTextView.resignFirstResponder()
            }
            doPost()
        } else {
            loadingView.alpha = 0
            loadingView.isHidden = false
            UIView.animate(withDuration: 0.3, animations: {
                self.loadingView.alpha = 1
            })
        }
    }
    
    func doPost() {
        var postText = captionTextView.text
        if firstTextView {
            postText = ""
        }
        var tags = ""
        let separationCharacters = CharacterSet(charactersIn: " ")
        let wordArray = postText?.components(separatedBy: separationCharacters)
        for a in wordArray! {
            if a.characters.first == "#" {
                let a1 = a.substring(from: a.characters.index(a.startIndex, offsetBy: 1))
                tags = "\(tags)\(a1) "
            }
        }
        if tags.characters.count > 1 {
            tags = tags.substring(to: tags.characters.index(tags.endIndex, offsetBy: -1))
        }
        var id:Int = 0
        if let postID = postID {
            id = postID
        }
        var location = ""
        if let loc = locationName {
            location = "\(loc)"
        }
        
        
        if id == 0 {
            self.acitivtyView.isHidden = true
            self.acitivity.stopAnimating()
            errorView.isUserInteractionEnabled = true
            errorView.isHidden = false
            self.navigationItem.rightBarButtonItem?.isEnabled = true
            self.navigationItem.leftBarButtonItem?.isEnabled = true
        } else {
            var lat:Float = 0.0
            var long:Float = 0.0
            if let locationCoordinate = locationCoordinate {
                lat = Float(locationCoordinate.latitude)
                long = Float(locationCoordinate.longitude)
            }
            FeedManager.sharedInstance.patchPost(id, location:location, lat:lat, long:long, text:postText!, tags: tags, completion: { success, error in
                if success {
                    self.acitivtyView.isHidden = true
                    self.acitivity.stopAnimating()
                    self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "newPost"), object: nil)
                    UserManager.sharedInstance.getCurrentUser() { (user, _) in}
                } else {
                    self.acitivtyView.isHidden = true
                    self.acitivity.stopAnimating()
                    self.errorView.isUserInteractionEnabled = true
                    self.errorView.isHidden = false
                    self.navigationItem.rightBarButtonItem?.isEnabled = true
                    self.navigationItem.leftBarButtonItem?.isEnabled = true
                }
            })
        }
    }
    @IBAction func backButtonPressed(_ sender: AnyObject) {
        _ = navigationController?.popViewController(animated: true)
        navigationController?.navigationBar.barTintColor = UIColor.black
        navigationController?.navigationBar.alpha = 0.9

    }
    @IBOutlet weak var errorView: UIView!
    
    @IBAction func errorButtonPressed(_ sender: UIButton) {
        errorView.isUserInteractionEnabled = false
        errorView.isHidden = true
    }
    // MARK: - Caption
    @IBOutlet weak var defaultView: UIView!
    @IBOutlet weak var userButton: UIButton!
    @IBOutlet weak var tagButton: UIButton!
    var tagBool = false
    var userBool = false
    var searchTerm = "" {
        didSet {
            downloaddata()
        }
    }
    
    @IBAction func tagButtonPressed(_ sender: UIButton) {
        checkFirst()
        var newString = ""
        if let cap = captionTextView.text {
            var space = ""
            if cap.characters.count > 0 {
                if cap.substring(from: cap.characters.index(cap.endIndex, offsetBy: -1)) != " " {
                    space = " "
                }
            }
            newString = "\(cap)\(space)#"
        }
        captionTextView.text = newString
        tagBool = true
        showUtilInfoLabelWithText(userInfo[0])
    }

    @IBAction func userButtonPressed(_ sender: UIButton) {
        checkFirst()
        var newString = ""
        if let cap = captionTextView.text {
            var space = ""
            if cap.characters.count > 0 {
                if cap.substring(from: cap.characters.index(cap.endIndex, offsetBy: -1)) != " " {
                    space = " "
                }
            }
            newString = "\(cap)\(space)@"
        }
        captionTextView.text = newString
        userBool = true
        showUtilInfoLabelWithText(userInfo[1])
    }
    func showCollectionView(_ word:String) {
        searchCollectionView.isHidden = false
        defaultView.isHidden = true
        searchTerm = String(word.characters.dropFirst())
    }
    func insertWord(_ word:String) {
        let cursorPosition = captionTextView.selectedRange.location
        let start = captionTextView.text.index(captionTextView.text.startIndex, offsetBy: cursorPosition - currentWord.characters.count)
        captionTextView.text = captionTextView.text.replacingOccurrences(of: currentWord, with: word, options: .backwards, range: start..<captionTextView.text.index(captionTextView.text.startIndex, offsetBy: cursorPosition))
        clearToDefault()
    }
    var firstTextView = true
    func checkFirst() {
        if firstTextView {
            captionTextView.text = ""
            firstTextView = false
        }
    }
    func textViewDidChange(_ textView: UITextView) {
        if let word = captionTextView.editedWord() {
            if let char = word.characters.first {
                switch char {
                case "@":
                    if !userBool {
                        userBool = true
                        showUtilInfoLabelWithText(userInfo[1])
                        if word.characters.count > 1 {
                            showCollectionView(word)
                        }
                    } else {
                        showCollectionView(word)
                    }
                    break
                case "#":
                    if !tagBool {
                        tagBool = true
                        showUtilInfoLabelWithText(userInfo[0])
                        if word.characters.count > 1 {
                            showCollectionView(word)
                        }
                    } else {
                        showCollectionView(word)
                    }
                    break
                default:
                    clearToDefault()
                    break
                }
            } else {
                clearToDefault()
            }
            currentWord = "\(word)"
        } else {
            clearToDefault()
        }
    }
    var currentWord = ""
    func clearToDefault() {
        hideUtilInfoLabel()
        isAtEnd = false
        userBool = false
        tagBool = false
        searchTerm = ""
        page = 0
        searchCollectionView.isHidden = true
        defaultView.isHidden = false
        cellItems.removeAll()
        searchCollectionView.reloadData()
    }
    func hideUtilInfoLabel() {
        utilInfoLabel.alpha = 0
        userButton.alpha = 1
        userButton.isEnabled = true
        tagButton.alpha = 1
        tagButton.isEnabled = true
    }
    func showUtilInfoLabelWithText(_ text:String) {
        captionTextView.becomeFirstResponder()
        utilInfoLabel.text = text
        utilInfoLabel.alpha = 1
        userButton.alpha = 0
        userButton.isEnabled = false
        tagButton.alpha = 0
        tagButton.isEnabled = false
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
        if firstTextView {
            captionTextView.text = ""
            firstTextView = false
        }
    }
    func downloaddata() {
        page += 1
        if userBool {
            searchUser(searchTerm, page: page)
        } else if tagBool {
            searchTag(searchTerm, page: page)
        }
    }
    func getColoredText(_ text: String) -> NSMutableAttributedString {
        let string:NSMutableAttributedString = NSMutableAttributedString(string: text)
        let words:[String] = text.components(separatedBy: " ")
        for word in words {
            if (word.hasPrefix("@") || word.hasPrefix("#")) {
                let range:NSRange = (string.string as NSString).range(of: word)
                let c = UIColor(red: 29/255, green: 267/255, blue: 223/255, alpha: 1.0)
                string.addAttribute(NSForegroundColorAttributeName, value: c, range: range)
            }
        }
        return string
    }
    
    var cellItems = [Int: [String:String]]()
    var isAtEnd = false
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if userBool {
            return users.count
        } else if tagBool {
            return tags.count
        } else {
            return 0
        }
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell:UICollectionViewCell!
        let row = (indexPath as NSIndexPath).row
        if row + 2 == cellItems.count && !isAtEnd {
            downloaddata()
        }
        if userBool {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "userCell", for: indexPath) as! UserCollectionViewCell
            if let c = cell as? UserCollectionViewCell {
                let user = users[row]
                c.name = user.getName()
                c.username = user.username
                c.imageURL = user.profileImage
                if row == cellItems.count-1 {
                    c.dividerView.isHidden = true
                } else {
                    c.dividerView.isHidden = false
                }
            }
        } else {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "tagCell", for: indexPath) as! TagCollectionViewCell
            if let c = cell as? TagCollectionViewCell {
                let tag = tags[row]
                c.text = tag.name
            }
        }
        cell.contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        cell.contentView.frame = cell.bounds
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if tagBool {
            let tag = tags[(indexPath as NSIndexPath).row]
            insertWord("#\(tag.name)")
        } else if userBool {
            let user = users[(indexPath as NSIndexPath).row]
            insertWord("@\(user.username)")
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        let height = searchCollectionView.frame.size.height
        var widht:CGFloat = 40
        if tagBool {
            let tag = tags[(indexPath as NSIndexPath).row]
            widht = tag.name.widthWithConstrainedHeight(height, font: UIFont(name: "Helvetica-Bold", size: 22)!)
        } else if userBool {
            let user = users[(indexPath as NSIndexPath).row]
            widht = user.getName().widthWithConstrainedHeight(height, font: UIFont(name: "Helvetica-Bold", size: 22)!) + height
        }
        return CGSize(width: widht, height: height)
    }
}

extension PublishViewController {
    fileprivate func storeUsers(_ newUsers: [User]) {
        for user in newUsers {
            users.append(user)
        }
        
    }
    func searchUser(_ query: String, page: Int, refresh: Bool = false) {
        SearchManager.sharedInstance.searchUser(query, completion: {users, error in
            guard users != nil && error == nil else {
                self.isAtEnd = true
                return
            }
            DispatchQueue.main.async {
                self.storeUsers(users!)
                self.searchCollectionView.reloadData()
            }
        })
    }
    
    fileprivate func storeTags(_ newTags: [Tag]) {
        for tag in newTags {
            tags.append(tag)
        }
        
    }
    func searchTag(_ query: String, page: Int, refresh: Bool = false) {
        SearchManager.sharedInstance.searchTags(query, completion: {tags, error in
            guard tags != nil && error == nil else {
                self.isAtEnd = true
                return
            }
            DispatchQueue.main.async {
                self.storeTags(tags!)
                self.searchCollectionView.reloadData()
            }
        })
    }
}

extension PublishViewController {
    func mergeVideoAndMusicWithVolume(_ videoURL: URL, audioURL: URL, startAudioTime: Float64, volumeVideo: Float, volumeAudio: Float, complete: @escaping (URL?) -> ()) {
        
        //The goal is merging a video and a music from iPod library, and set it a volume
        
        //Get the path of App Document Directory
        let dirPaths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let docsDir = dirPaths[0] as String
        
        //Create Asset from record and music
        let assetVideo: AVURLAsset = AVURLAsset(url: videoURL)
        let assetMusic: AVURLAsset = AVURLAsset(url: audioURL)
        
        let composition: AVMutableComposition = AVMutableComposition()
        let compositionVideo: AVMutableCompositionTrack = composition.addMutableTrack(withMediaType: AVMediaTypeVideo, preferredTrackID: CMPersistentTrackID())
        let compositionAudioVideo: AVMutableCompositionTrack = composition.addMutableTrack(withMediaType: AVMediaTypeAudio, preferredTrackID: CMPersistentTrackID())
        let compositionAudioMusic: AVMutableCompositionTrack = composition.addMutableTrack(withMediaType: AVMediaTypeAudio, preferredTrackID: CMPersistentTrackID())
        
        //Add video to the final record
        do {
            try compositionVideo.insertTimeRange(CMTimeRangeMake(kCMTimeZero, assetVideo.duration), of: assetVideo.tracks(withMediaType: AVMediaTypeVideo)[0], at: kCMTimeZero)
        } catch _ {
        }
        
        //Extract audio from the video and the music
        let audioMix: AVMutableAudioMix = AVMutableAudioMix()
        var audioMixParam: [AVMutableAudioMixInputParameters] = []
        
        let assetVideoTrack: AVAssetTrack = assetVideo.tracks(withMediaType: AVMediaTypeAudio)[0]
        let assetMusicTrack: AVAssetTrack = assetMusic.tracks(withMediaType: AVMediaTypeAudio)[0]
        
        let videoParam: AVMutableAudioMixInputParameters = AVMutableAudioMixInputParameters(track: assetVideoTrack)
        videoParam.trackID = compositionAudioVideo.trackID
        
        let musicParam: AVMutableAudioMixInputParameters = AVMutableAudioMixInputParameters(track: assetMusicTrack)
        musicParam.trackID = compositionAudioMusic.trackID
        
        //Set final volume of the audio record and the music
        videoParam.setVolume(volumeVideo, at: kCMTimeZero)
        musicParam.setVolume(volumeAudio, at: kCMTimeZero)
        
        //Add setting
        audioMixParam.append(musicParam)
        audioMixParam.append(videoParam)
        
        //Add audio on final record
        //First: the audio of the record and Second: the music
        do {
            try compositionAudioVideo.insertTimeRange(CMTimeRangeMake(kCMTimeZero, assetVideo.duration), of: assetVideoTrack, at: kCMTimeZero)
        } catch _ {
            assertionFailure()
        }
        
        do {
            try compositionAudioMusic.insertTimeRange(CMTimeRangeMake(CMTimeMake(Int64(startAudioTime * 10000), 10000), assetVideo.duration), of: assetMusicTrack, at: kCMTimeZero)
        } catch _ {
            assertionFailure()
        }
        
        //Add parameter
        audioMix.inputParameters = audioMixParam
        
        //Remove the previous temp video if exist
        let filemgr = FileManager.default
        do {
            if filemgr.fileExists(atPath: "\(docsDir)/movie-merge-music.m4v") {
                try filemgr.removeItem(atPath: "\(docsDir)/movie-merge-music.m4v")
            } else {
            }
        } catch _ {
        }
        
        //Exporte the final record’
        let completeMovie = "\(docsDir)/movie-merge-music.m4v"
        let completeMovieUrl = URL(fileURLWithPath: completeMovie)
        let exporter: AVAssetExportSession = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetHighestQuality)!
        exporter.outputURL = completeMovieUrl
        exporter.outputFileType = AVFileTypeMPEG4
        exporter.shouldOptimizeForNetworkUse = true
        exporter.audioMix = audioMix
        
        exporter.exportAsynchronously(completionHandler: {
            switch exporter.status{
            case  AVAssetExportSessionStatus.failed:
                debugPrint("failed \(exporter.error)")
                DispatchQueue.main.async(execute: {
                    complete(nil)
                })
            case AVAssetExportSessionStatus.cancelled:
                debugPrint("cancelled \(exporter.error)")
                DispatchQueue.main.async(execute: {
                    complete(nil)
                })
            default:
                DispatchQueue.main.async(execute: {
                    complete(completeMovieUrl)
                })
            }
        })
    }
}
