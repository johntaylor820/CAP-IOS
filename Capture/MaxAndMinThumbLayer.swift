//
//  MaxAndMinThumbLayer.swift
//  Filterlapse
//
//  Created by Mathias on 2015-04-14.
//  Copyright (c) 2015 Mathias Palm. All rights reserved.
//

import UIKit
import QuartzCore

class MaxAndMinThumbLayer: CALayer {
    var highlighted: Bool = false {
        didSet {
            setNeedsDisplay()
        }
    }
    weak var maxAndMinSlider: MaxAndMinControl?
    var left = true
    
    override func draw(in ctx: CGContext) {
        if let _ = maxAndMinSlider {
            
            let thumbPath = UIBezierPath()
            
            var leftLine:CGFloat = -3.0
            
            if left {
                leftLine = 3.0
            }
            
            thumbPath.move(to: CGPoint(x: bounds.width/2, y: 0))
            thumbPath.addLine(to: CGPoint(x: bounds.width/2, y: bounds.height))
            thumbPath.addLine(to: CGPoint(x: bounds.width/2+leftLine, y: bounds.height))
            thumbPath.addLine(to: CGPoint(x: bounds.width/2+leftLine, y: bounds.height/2+10))
            thumbPath.addLine(to: CGPoint(x: bounds.width/2+leftLine*5, y: bounds.height/2))
            thumbPath.addLine(to: CGPoint(x: bounds.width/2+leftLine, y: bounds.height/2-10))
            thumbPath.addLine(to: CGPoint(x: bounds.width/2+leftLine, y: 0))
            
            
            thumbPath.close()
            
            // Fill - with a subtle shadow
            ctx.setFillColor(UIColor.black.cgColor)
            ctx.addPath(thumbPath.cgPath)
            ctx.fillPath()
            
            // Outline
            ctx.setLineWidth(0)
            ctx.addPath(thumbPath.cgPath)
            ctx.strokePath()
            
            if highlighted {
                ctx.setFillColor(UIColor(red: 29/255.0, green: 168/255.0, blue: 224/255.0, alpha: 1.0).cgColor)
                ctx.addPath(thumbPath.cgPath)
                ctx.fillPath()
            }
        }
    }
}
