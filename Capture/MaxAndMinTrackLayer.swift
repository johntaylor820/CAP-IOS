//
//  MaxAndMinTrackLayer.swift
//  Filterlapse
//
//  Created by Mathias on 2015-04-14.
//  Copyright (c) 2015 Mathias Palm. All rights reserved.
//

import UIKit

class MaxAndMinTrackLayer: CALayer {
    weak var maxAndMinSlider: MaxAndMinControl?
    
    override func draw(in ctx: CGContext) {
        if let _ = maxAndMinSlider {
            let path = UIBezierPath(rect: CGRect(x: 15, y: +0.5, width: bounds.width-30, height: bounds.height))
            
            path.move(to: CGPoint(x: 15, y: bounds.height))
            path.addLine(to: CGPoint(x: bounds.width - 15, y: bounds.height))
            path.addLine(to: CGPoint(x: bounds.width - 15, y: 0))
            path.close()
            
            ctx.setFillColor(UIColor(red: 102/255.0, green: 102/255.0, blue: 102/255.0, alpha: 1.0).cgColor)
            ctx.addPath(path.cgPath)
            ctx.fillPath()
            
            let framePath = UIBezierPath()
            
            framePath.move(to: CGPoint(x: 15, y: bounds.height))
            framePath.addLine(to: CGPoint(x: bounds.width - 15, y: bounds.height))
            framePath.addLine(to: CGPoint(x: bounds.width - 15, y: 0))
            
            ctx.setLineWidth(0.5)
            ctx.setStrokeColor(UIColor.white.cgColor)
            ctx.addPath(framePath.cgPath)
            ctx.strokePath()
        }
    }
}
