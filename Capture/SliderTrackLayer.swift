//
//  SliderTrackLayer.swift
//  Filterlapse
//
//  Created by Mathias on 2015-03-03.
//  Copyright (c) 2015 Mathias Palm. All rights reserved.
//

import UIKit

class SliderTrackLayer: CALayer {
    weak var rangeSlider: RangeSlider?
    
    override func draw(in ctx: CGContext) {
        if let slider = rangeSlider {
            ctx.setStrokeColor(UIColor(red: 102/255, green: 102/255, blue: 102/255, alpha: 1.0).cgColor)
            
            ctx.setLineWidth(1.0)
            ctx.move(to: CGPoint(x: 0, y: 3))
            ctx.addLine(to: CGPoint(x: slider.frame.size.width, y: 3))
            ctx.strokePath()
            ctx.setFillColor(UIColor(red: 29/255, green: 168/255, blue: 224/255, alpha: 1.0).cgColor)
            let valuePosition = CGFloat(slider.positionForValue(slider.value))
            var rect:CGRect!
            if slider.useRange {
                rect = CGRect(x: slider.frame.size.width/2, y: 2.0, width: valuePosition - slider.frame.size.width/2, height: 2.0)
                ctx.move(to: CGPoint(x: slider.frame.size.width/2 - 1, y: 0))
                ctx.addLine(to: CGPoint(x: slider.frame.size.width/2 - 1, y: 6))
                ctx.strokePath()
            } else {
                rect = CGRect(x: 0, y: 2.0, width: valuePosition, height: 2.0)
            }
            ctx.fill(rect)
            
            
        }
    }
}
