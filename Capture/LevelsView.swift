//
//  LevelsView.swift
//  Filterlapse
//
//  Created by Mathias on 2015-04-18.
//  Copyright (c) 2015 Mathias Palm. All rights reserved.
//

import UIKit

class LevelsView: UIView {
    //LEVELS Controls
    var rgbLevelsControl = LevelsControl()
    var rgbLevelsMax = MaxAndMinControl()
    var redLevelsControl = LevelsControl()
    var redLevelsMax = MaxAndMinControl()
    var greenLevelsControl = LevelsControl()
    var greenLevelsMax = MaxAndMinControl()
    var blueLevelsControl = LevelsControl()
    var blueLevelsMax = MaxAndMinControl()
    var activeView = "RGB"
    var activeLevels:LevelsControl!
    var activeMaxAndMin:MaxAndMinControl!
    var activefilterOperation: FilterOperationInterface!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        createSubView(rgbLevelsControl, max: rgbLevelsMax, color: UIColor(red: 102/255, green: 102/255, blue: 102/255, alpha: 1.0), tag: 0)
        createSubView(redLevelsControl, max: redLevelsMax, color: UIColor.red, tag: 1)
        createSubView(greenLevelsControl, max: greenLevelsMax, color: UIColor.green, tag: 2)
        createSubView(blueLevelsControl, max: blueLevelsMax, color: UIColor.blue, tag: 3)
        activeteView(rgbLevelsControl, max: rgbLevelsMax)
    }
    override func layoutSubviews() {
        setFrame(rgbLevelsControl, max: rgbLevelsMax)
        setFrame(redLevelsControl, max: redLevelsMax)
        setFrame(greenLevelsControl, max: greenLevelsMax)
        setFrame(blueLevelsControl, max: blueLevelsMax)
    }
    fileprivate func setFrame(_ levels:LevelsControl, max:MaxAndMinControl) {
        levels.frame = CGRect(x: 60, y: 8, width: self.frame.size.width - 68, height: self.frame.size.height - 68)
        max.frame = CGRect(x: levels.frame.origin.x, y: levels.frame.origin.y + levels.frame.size.height + 4, width: levels.frame.size.width, height: self.frame.size.height - levels.frame.size.height - 16)
    }
    fileprivate func createSubView(_ levels:LevelsControl, max:MaxAndMinControl, color: UIColor, tag:Int) {
        levels.frame =  CGRect(x: 58, y: 8, width: 300, height: 100)
        levels.color = tag
        levels.curveColor = color
        max.frame = CGRect(x: 58, y: levels.frame.size.height + 8, width: 300, height: 60)
        max.color = tag
        let num = filterOperations.count
        if tag == 0 {
            levels.filterOperation = filterOperations[num-1]
        } else {
            levels.filterOperation = filterOperations[num-2]
        }
        deActivateView(levels, max: max)
        self.addSubview(levels)
        self.addSubview(max)
    }
    
    func showActiveView(_ view:String) {
        switch activeView {
        case "RGB":
            deActivateView(rgbLevelsControl, max: rgbLevelsMax)
        case "R":
            deActivateView(redLevelsControl, max: redLevelsMax)
        case "G":
            deActivateView(greenLevelsControl, max: greenLevelsMax)
        case "B":
            deActivateView(blueLevelsControl, max: blueLevelsMax)
        default:
            break
        }
        switch view {
        case "RGB":
            activeteView(rgbLevelsControl, max: rgbLevelsMax)
        case "R":
            activeteView(redLevelsControl, max: redLevelsMax)
        case "G":
            activeteView(greenLevelsControl, max: greenLevelsMax)
        case "B":
            activeteView(blueLevelsControl, max: blueLevelsMax)
        default:
            break
        }
        activeView = view
    }
    fileprivate func activeteView(_ levels:LevelsControl, max:MaxAndMinControl) {
        activefilterOperation = levels.filterOperation
        activeLevels = levels
        activeMaxAndMin = max
        levels.isUserInteractionEnabled = true
        levels.alpha = 1
        max.isUserInteractionEnabled = true
        max.alpha = 1
    }
    fileprivate func deActivateView(_ levels:LevelsControl, max:MaxAndMinControl) {
        levels.isUserInteractionEnabled = false
        levels.alpha = 0
        max.isUserInteractionEnabled = false
        max.alpha = 0
    }
    func resetAllViews() {
        checkIfActivated(rgbLevelsControl, max: rgbLevelsMax)
        checkIfActivated(redLevelsControl, max: redLevelsMax)
        checkIfActivated(greenLevelsControl, max: greenLevelsMax)
        checkIfActivated(blueLevelsControl, max: blueLevelsMax)
    }
    func resetActiveView() {
        switch activeView {
        case "RGB":
            checkIfActivated(rgbLevelsControl, max: rgbLevelsMax)
        case "R":
            checkIfActivated(redLevelsControl, max: redLevelsMax)
        case "G":
            checkIfActivated(greenLevelsControl, max: greenLevelsMax)
        case "B":
            checkIfActivated(blueLevelsControl, max: blueLevelsMax)
        default:
            break
        }
    }
    func checkIfActivated(_ levels:LevelsControl, max:MaxAndMinControl){
        if levels.black != levels.minimumValue || levels.gamma != levels.maximumValue/2 || levels.white != levels.maximumValue || max.minOut != max.minimumValue || max.maxOut != max.maximumValue {
            resetControlValues(levels, max: max)
        }
    }
    fileprivate func resetControlValues(_ levels:LevelsControl, max:MaxAndMinControl) {
        levels.black = 0.0
        levels.gamma = 0.5
        levels.white = 1.0
        max.maxOut = 1.0
        max.minOut = 0.0
        levels.filterOperation!.updateLelvelsSliderValue(levels.color, min: 0.0, gamma: 0.5, max: 1.0, minOut: 0.0, maxOut: 1.0)
        levels.sendActions(for: .valueChanged)
        max.sendActions(for: .valueChanged)
    }
}









