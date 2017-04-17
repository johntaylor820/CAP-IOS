//
//  ShadowLabel.swift
//  Capture
//
//  Created by Mathias Palm on 2016-07-06.
//  Copyright © 2016 capture. All rights reserved.
//

import UIKit

class ShadowLabel: UILabel {

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        layer.shadowOpacity = 0.5
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowRadius = 0.2
        layer.shadowOffset = CGSize(width: 0, height: 1)
    }
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
