//
//  MaxAndMinControl.swift
//  Filterlapse
//
//  Created by Mathias on 2015-04-14.
//  Copyright (c) 2015 Mathias Palm. All rights reserved.
//

import UIKit
import QuartzCore

class MaxAndMinControl: UIControl {
    let lowerTrackLayer = MaxAndMinTrackLayer()
    let minOutThumbLayer = MaxAndMinThumbLayer()
    let maxOutThumbLayer = MaxAndMinThumbLayer()
    //var activeValue:CGFloat?
    //var activeType:String?
    var id:Int?
    var previousLocation2:CGPoint = CGPoint.zero
    var color = 0
    
    var minimumValue: CGFloat = 0.0 {
        didSet {
            updateLayerFrames()
        }
    }
    var maximumValue: CGFloat = 1.0 {
        didSet {
            updateLayerFrames()
        }
    }
    var minOut: CGFloat = 0.0 {
    didSet {
        updateLayerFrames()
    }
    }
    var maxOut: CGFloat = 1.0 {
    didSet {
        updateLayerFrames()
    }
    }
    var thumbWidth: CGFloat {
        return CGFloat(30)
    }

    override var frame: CGRect {
    didSet {
        updateLayerFrames()
    }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        lowerTrackLayer.maxAndMinSlider = self
        lowerTrackLayer.contentsScale = UIScreen.main.scale
        layer.addSublayer(lowerTrackLayer)
        
        minOutThumbLayer.maxAndMinSlider = self
        minOutThumbLayer.contentsScale = UIScreen.main.scale
        layer.addSublayer(minOutThumbLayer)
        
        maxOutThumbLayer.maxAndMinSlider = self
        maxOutThumbLayer.left = false
        maxOutThumbLayer.contentsScale = UIScreen.main.scale
        layer.addSublayer(maxOutThumbLayer)
        
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    func updateLayerFrames() {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        lowerTrackLayer.frame = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height)
        lowerTrackLayer.setNeedsDisplay()
        
        let minOutThumbCenter = CGFloat(positionForValue(minOut))
        minOutThumbLayer.frame = CGRect(x: minOutThumbCenter - thumbWidth / 2.0, y: 0.0, width: thumbWidth, height: bounds.height)
        minOutThumbLayer.setNeedsDisplay()
        
        let maxOutThumbCenter = CGFloat(positionForValue(maxOut))
        maxOutThumbLayer.frame = CGRect(x: maxOutThumbCenter - thumbWidth / 2.0, y: 0.0, width: thumbWidth, height: bounds.height)
        maxOutThumbLayer.setNeedsDisplay()
        
        CATransaction.commit()
    }
    func positionForValue(_ value: CGFloat) -> CGFloat {
        _ = CGFloat(thumbWidth)
        return CGFloat(bounds.width - thumbWidth) * (value - minimumValue) /
            (maximumValue - minimumValue) + CGFloat(thumbWidth / 2.0)
    }
    // Touch handlers
    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        previousLocation2 = touch.location(in: self)
        var min = positionForValue(minOut) - CGFloat(previousLocation2.x)
        min = min < 0.0 ? -min : min
        var max = positionForValue(maxOut) - CGFloat(previousLocation2.x)
        max = max < 0.0 ? -max : max
        var sorter = [min, max]
        sorter.sort(by: {$0 < $1})
        
        if sorter[0] == min {
            minOutThumbLayer.highlighted = true
        } else if sorter[0] == max {
            maxOutThumbLayer.highlighted = true
        }
        
        return minOutThumbLayer.highlighted || maxOutThumbLayer.highlighted
    }
    func boundValue(_ value: CGFloat, toLowerValue lowerValue: CGFloat, upperValue: CGFloat) -> CGFloat {
        return min(max(value, lowerValue), upperValue)
    }

    override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let location = touch.location(in: self)
        
        let deltaLocation:CGFloat = CGFloat(location.x - previousLocation2.x)
        let deltaValue = (maximumValue - minimumValue) * deltaLocation / CGFloat(bounds.width - bounds.height) / 2.0
        previousLocation2 = location
        
        
        if minOutThumbLayer.highlighted {
            minOut += deltaValue
            minOut = boundValue(minOut, toLowerValue: minimumValue, upperValue: maxOut-0.1)
        } else if maxOutThumbLayer.highlighted {
            maxOut += deltaValue
            maxOut = boundValue(maxOut, toLowerValue:minOut+0.1, upperValue: maximumValue)
        }
        
        self.sendActions(for: .valueChanged)
        return true
    }
    override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        endTracking()
    }
    override func cancelTracking(with event: UIEvent?) {
        endTracking()
    }
    func endTracking() {
        self.sendActions(for: .valueChanged)
        NotificationCenter.default.post(name: Notification.Name(rawValue: "levelsTrackingHasEnded"), object: self)
        minOutThumbLayer.highlighted = false
        maxOutThumbLayer.highlighted = false
    }
}
