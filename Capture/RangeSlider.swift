//
//  RangeSlider.swift
//  Filterlapse
//
//  Created by Mathias on 2015-03-04.
//  Copyright (c) 2015 Mathias Palm. All rights reserved.
//

import UIKit
import QuartzCore


class RangeSlider: UIControl {
    let trackLayer = SliderTrackLayer()
    let thumbLayer = SliderThumbLayer()
    var previousLocation:CGPoint = CGPoint.zero
    
    var minimumValue: Float = 0.0 {
        didSet {
            updateLayerFrames()
        }
    }
    
    var maximumValue: Float = 1.0 {
        didSet {
            updateLayerFrames()
        }
    }
    var useRange = true
    var isTracking1 = false
    var id:Int?
    var increased:String = ""
    var oldValue:Float = 0.5
    var value: Float = 0.5 {
        didSet {
            updateLayerFrames()
        }
    }
    var filterOperation: FilterOperationInterface?
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
        trackLayer.rangeSlider = self
        trackLayer.contentsScale = UIScreen.main.scale
        layer.addSublayer(trackLayer)
        
        thumbLayer.rangeSlider = self
        thumbLayer.contentsScale = UIScreen.main.scale
        layer.addSublayer(thumbLayer)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(RangeSlider.sliderTaped(_:)))
        self.addGestureRecognizer(tap)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func updateLayerFrames() {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        trackLayer.frame = CGRect(x: 2, y: thumbWidth/2 - 3 + 10, width: bounds.width - 4, height: 6)
        trackLayer.setNeedsDisplay()
        
        let upperThumbCenter = CGFloat(positionForValue(value))
        thumbLayer.frame = CGRect(x: upperThumbCenter - thumbWidth / 2.0, y: 10.0,
            width: thumbWidth, height: thumbWidth)
        thumbLayer.setNeedsDisplay()
        
        CATransaction.commit()
    }
    
    func positionForValue(_ value: Float) -> Float {
        _ = Float(thumbWidth)
        return Float(bounds.width - thumbWidth) * (value - minimumValue) /
            (maximumValue - minimumValue) + Float(thumbWidth / 2.0)
    }
    func sliderTaped(_ tap:UITapGestureRecognizer) {
        let pt = tap.location(in: self)
        let position = CGFloat(positionForValue(value))
        if useRange && !isTracking1 {
            oldValue = value
            if pt.x >= position {
                if !thumbLayer.highlighted {
                    value = maximumValue/2 + 6.0
                    thumbLayer.highlighted = true
                } else if (value >= maximumValue) == false {
                    value += 1
                }
            } else if pt.x <= position {
                if !thumbLayer.highlighted {
                    value = maximumValue/2 - 6.0
                    thumbLayer.highlighted = true
                } else if (value <= minimumValue) == false {
                    value -= 1
                }
            }
            if value <= (maximumValue/2 + 5.0) && value >= (maximumValue/2 - 5.0) {
                thumbLayer.highlighted = false
                value = maximumValue/2
            }
        } else if !isTracking1 {
            if pt.x >= position {
                if (value >= maximumValue) == false {
                    value += 1
                    thumbLayer.highlighted = true
                }
            } else if pt.x <= position {
                if (value <= minimumValue) == false {
                    value -= 1
                }
            }
        }
        endTracking()
    }
    func configSlider(_ minimumValue:Float, maximumValue:Float, initialValue:Float) {
        value = initialValue
        oldValue = value
        self.maximumValue = maximumValue
        self.minimumValue = minimumValue
        thumbLayer.highlighted = false
    }
    func resetSlider() {
        value = useRange ? 50.0 : 0.0
        oldValue = value
        self.maximumValue = Float(maximumValue)
        self.minimumValue = Float(minimumValue)
        thumbLayer.highlighted = false
    }
    // Touch handlers
    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        isTracking1 = true
        previousLocation = touch.location(in: self)
        return super.beginTracking(touch, with: event)
    }
    func boundValue(_ value: Float, toLowerValue lowerValue: Float, upperValue: Float) -> Float {
        return min(max(value, lowerValue), upperValue)
    }
    
    override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let location = touch.location(in: self)
        let deltaLocation = Float(location.x - previousLocation.x)
        let deltaValue = (maximumValue - minimumValue) * deltaLocation / Float(bounds.width - bounds.height)
        value += deltaValue
        value = boundValue(value, toLowerValue: minimumValue, upperValue: maximumValue)
        
        previousLocation = location
        if useRange {
            if value <= (maximumValue/2 + 6.0) && value >= (maximumValue/2 - 6.0) {
                thumbLayer.highlighted = false
            } else {
                thumbLayer.highlighted = true
            }
        } else {
            if value > 0.0 {
                thumbLayer.highlighted = true
            } else {
                thumbLayer.highlighted = false
            }
        }
        if value > maximumValue {
            value = maximumValue
            return false
        } else if value < minimumValue {
            value = minimumValue
            return false
        }
        self.sendActions(for: .valueChanged)
        return true
    }
    override func cancelTracking(with event: UIEvent?) {
        endTracking()
    }
    override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        endTracking()
    }
    func endTracking() {
        if value < oldValue {
            increased = "Decreased"
        } else {
            increased = "Increased"
        }
        if !thumbLayer.highlighted {
            isTracking1 = false
            if useRange {
                value = maximumValue/2
            } else {
                value = minimumValue
            }
        }
        self.sendActions(for: .valueChanged)
        if oldValue != value {
            NotificationCenter.default.post(name: Notification.Name(rawValue: "rangeTrackingHasEnded"), object: self)
        }
    }
}
