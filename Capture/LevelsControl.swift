//
//  LevelsControl.swift
//  Filterlapse
//
//  Created by Mathias on 2015-04-07.
//  Copyright (c) 2015 Mathias Palm. All rights reserved.
//

import UIKit
import QuartzCore

class LevelsControl: UIControl {
    let upperTrackLayer = LevelsTrackLayer()
    let blackThumbLayer = LevelsThumbLayer()
    let gammaThumbLayer = LevelsThumbLayer()
    let whiteThumbLayer = LevelsThumbLayer()
    
    var previousLocation:CGPoint = CGPoint.zero
    var color = 0
    var id:Int?
    var filterOperation: FilterOperationInterface?
    //var activeValue:CGFloat?
    //var activeType:String?
    
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
    var black: CGFloat = 0.0 {
        didSet {
            updateLayerFrames()
        }
    }
    var gamma: CGFloat = 0.5 {
        didSet {
            updateLayerFrames()
        }
    }
    var white: CGFloat = 1.0 {
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
    var curveColor = UIColor.black
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        upperTrackLayer.levelsSlider = self
        upperTrackLayer.contentsScale = UIScreen.main.scale
        layer.addSublayer(upperTrackLayer)
        
        gammaThumbLayer.levelsSlider = self
        gammaThumbLayer.mid = true
        gammaThumbLayer.contentsScale = UIScreen.main.scale
        layer.addSublayer(gammaThumbLayer)
        
        blackThumbLayer.levelsSlider = self
        blackThumbLayer.left = true
        blackThumbLayer.contentsScale = UIScreen.main.scale
        layer.addSublayer(blackThumbLayer)
        
        whiteThumbLayer.levelsSlider = self
        whiteThumbLayer.right = true
        whiteThumbLayer.contentsScale = UIScreen.main.scale
        layer.addSublayer(whiteThumbLayer)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func updateLayerFrames() {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        upperTrackLayer.frame = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height)
        upperTrackLayer.setNeedsDisplay()
        
        let gammaThumbCenter = CGFloat(positionForValue(gamma))
        gammaThumbLayer.frame = CGRect(x: gammaThumbCenter - thumbWidth / 2.0, y: 0.0, width: thumbWidth, height: bounds.height)
        gammaThumbLayer.setNeedsDisplay()
        
        let blackThumbCenter = CGFloat(positionForValue(black))
        blackThumbLayer.frame = CGRect(x: blackThumbCenter - thumbWidth / 2.0, y: 0.0, width: thumbWidth, height: bounds.height)
        blackThumbLayer.setNeedsDisplay()
        
        let whiteThumbCenter = CGFloat(positionForValue(white))
        whiteThumbLayer.frame = CGRect(x: whiteThumbCenter - thumbWidth / 2.0, y: 0.0, width: thumbWidth, height: bounds.height)
        whiteThumbLayer.setNeedsDisplay()
        CATransaction.commit()
        self.sendActions(for: .valueChanged)
    }
    
    func positionForValue(_ value: CGFloat) -> CGFloat {
        _ = CGFloat(thumbWidth)
        return CGFloat(bounds.width - thumbWidth) * (value - minimumValue) /
            (maximumValue - minimumValue) + CGFloat(thumbWidth / 2.0)
    }
    // Touch handlers
    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        previousLocation = touch.location(in: self)
        
        var blackX = positionForValue(black) - CGFloat(previousLocation.x)
        blackX = blackX < 0.0 ? -blackX : blackX
        var gammaX = positionForValue(gamma) - CGFloat(previousLocation.x)
        gammaX = gammaX < 0.0 ? -gammaX : gammaX
        var whiteX = positionForValue(white) - CGFloat(previousLocation.x)
        whiteX = whiteX < 0.0 ? -whiteX : whiteX
        
        var sorter = [blackX, gammaX, whiteX]
        sorter.sort(by: {$0 < $1})

        if sorter[0] == blackX {
            blackThumbLayer.highlighted = true
        } else if sorter[0] == gammaX {
            gammaThumbLayer.highlighted = true
        } else if sorter[0] == whiteX {
            whiteThumbLayer.highlighted = true
        }
        
        return blackThumbLayer.highlighted || gammaThumbLayer.highlighted || whiteThumbLayer.highlighted
    }
    func boundValue(_ value: CGFloat, toLowerValue lowerValue: CGFloat, upperValue: CGFloat) -> CGFloat {
        return min(max(value, lowerValue), upperValue)
    }
    
    override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let location = touch.location(in: self)
        
        let deltaLocation = CGFloat(location.x - previousLocation.x)
        let deltaValue = ((maximumValue - minimumValue) * deltaLocation / CGFloat(bounds.width - bounds.height)) / 2.0
        previousLocation = location
        
        if blackThumbLayer.highlighted {
            let testBlack = black + deltaValue
            if testBlack < gamma-0.01 && testBlack > minimumValue  {
                moveGamma(deltaValue/2)
                black += deltaValue
                black = boundValue(black, toLowerValue: minimumValue, upperValue: gamma-0.01)
            } else if testBlack < minimumValue {
                black = minimumValue
            } else {
                moveGamma(deltaValue)
                black += deltaValue
                black = boundValue(black, toLowerValue: minimumValue, upperValue: gamma-0.01)
            }
        } else if gammaThumbLayer.highlighted {
            let testGamma = gamma + deltaValue
            if testGamma > black+0.01 && testGamma < white-0.01 {
                moveGamma(deltaValue)
            } else if testGamma <= black+0.01 {
                black += deltaValue
                black = boundValue(black, toLowerValue: minimumValue, upperValue: gamma)
                moveGamma(deltaValue)
            } else if testGamma >= white-0.01 {
                white += deltaValue
                white = boundValue(white, toLowerValue: gamma, upperValue: maximumValue)
                moveGamma(deltaValue)
            }
        } else if whiteThumbLayer.highlighted {
            let testWhite = white + deltaValue
            if testWhite > gamma+0.01 && testWhite < maximumValue {
                moveGamma(deltaValue/2)
                white += deltaValue
                white = boundValue(white, toLowerValue: gamma+0.01, upperValue: maximumValue)
            } else if testWhite > maximumValue {
                white = maximumValue
            } else {
                moveGamma(deltaValue)
                white += deltaValue
                white = boundValue(white, toLowerValue: gamma+0.01, upperValue: maximumValue)
            }
        }
        self.sendActions(for: .valueChanged)
        return true
    }
    func moveGamma(_ delta:CGFloat) {
        gamma += delta
        gamma = boundValue(gamma, toLowerValue: black+0.01, upperValue: white-0.01)
    }
    override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        endTracking()
    }
    override func cancelTracking(with event: UIEvent?) {
        endTracking()
    }
    func endTracking() {
        blackThumbLayer.highlighted = false
        gammaThumbLayer.highlighted = false
        whiteThumbLayer.highlighted = false
        self.sendActions(for: .valueChanged)
        NotificationCenter.default.post(name: Notification.Name(rawValue: "levelsTrackingHasEnded"), object: self)
    }

}

