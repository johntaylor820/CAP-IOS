//
//  CropViewFrame.swift
//  Filterlapse
//
//  Created by Mathias on 2015-03-22.
//  Copyright (c) 2015 Mathias Palm. All rights reserved.
//

import UIKit

class CropViewFrame: UIView {
    var topRightCorner: UIView!
    var topLeftCorner: UIView!
    var bottomLeftCorner: UIView!
    var bottomRightCorner: UIView!
    let cornerPos:CGFloat = 7.0
    let cornerSize:CGFloat = 16
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.frame = frame
        self.layer.borderColor = UIColor.white.cgColor
        self.layer.borderWidth = 1.0
        self.layer.isOpaque = false
        topRightCorner = UIView()
        setupConstraints(topRightCorner, rightOrLeft: .leading, topOrBottom: .top, posX: -cornerPos, posY: -cornerPos)
        topLeftCorner = UIView()
        setupConstraints(topLeftCorner, rightOrLeft: .trailing, topOrBottom: .top, posX: cornerPos, posY: -cornerPos)
        bottomRightCorner = UIView()
        setupConstraints(bottomRightCorner, rightOrLeft: .leading, topOrBottom: .bottom, posX: -cornerPos, posY: cornerPos)
        bottomLeftCorner = UIView()
        setupConstraints(bottomLeftCorner, rightOrLeft: .trailing, topOrBottom: .bottom, posX: cornerPos, posY: cornerPos)
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

    }
    func setupConstraints(_ view: UIView, rightOrLeft: NSLayoutAttribute, topOrBottom: NSLayoutAttribute, posX: CGFloat, posY: CGFloat) {
        view.backgroundColor = UIColor.white
        view.layer.cornerRadius = cornerPos
        self.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        let constX = NSLayoutConstraint(item: view, attribute: rightOrLeft, relatedBy: .equal, toItem: self, attribute: rightOrLeft, multiplier: 1, constant: posX)
        self.addConstraint(constX)
        let constY = NSLayoutConstraint(item: view, attribute: topOrBottom, relatedBy: .equal, toItem: self, attribute: topOrBottom, multiplier: 1, constant: posY)
        self.addConstraint(constY)
        let constW = NSLayoutConstraint(item: view, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 16)
        view.addConstraint(constW)
        let constH = NSLayoutConstraint(item: view, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 16)
        view.addConstraint(constH)
    }
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
