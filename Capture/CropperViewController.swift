//
//  CropperViewController.swift
//  Capture
//
//  Created by Mathias Palm on 2016-04-12.
//  Copyright © 2016 capture. All rights reserved.
//

import UIKit
import GPUImage
import Photos
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class CropperViewController: UIViewController {
    let screenWidth = UIScreen.main.bounds.width
    var screenHeight = UIScreen.main.bounds.height
    
    var videoAsset:URL!
    var asset:PHAsset!
    var orientation:GPUImageRotationMode!
    
    var movieFile:GPUImageMovie!
    var movieView:GPUImageView!
    
    var transform1:GPUImageTransformFilter!
    var cropFilter:GPUImageCropFilter!
    var tempOrientation:GPUImageRotationMode!
    var newOrientation:GPUImageRotationMode!
    var assetAspect:CGFloat!
    var copyAssetAspect:CGFloat!
    var fixedSizedCalcAspect:CGFloat!
    var fixedAspectActive:CGFloat!
    var orginalFrame:CGRect!
    var croppingFrame:CGRect!
    
    @IBOutlet weak var videoView: UIView!
    
    @IBOutlet var croperView: CropView!
    @IBOutlet var cropTopConstraint: NSLayoutConstraint!
    @IBOutlet var croperHeight: NSLayoutConstraint!
    @IBOutlet var croperWidth: NSLayoutConstraint!
    @IBOutlet var leadingConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.barTintColor = UIColor.white
        navigationController?.navigationBar.alpha = 1

        assetAspect = CGFloat(asset.pixelWidth)/CGFloat(asset.pixelHeight)
        copyAssetAspect = assetAspect
        fixedSizedCalcAspect = assetAspect
        fixedSizedCalcAspect = assetAspect
        newOrientation = orientation
        tempOrientation = orientation
        calculateViewFromAspect(assetAspect)
        movieView = GPUImageView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenWidth))
        movieFile = GPUImageMovie(url: videoAsset)
        movieFile.playAtActualSpeed = true
        movieFile.shouldRepeat = true
        transform1 = GPUImageTransformFilter()
        transform1.setInputRotation(orientation, at: 0)
        cropFilter = GPUImageCropFilter()
        movieFile.addTarget(transform1)
        transform1.addTarget(cropFilter)
        cropFilter.addTarget(movieView)
        videoView.addSubview(movieView)
        setCroppingFrame(assetAspect)
        orginalFrame = CGRect(x: 0, y: 0, width: CGFloat(asset.pixelWidth), height: CGFloat(asset.pixelHeight))
        croppingFrame = CGRect(x: 0, y: 0, width: 1, height: 1)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        movieFile.startProcessing()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func NextButtonPressed(_ sender: AnyObject) {
        newOrientation = tempOrientation
        croppingFrame = neutralizeRect(croperView.croperViewFrame.frame)
        performSegue(withIdentifier: "moveToEdit", sender: nil)
        navigationController?.navigationBar.barTintColor = UIColor.black
        navigationController?.navigationBar.alpha = 0.9

    }
    func neutralizeRect(_ rect:CGRect) -> CGRect {
        let transform = CGAffineTransform(scaleX: 1.0/croperWidth.constant, y: 1.0/croperHeight.constant)
        return rect.applying(transform)
    }
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "moveToEdit" {
            let vc: EditsViewController = segue.destination as! EditsViewController
            vc.videoAsset = videoAsset
            vc.orientation = newOrientation
            vc.croppingFrame = croppingFrame
            movieFile.endProcessing()
            movieFile.removeAllTargets()
            transform1.removeAllTargets()
        }
    }
    func calculateViewFromAspect(_ aspect:CGFloat) {
        var height:CGFloat = 0.0
        var width:CGFloat = 0.0
        if aspect < 1.0 {
            width = aspect * screenHeight
            height = width / aspect
        } else if aspect > 1.0 {
            height = screenWidth / aspect
            width = aspect * height
        } else {
            height = screenWidth
            width = screenWidth
        }
    }
    func setCroppingFrame(_ aspect:CGFloat) {
        var height:CGFloat = 0.0
        var width:CGFloat = 0.0
        if aspect < 1.0 {
            width = aspect * screenWidth
            height = width / aspect
        } else if aspect > 1.0 {
            height = screenWidth / aspect
            width = aspect * height
        } else {
            height = screenWidth
            width = screenWidth
        }
        cropTopConstraint.constant = (screenWidth-height)/2
        leadingConstraint.constant = (screenWidth-width)/2
        croperHeight.constant = height
        croperWidth.constant = width
        view.layoutIfNeeded()
        let y = (screenWidth-width) / 2
        var x:CGFloat = 0.0
        if y == 0 {
            x = (screenWidth-height) / 2
        }
        if width < height {
            croperView.croperViewFrame.frame = CGRect(x: x, y: y, width: width, height: width)
        } else {
            croperView.croperViewFrame.frame = CGRect(x: x, y: y, width: height, height: height)
        }
        croperView.holeRect = croperView.croperViewFrame.frame
    }
    func rotateViewAnimation(_ radians:CGFloat, rotation:GPUImageRotationMode) {
        self.croperView.alpha = 0
        UIView.animate(withDuration: 0.3, delay: 0.0, usingSpringWithDamping: 10, initialSpringVelocity: 10, options: [], animations: {
            self.movieView.transform = CGAffineTransform(rotationAngle: radians)
            }, completion:{
                value in
                UIView.animate(withDuration: 0.1, animations: {
                    self.movieView.alpha = 0
                    }, completion:{
                        value in
                        self.transform1.setInputRotation(rotation, at: 0)
                        self.movieView.transform = CGAffineTransform(rotationAngle: 0)
                        UIView.animate(withDuration: 0.1, delay: 0.1, options: [], animations: {
                            self.movieView.alpha = 1
                            self.croperView.alpha = 1
                            }, completion: nil)
                })
        })
    }
    @IBAction func rotateViewLeft(_ sender: UIButton) {
        rotateView(false)
    }
    @IBAction func rotateViewRight(_ sender: UIButton) {
        rotateView(true)
    }
    func rotateView(_ direction:Bool) {
        var rotation:GPUImageRotationMode = tempOrientation
        var deg:CGFloat = 0.0
        switch tempOrientation.rawValue {
        case 0:
            rotation = direction ? kGPUImageRotateRight : kGPUImageRotateLeft
        case 1:
            rotation = direction ? kGPUImageNoRotation : kGPUImageRotate180
        case 2:
            rotation = direction ? kGPUImageRotate180 : kGPUImageNoRotation
        case 7:
            rotation = direction ? kGPUImageRotateLeft : kGPUImageRotateRight
        default:
            break
        }
        if direction {
            deg = 90
        } else {
            deg = -90
        }
        if orginalFrame.width < orginalFrame.height {
            if copyAssetAspect < 1.0 {
                setCroppingFrame(orginalFrame.height/orginalFrame.width)
                copyAssetAspect = orginalFrame.height/orginalFrame.width
            } else if copyAssetAspect > 1.0 {
                setCroppingFrame(orginalFrame.width/orginalFrame.height)
                copyAssetAspect = orginalFrame.width/orginalFrame.height
            }
        } else if orginalFrame.width > orginalFrame.height {
            if copyAssetAspect > 1.0 {
                setCroppingFrame(orginalFrame.height/orginalFrame.width)
                copyAssetAspect = orginalFrame.height/orginalFrame.width
            } else if copyAssetAspect < 1.0 {
                setCroppingFrame(orginalFrame.width/orginalFrame.height)
                copyAssetAspect = orginalFrame.width/orginalFrame.height
            }
        }
        rotateViewAnimation(degreesToRadians(deg), rotation: rotation)
        tempOrientation = rotation
    }
    @IBAction func goback(_ sender: AnyObject) {
        _ = navigationController?.popViewController(animated: true)
    }
    func degreesToRadians(_ degrees:CGFloat) -> CGFloat {
        return degrees / 180.0 * CGFloat(M_PI)
    }
    @IBAction func resetCropping(_ sender: UIButton) {
        croperView.croperViewFrame.frame = orginalFrame
        croperView.holeRect = orginalFrame
        croppingFrame = CGRect(x: 0, y: 0, width: 1, height: 1)
        calculateViewFromAspect(assetAspect)
        copyAssetAspect = assetAspect
        setCroppingFrame(assetAspect)
        tempOrientation = orientation
        newOrientation = orientation
        transform1.setInputRotation(orientation, at: 0)
    }
}
