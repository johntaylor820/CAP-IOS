//
//  TagCollectionViewCell.swift
//  Capture
//
//  Created by Mathias Palm on 2016-04-18.
//  Copyright © 2016 capture. All rights reserved.
//

import UIKit

class TagCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var tagView: UIView!
    @IBOutlet weak var tagLabel: UILabel!
    
    var text = "" {
        didSet {
            tagView.layer.cornerRadius = 5
            tagView.layer.borderColor = UIColor.white.cgColor
            tagView.layer.borderWidth = 1
            tagLabel.text = text
            self.layoutIfNeeded()
        }
    }
}
