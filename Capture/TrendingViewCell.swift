//
//  TrendingViewCell.swift
//  Capture
//
//  Created by Mathias Palm on 2016-07-04.
//  Copyright © 2016 capture. All rights reserved.
//

import UIKit

class TrendingViewCell: UICollectionViewCell {
    @IBOutlet weak var trendingLabel: UILabel!
    
    var name: String? {
        didSet{
            if let name = name {
                trendingLabel.text = name
            }
        }
    }
    var id: Int?
}
