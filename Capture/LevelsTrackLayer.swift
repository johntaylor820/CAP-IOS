//
//  LevelsTrackLayer.swift
//  Filterlapse
//
//  Created by Mathias on 2015-04-14.
//  Copyright (c) 2015 Mathias Palm. All rights reserved.
//

import UIKit

class LevelsTrackLayer: CALayer {
    weak var levelsSlider: LevelsControl?
    override func draw(in ctx: CGContext) {
        if let slider = levelsSlider {
            // Clip
            let path = UIBezierPath(rect: CGRect(x: 15, y: 0, width: bounds.width - 30, height: bounds.height-15))
            
            // Fill the track
            ctx.setFillColor(UIColor(red: 1, green: 1, blue: 1, alpha: 0.1).cgColor)
            ctx.setStrokeColor(UIColor(red: 102/255.0, green: 102/255.0, blue: 102/255.0, alpha: 1.0).cgColor)
            ctx.addPath(path.cgPath)
            ctx.fillPath()
            let gridWidth = (bounds.width)/4
            
            
            path.move(to: CGPoint(x: gridWidth+7.5, y: 0))
            path.addLine(to: CGPoint(x: gridWidth+7.5, y: bounds.height-15))
            
            path.move(to: CGPoint(x: gridWidth*2, y: 0))
            path.addLine(to: CGPoint(x: gridWidth*2, y: bounds.height-15))
            
            path.move(to: CGPoint(x: gridWidth*3-7.5, y: 0))
            path.addLine(to: CGPoint(x: gridWidth*3-7.5, y: bounds.height-15))
            
            path.move(to: CGPoint(x: 15, y: (bounds.height-16)/2))
            path.addLine(to: CGPoint(x: bounds.width-15, y: (bounds.height-16)/2))
            
            ctx.addPath(path.cgPath)
            ctx.setLineWidth(0.5)
            ctx.strokePath()

            // Fill the highlighted range
            
            let lowerValuePosition = CGFloat(slider.positionForValue(slider.black))
            let upperValuePosition = CGFloat(slider.positionForValue(slider.white))
            let midPoint = CGFloat(slider.positionForValue(slider.gamma))
            let pathLineHeihgt = (bounds.height-15) / 2.0
            let middlePoint1 = CGFloat(slider.positionForValue((slider.gamma-slider.black)/2))+lowerValuePosition-15
            let middlePoint2 = CGFloat(slider.positionForValue((slider.white-slider.gamma)/2))+midPoint-15
            
            let curvePath = UIBezierPath()
            
            curvePath.move(to: CGPoint(x: lowerValuePosition, y: pathLineHeihgt))
            
            curvePath.addQuadCurve(to: CGPoint(x: midPoint, y: pathLineHeihgt), controlPoint: CGPoint(x: middlePoint1, y: -15))
            curvePath.addQuadCurve(to: CGPoint(x: upperValuePosition, y: pathLineHeihgt), controlPoint: CGPoint(x: middlePoint2, y: bounds.height))
            
            // Outline
            ctx.setStrokeColor(slider.curveColor.cgColor)
            ctx.addPath(curvePath.cgPath)
            ctx.setLineWidth(1.5)
            ctx.strokePath()
        }
    }

}
