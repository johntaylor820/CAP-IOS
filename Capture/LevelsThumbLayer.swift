//
//  LevelsThumbLayer.swift
//  Filterlapse
//
//  Created by Mathias on 2015-04-14.
//  Copyright (c) 2015 Mathias Palm. All rights reserved.
//

import UIKit
import QuartzCore

class LevelsThumbLayer: CALayer {
    var highlighted: Bool = false {
        didSet {
            setNeedsDisplay()
        }
    }
    weak var levelsSlider: LevelsControl?
    var mid = false
    var left = false
    var right = false
    
    override func draw(in ctx: CGContext) {
        if let slider = levelsSlider {

            let thumbPath = UIBezierPath()
            
            if left {
                thumbPath.move(to: CGPoint(x: bounds.width/2, y: 0))
                thumbPath.addLine(to: CGPoint(x: bounds.width/2, y: bounds.height))
                thumbPath.addLine(to: CGPoint(x: bounds.width/2+15, y: bounds.height))
                thumbPath.addLine(to: CGPoint(x: bounds.width/2+3, y: bounds.height-15))
                thumbPath.addLine(to: CGPoint(x: bounds.width/2+3, y: 0))
            } else if mid {
                thumbPath.move(to: CGPoint(x: bounds.width/2 - 1.5, y: 0))
                thumbPath.addLine(to: CGPoint(x: bounds.width/2 - 1.5, y: bounds.height-15))
                thumbPath.addLine(to: CGPoint(x: 2, y: bounds.height))
                thumbPath.addLine(to: CGPoint(x: bounds.width-2, y: bounds.height))
                thumbPath.addLine(to: CGPoint(x: bounds.width/2 + 1, y: bounds.height-15))
                thumbPath.addLine(to: CGPoint(x: bounds.width/2 + 1.5, y: 0))
            } else if right {
                thumbPath.move(to: CGPoint(x: bounds.width/2, y: 0))
                thumbPath.addLine(to: CGPoint(x: bounds.width/2, y: bounds.height))
                thumbPath.addLine(to: CGPoint(x: bounds.width/2-15, y: bounds.height))
                thumbPath.addLine(to: CGPoint(x: bounds.width/2-3, y: bounds.height-15))
                thumbPath.addLine(to: CGPoint(x: bounds.width/2-3, y: 0))
            }
            thumbPath.close()
            
            // Fill - with a subtle shadow
            ctx.setFillColor(UIColor(red: 102/255.0, green: 102/255.0, blue: 102/255.0, alpha: 1.0).cgColor)
            ctx.addPath(thumbPath.cgPath)
            ctx.fillPath()
            
            // Outline
            ctx.setLineWidth(0)
            ctx.setStrokeColor(UIColor(red: 102/255.0, green: 102/255.0, blue: 102/255.0, alpha: 1.0).cgColor)
            ctx.addPath(thumbPath.cgPath)
            ctx.strokePath()
            
            if highlighted {
                ctx.setFillColor(slider.curveColor.cgColor)
                ctx.addPath(thumbPath.cgPath)
                ctx.fillPath()
            }
        }
    }
}
