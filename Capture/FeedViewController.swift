//
//  ViewController.swift
//  Filterlapse
//
//  Created by Mathias on 2014-12-14.
//  Copyright (c) 2014 Mathias Palm. All rights reserved.
//

import UIKit
import AVFoundation
import AssetsLibrary
import Foundation
import GPUImage
import Photos

class FeedViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, PHPhotoLibraryChangeObserver {
    let reuseIdentifier = "Cell"
    let screenWidth = UIScreen.main.bounds.width
    let screenHeight = UIScreen.main.bounds.height
    
    // MARK: - Outlets
    @IBOutlet weak var feedCollectionView: UICollectionView!
    @IBOutlet var accsesDenied: UILabel!
    @IBOutlet var accessDeneidSub: UILabel!

    @IBOutlet var collectionViewTapGesture: UITapGestureRecognizer!
    
    var images: PHFetchResult<AnyObject>?
    let imageManager = PHCachingImageManager()
    
    //Other usefull stuff
    var handler = 0
    var loadingDelay = 0.0
    var latestContentOffset:CGFloat = 0.0
    var distanceBeforMenu:CGFloat = 0.0
    var videoIsPlaying = false
    
    //GPUImage
    var movieFile: GPUImageMovie?
    var movieView: GPUImageView?
    var transformView = GPUImageTransformFilter()
    
    //Pass Values
    var currentVideoToPass: URL?
    var assetToPass:PHAsset?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.tabBar.isHidden = true
        collectionViewTapGesture.isEnabled = false
        view.layoutIfNeeded()
        view.addSubview(feedCollectionView)
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [
            NSSortDescriptor(key: "creationDate", ascending: false)
        ]
        images = PHAsset.fetchAssets(with: .video, options: fetchOptions) as? PHFetchResult<AnyObject>
        
        PHPhotoLibrary.shared().register(self)
        feedCollectionView.reloadData()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let status = PHPhotoLibrary.authorizationStatus()
        if (status == .denied) {
            self.accsesDenied.text = "This app does not have access to your videos"
            self.accessDeneidSub.text = "You can enable access in privacy settings"
            self.accsesDenied.alpha = 1.0
            self.accessDeneidSub.alpha = 1.0
        }
    }
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
    if segue.identifier == "moveToCrop" {
        let vc: CropperViewController = segue.destination as! CropperViewController
            vc.orientation = self.orientationOfVideo(AVAsset(url:currentVideoToPass!))
            vc.videoAsset = currentVideoToPass!
            vc.asset = assetToPass!
        }
    }
    
    @IBAction func cancelButtonPressed(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    
    func photoLibraryDidChange(_ changeInfo: PHChange) {
        DispatchQueue.main.async {
            if let collectionChanges = changeInfo.changeDetails(for: self.images as! PHFetchResult<PHObject>) {
                self.images = collectionChanges.fetchResultAfterChanges as? PHFetchResult<AnyObject>
                self.feedCollectionView.setContentOffset(CGPoint.zero, animated: true)
                self.feedCollectionView.reloadData()
            }
        }
    }

    func RadiansToDegrees(_ radians: CGFloat) -> CGFloat {
        return radians * 180.0 / CGFloat(M_PI)
    }
    func orientationOfVideo(_ asset: AVAsset) -> GPUImageRotationMode {
        let videoTracks = asset.tracks(withMediaType: AVMediaTypeVideo).first
        let txf = videoTracks!.preferredTransform
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
    }

    // MARK: - UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let images = images {
            return images.count
        }
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! FeedCollectionViewCell
        cell.contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        cell.imageManager = imageManager
        cell.imageAsset = images?[(indexPath as NSIndexPath).item] as? PHAsset
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            let xy = screenWidth/3
            return CGSize(width: xy, height: xy)
    }
    func getVideoURL(_ asset: PHAsset, completionHandler: @escaping (URL) -> ()) {
        let options = PHVideoRequestOptions()
        options.deliveryMode = .automatic
        options.isNetworkAccessAllowed = true
        options.version = .original
        imageManager.requestAVAsset(forVideo: asset, options: options, resultHandler: {
            (asset: AVAsset?, audioMix: AVAudioMix?, info: [AnyHashable: Any]?) in
            if let asset = asset as? AVURLAsset {
                completionHandler(asset.url)
            }
        })
    }
    // MARK: - UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        navigationController?.navigationBar.barTintColor = UIColor.white
        navigationController?.navigationBar.alpha = 1

        getVideoURL(images?[(indexPath as NSIndexPath).row] as! PHAsset, completionHandler: { url in
            self.assetToPass = self.images?[(indexPath as NSIndexPath).row] as? PHAsset
            self.currentVideoToPass = url
            //self.navigationController?.popViewControllerAnimated(true)
            DispatchQueue.main.async(execute: {
                self.performSegue(withIdentifier: "moveToCrop", sender:self)
            })
        })
    }
}

