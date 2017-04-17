//
//  ExplorerLabel.swift
//  Capture
//
//  Created by Mathias Palm on 2016-08-29.
//  Copyright © 2016 capture. All rights reserved.
//

import UIKit

class ExplorerLabel: UICollectionViewCell {
    
    @IBOutlet weak var label: UILabel!
    
    var string: String? {
        didSet {
            label.text = string
        }
    }
}
