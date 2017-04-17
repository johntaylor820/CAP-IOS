//
//  MyCollectionViewCell.swift
//  Capture
//
//  Created by Mathias Palm on 2016-05-03.
//  Copyright © 2016 capture. All rights reserved.
//

import UIKit

class MyCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var videoImageView: ImageView!
    @IBOutlet weak var playImage: UIImageView!
    
    var postID:Int?
    var thumb:String? {
        didSet {
            if let thumb = thumb {
                if thumb.characters.count > 0 {
                    videoImageView.alpha = 1
                    playImage.alpha = 1
                    videoImageView.loadImage(thumb)
                }
            }
        }
    }
}
