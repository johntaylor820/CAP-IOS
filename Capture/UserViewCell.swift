//
//  UserViewCell.swift
//  Capture
//
//  Created by Mathias Palm on 2016-07-04.
//  Copyright © 2016 capture. All rights reserved.
//

import UIKit

class UserViewCell: UICollectionViewCell {
    @IBOutlet weak var userImageView: CircularImageViewWithOutBorder!
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var dividerView: UIView!
    
    @IBOutlet weak var chopperHeight: NSLayoutConstraint!

    var id:Int?
    var username:String?
    var name:String = "" {
        didSet {
            chopperHeight.constant = 1/UIScreen.main.scale
            self.layoutIfNeeded()
            userLabel.text = name
        }
    }
    var imageURL:String? {
        didSet {
            if let imageURL = imageURL {
                userImageView.loadImage(imageURL)
            }
        }
    }
}
