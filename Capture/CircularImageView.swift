//
//  CircularImageView.swift
//  Capture
//
//  Created by Mathias Palm on 2016-05-27.
//  Copyright © 2016 capture. All rights reserved.
//

import UIKit

class CircularImageView: ImageView {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let radius = bounds.width/2.0
        backgroundColor = UIColor.clear
        layer.cornerRadius = radius
        layer.borderWidth = 2.5
        layer.borderColor = UIColor.white.cgColor
        
        let path = UIBezierPath(roundedRect: bounds.insetBy(dx: 0.5, dy: 0.5), cornerRadius: radius)
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
    // MARK: - ImageUrlProtocol
    
    func setImageForUser(_ user: User) {
        if user.profileImage.characters.count > 0 {
            loadImage(user.profileImage)
        } else {
            image = UIImage(named: "userimg")
        }
    }    
}
class CircularImageViewWithOutBorder: CircularImageView {
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.width/2.0
        layer.borderWidth = 0
        layer.borderColor = UIColor.clear.cgColor
        layer.shadowColor = UIColor.clear.cgColor
        layer.shadowRadius = 0.0
    }
}
