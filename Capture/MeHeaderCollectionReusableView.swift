//
//  MeHeaderCollectionReusableView.swift
//  Capture
//
//  Created by Mathias Palm on 2016-06-30.
//  Copyright © 2016 capture. All rights reserved.
//

import UIKit

class MeHeaderCollectionReusableView: UICollectionReusableView {
    @IBOutlet weak var userImageBackGroundView: BackgroundImageView!
    @IBOutlet weak var blurView: UIView!
    @IBOutlet weak var userImageView: CircularImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var locationDotImageView: UIImageView!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var websiteLabel: UILabel!
    @IBOutlet weak var heighContraints: NSLayoutConstraint!
    var id:Int?
    var name: String? {
        didSet {
            if let name = name {
                nameLabel.text = name
            }
        }
    }
    var location: String? {
        didSet {
            if let location = location , location.characters.count > 0 {
                locationDotImageView.isHidden = false
                locationLabel.text = location
            }
        }
    }
    var info: String? {
        didSet {
            if let info = info {
                infoLabel.text = info
            }
        }
    }
    var website: String? {
        didSet {
            if let website = website {
                let tap = UITapGestureRecognizer(target: self, action: #selector(didTapLink(_:)))
                tap.numberOfTapsRequired = 1
                websiteLabel.addGestureRecognizer(tap)
                websiteLabel.text = website
            }
        }
    }
    func didTapLink(_ sender: UITapGestureRecognizer) {
        if let urlString = websiteLabel.text {
            var newUrl = "http://\(urlString)"
            if urlString.range(of: "http") != nil {
                newUrl = urlString
            }
            let URL = Foundation.URL(string: newUrl)
            if let u = URL {
                if UIApplication.shared.canOpenURL(u) {
                    UIApplication.shared.openURL(u)
                }
            }
        }
    }
    func setProfileImg(_ stringUrl: String) {
        userImageView.loadImage(stringUrl)
    }
    
    func setBackgroundImg(_ stringUrl: String) {
        if let url = URL(string: stringUrl) {
            userImageBackGroundView.hnk_setImageFromURL(url)
        }
//        userImageBackGroundView.hnk_setImageFromURL(stringUrl)
    }
    func setHeight(_ height: CGFloat) {
        heighContraints.constant = height - 30
        self.layoutIfNeeded()
    }

}
