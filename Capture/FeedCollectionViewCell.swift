//
//  FeedCollectionViewCell.swift
//  Filterlapse
//
//  Created by Mathias on 2014-12-14.
//  Copyright (c) 2014 Mathias Palm. All rights reserved.
//

import UIKit
import Photos

let OffsetSpeed: CGFloat = 8.0

class FeedCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageFrame: UIView!
    
    override var bounds : CGRect {
        didSet {
            // Fix autolayout constraints broken in Xcode 6 GM + iOS 7.1
            self.contentView.frame = bounds
        }
    }
    var imageManager: PHImageManager?
    var imageAsset: PHAsset? {
        didSet {
            self.imageManager?.requestImage(for: imageAsset!, targetSize: CGSize(width: bounds.width, height: bounds.height), contentMode: .aspectFill, options: nil) { image, info in
            self.imageView.image = image
            }
        }
    }
}
