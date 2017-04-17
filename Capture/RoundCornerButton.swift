//
//  RoundCornerButton.swift
//  Capture
//
//  Created by Mathias Palm on 2016-06-29.
//  Copyright © 2016 capture. All rights reserved.
//

import UIKit

class RoundCornerButton: UIButton {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        layer.cornerRadius = 4.0
    }
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
