//
//  BackgroundImageView.swift
//  Capture
//
//  Created by Mathias Palm on 2016-06-09.
//  Copyright © 2016 capture. All rights reserved.
//

import UIKit
import Alamofire
import GPUImage

class BackgroundImageView: ImageView {

    var filter: GPUImageGaussianBlurFilter!
    var picture: GPUImagePicture!
    var gpuView: GPUImageView!
    var blackView: UIView!
    // MARK: - ImageUrlProtocol
    
    func setImageForUser(_ user: User) {
        setImageFromUrl(user.profileBackgroundImage)
        setDefaultImageForUser(user)
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUp()
    }
    
    func setUp() {
        gpuView = GPUImageView(frame: self.frame)
        blackView = UIView(frame: self.frame)
        blackView.backgroundColor = UIColor.black
        blackView.alpha = 0.25
        blackView.tag = 1931
        gpuView.contentMode = .scaleAspectFill
        gpuView.fillMode = kGPUImageFillModePreserveAspectRatioAndFill
        filter = GPUImageGaussianBlurFilter()
        addSubview(gpuView)
        addSubview(blackView)
        
        gpuView.translatesAutoresizingMaskIntoConstraints = false
        blackView.translatesAutoresizingMaskIntoConstraints = false
        
        let widht = NSLayoutConstraint(item: self, attribute: .leading, relatedBy: .equal, toItem: gpuView, attribute: .leading, multiplier: 1, constant: 0)
        let height = NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: gpuView, attribute: .trailing, multiplier: 1, constant: 0)
        let centerY = NSLayoutConstraint(item: self, attribute: .top, relatedBy: .equal, toItem: gpuView, attribute: .top, multiplier: 1, constant: 0)
        let centerX = NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: gpuView, attribute: .bottom, multiplier: 1, constant: 0)

        addConstraints([widht, height, centerY, centerX])
        
        let widhtV = NSLayoutConstraint(item: self, attribute: .leading, relatedBy: .equal, toItem: blackView, attribute: .leading, multiplier: 1, constant: 0)
        let heightV = NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: blackView, attribute: .trailing, multiplier: 1, constant: 0)
        let centerYV = NSLayoutConstraint(item: self, attribute: .top, relatedBy: .equal, toItem: blackView, attribute: .top, multiplier: 1, constant: 0)
        let centerXV = NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: blackView, attribute: .bottom, multiplier: 1, constant: 0)
        
        addConstraints([widhtV, heightV, centerYV, centerXV])
        
        layoutIfNeeded()
    }
    
    func setBgImg(_ newImage: UIImage) {
        image = newImage
    }
    
    func setDefaultImageForUser(_ user: User) {
        image = UIImage(named: "bg")
    }
    
    func setImageFromUrl(_ url: String) {
//        Alamofire.request(url).response {
//            response in
//            response
//            let image = UIImage(data: )
//            if let image = image {
//                self.makeGauseBlur(image)
//            }
//        }
    }
    
    func makeGauseBlur(_ image:UIImage) {
        picture = GPUImagePicture(image: image)
        filter.blurRadiusInPixels = 7.76969696969697
        picture.addTarget(filter)
        filter.addTarget(gpuView)
        picture.processImage()
        blackView.alpha = 0.25
    }
    func changeBluriness(_ radius:CGFloat) {
        if let picture = picture {
            let a = radius / 7.5196969696969 - 0.783
            filter.blurRadiusInPixels = radius
            picture.processImage()
            if a > 0.25 {
                blackView.alpha = 0.25
            } else if a < 0.0 {
                blackView.alpha = 0.0
            } else {
                blackView.alpha = a
            }
        }
    }
}
