//
//  SpeachBubble.swift
//  Capture
//
//  Created by Mathias Palm on 2016-09-13.
//  Copyright © 2016 capture. All rights reserved.
//

import UIKit

class SpeachBubble: UIView {

    var color:UIColor = UIColor(red: 250/255, green: 33/255, blue: 86/255, alpha: 1.0)
    
    lazy var likes: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white
        label.font = UIFont(name: "HelveticaNeue", size: 14)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var imageView: UIImageView = {
        let imageView = UIImageView(frame: CGRect.zero)
        imageView.image = UIImage(named: "explorer_heart")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required convenience init(numLikes: Int) {
        let horzintalMargin:CGFloat = 5
        let height:CGFloat = 30
        var newFrame = CGRect(x: 0, y: 0, width: height + CGFloat("\(numLikes)".characters.count*5)+horzintalMargin, height: height)
        self.init(frame: newFrame)
        //translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = UIColor.clear
        let likesText = "\(numLikes)"
        likes.text = likesText
        newFrame.size.width = horzintalMargin/2 + height*0.35 + horzintalMargin + likesText.widthWithConstrainedHeight(height, font: likes.font) + horzintalMargin
        self.frame = newFrame
        addSubview(likes)
        addSubview(imageView)
        addConstraint(NSLayoutConstraint(item: imageView, attribute: .height, relatedBy: .equal, toItem: self, attribute: .height, multiplier: 0.35, constant: 1.0))
        addConstraint(NSLayoutConstraint(item: imageView, attribute: .width, relatedBy: .equal, toItem: self, attribute: .height, multiplier: 0.35, constant: 1.0))
        addConstraint(NSLayoutConstraint(item: imageView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1.0, constant: -frame.height * 1 / 8))
        addConstraint(NSLayoutConstraint(item: imageView, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: horzintalMargin))
        addConstraint(NSLayoutConstraint(item: likes, attribute: .leading, relatedBy: .equal, toItem: imageView, attribute: .trailing, multiplier: 1.0, constant: horzintalMargin/2))
        addConstraint(NSLayoutConstraint(item: likes, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1.0, constant: -frame.height * 1 / 8))
    }
    
    override func draw(_ rect: CGRect) {
        
        let rounding:CGFloat = 5
        let arrowWidht:CGFloat = 8
        
        let bubbleFrame = CGRect(x: 0, y: 0, width: rect.width, height: rect.height * 3 / 4)
        let bubblePath = UIBezierPath(roundedRect: bubbleFrame, byRoundingCorners: UIRectCorner.allCorners, cornerRadii: CGSize(width: rounding, height: rounding))
        
        color.setStroke()
        color.setFill()
        bubblePath.stroke()
        bubblePath.fill()
        
        let context = UIGraphicsGetCurrentContext()
        let mid = rect.maxX * 1/2
        
        context?.beginPath()
        context?.move(to: CGPoint(x: mid - arrowWidht, y: bubbleFrame.maxY))
        
        context?.addLine(to: CGPoint(x: mid, y: rect.maxY))
        
        context?.addLine(to: CGPoint(x: mid + arrowWidht, y: bubbleFrame.maxY))
        context?.closePath()
        
        context?.setFillColor(color.cgColor)
        context?.fillPath()
        
    }
}
