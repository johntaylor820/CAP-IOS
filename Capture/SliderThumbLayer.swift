//
//  SliderThumbLayer.swift
//  Filterlapse
//
//  Created by Mathias on 2015-03-04.
//  Copyright (c) 2015 Mathias Palm. All rights reserved.
//

import UIKit
import QuartzCore

class SliderThumbLayer: CALayer {
var highlighted: Bool = false {
        didSet {
            setNeedsDisplay()
        }
    }
    weak var rangeSlider: RangeSlider?
    
    override func draw(in ctx: CGContext) {
        if let _ = rangeSlider {
            let thumbFrame = bounds.insetBy(dx: 2.0, dy: 2.0)
            let cornerRadius = thumbFrame.height / 2.0
            let thumbPath = UIBezierPath(roundedRect: thumbFrame, cornerRadius: cornerRadius)
            if highlighted {
                ctx.setStrokeColor(UIColor(red: 29/255, green: 168/255, blue: 224/255, alpha: 1.0).cgColor)
                ctx.setLineWidth(2.0)
                ctx.addPath(thumbPath.cgPath)
                ctx.strokePath()
            } else {
                ctx.setStrokeColor(UIColor(red: 102/255, green: 102/255, blue: 102/255, alpha: 1.0).cgColor)
                ctx.setLineWidth(2.0)
                ctx.addPath(thumbPath.cgPath)
                ctx.strokePath()
            }
            ctx.setFillColor(UIColor(red: 102/255, green: 102/255, blue: 102/255, alpha: 1.0).cgColor)
            ctx.addPath(thumbPath.cgPath)
            ctx.fillPath()
        }
    }
   
}
