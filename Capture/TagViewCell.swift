//
//  TagViewCell.swift
//  Capture
//
//  Created by Mathias Palm on 2016-07-04.
//  Copyright © 2016 capture. All rights reserved.
//

import UIKit

class TagViewCell: UICollectionViewCell {
    
    @IBOutlet weak var tagLable: UILabel!
    @IBOutlet weak var dividerView: UIView!
    
    @IBOutlet weak var chopperHeight: NSLayoutConstraint!
    var id:Int?
    var tagString:String? {
        didSet {
            chopperHeight.constant = 1/UIScreen.main.scale
            self.layoutIfNeeded()
            setTagLable()
        }
    }
    
    func setTagLable() {
        if let t = tagString {
            tagLable.text = "#\(t)"
        }
    }
}
