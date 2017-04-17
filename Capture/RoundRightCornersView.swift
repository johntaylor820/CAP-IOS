//
//  RoundRightCornersView.swift
//  Capture
//
//  Created by Mathias Palm on 2016-09-04.
//  Copyright © 2016 capture. All rights reserved.
//

import UIKit

class RoundRightCornersView: UILabel {

    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        let maskLayer = CAShapeLayer()
        maskLayer.path = UIBezierPath(roundedRect: bounds, byRoundingCorners: [.bottomRight, .topRight], cornerRadii: CGSize(width: 5, height: 5)).cgPath
        layer.mask = maskLayer
    }
    
}
