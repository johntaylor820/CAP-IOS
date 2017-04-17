//
//  UserCollectionViewCell.swift
//  Capture
//
//  Created by Mathias Palm on 2016-04-18.
//  Copyright © 2016 capture. All rights reserved.
//

import UIKit

class UserCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageBackgroundView: UIView!
    @IBOutlet weak var imageView: CircularImageView!
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var dividerView: UIView!
    
    var username:String?
    var name:String = "" {
        didSet {
            userLabel.text = name
        }
    }
    var imageURL:String? {
        didSet {
            if let imageURL = imageURL {
                imageView.loadImage(imageURL)
            }
        }
    }
}
