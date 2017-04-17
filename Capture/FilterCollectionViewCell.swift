//
//  FilterCollectionViewCell.swift
//  Filterlapse
//
//  Created by Mathias on 2015-02-17.
//  Copyright (c) 2015 Mathias Palm. All rights reserved.
//

import UIKit

class FilterCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var filterImage: UIImageView!
    @IBOutlet var filterLabel: UILabel!
    
    @IBOutlet weak var selectedImage: UIImageView!
    
    override var isSelected:Bool {
        didSet{
            toggleSelectedStatus()
        }
    }
    override var bounds : CGRect {
        didSet {
            // Fix autolayout constraints broken in Xcode 6 GM + iOS 7.1
            self.contentView.frame = bounds
        }
    }
    var label:String! {
        didSet {
            filterLabel.text = label.capitalized
        }
    }
    var image: UIImage = UIImage() {
        didSet {
            filterImage.image = image
        }
    }
    func toggleSelectedStatus() {
        if isSelected {
            selectedImage.alpha = 1
        } else {
            selectedImage.alpha = 0
        }
    }
}
