//
//  MusicCollectionViewCell.swift
//  Capture
//
//  Created by Mathias Palm on 2016-06-28.
//  Copyright © 2016 capture. All rights reserved.
//

import UIKit

class MusicCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var musicImageView: UIImageView!
    @IBOutlet weak var musicLabel: UILabel!
    
    let selectedColor = UIColor(red: 3/255, green: 167/255, blue: 227/255, alpha: 1.0)
    let color = UIColor(red: 136/255, green: 136/255, blue: 136/255, alpha: 1.0)
    
    override var bounds : CGRect {
        didSet {
            // Fix autolayout constraints broken in Xcode 6 GM + iOS 7.1
            self.contentView.frame = bounds
        }
    }
    override var isSelected:Bool {
        didSet{
            toggleSelectedStatus()
        }
    }
    var image: UIImage? {
        didSet {
            if let image = image {
                musicImageView.image = image
            }
        }
    }
    var name: String? {
        didSet {
            if let name = name {
                musicLabel.text = name
            }
        }
    }
    var song:String?
    
    func toggleSelectedStatus() {
        if isSelected {
            musicImageView.alpha = 0.5
            musicLabel.textColor = color
        } else {
            musicImageView.alpha = 1.0
            musicLabel.textColor = UIColor.white
        }
    }
}
