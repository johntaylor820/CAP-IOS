//
//  RangeSliderView.swift
//  Filterlapse
//
//  Created by Mathias Palm on 2015-08-07.
//  Copyright (c) 2015 Mathias Palm. All rights reserved.
//

import UIKit
protocol UpdateGroupFiltersDelegate {
    func removeFilterFromGroup(_ filter:FilterOperationInterface)
    func addFilterToGroup(_ filter:FilterOperationInterface)
    func isUpdating()
}

class RangeSliderView: UIScrollView {
    
    var updateDelegate:UpdateGroupFiltersDelegate?
    
    var contrast:RangeSlider!
    var brightness:RangeSlider!
    var temp:RangeSlider!
    var saturation:RangeSlider!
    var sharp:RangeSlider!
    var tiltShift:RangeSlider!
    var vignette:RangeSlider!
    
    var addContrast = true
    var addBrightness = true
    var addTemp = true
    var addSaturation = true
    var addSharp = true
    var addTiltShift = true
    var addVignette = true
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        let screenWidth = UIScreen.main.bounds.width
        let width = screenWidth - 120
        contrast = RangeSlider(frame: CGRect(x: 105, y: 10, width: width, height: 50))
        createLabel("Contrast", slider: contrast)
        contrast.filterOperation = filterOperations[0]
        contrast.configSlider(0.0, maximumValue: 100.0, initialValue: 50.0)
        contrast.id = 0
        contrast.addTarget(self, action: #selector(RangeSliderView.updateUseRangeVal(_:)), for: .valueChanged)
        
        brightness = RangeSlider(frame: CGRect(x: 105, y: contrast.frame.origin.y + 50, width: width, height: 50))
        createLabel("Brightness", slider: brightness)
        brightness.filterOperation = filterOperations[1]
        brightness.configSlider(0.0, maximumValue: 100.0, initialValue: 50.0)
        brightness.id = 1
        brightness.addTarget(self, action: #selector(RangeSliderView.updateUseRangeVal(_:)), for: .valueChanged)
        
        temp = RangeSlider(frame: CGRect(x: 105, y: brightness.frame.origin.y + 50, width: width, height: 50))
        createLabel("Temperature", slider: temp)
        temp.filterOperation = filterOperations[2]
        temp.configSlider(0.0, maximumValue: 100.0, initialValue: 50.0)
        temp.id = 2
        temp.addTarget(self, action: #selector(RangeSliderView.updateUseRangeVal(_:)), for: .valueChanged)
        
        saturation = RangeSlider(frame: CGRect(x: 105, y: temp.frame.origin.y + 50, width: width, height: 50))
        createLabel("Saturation", slider: saturation)
        saturation.filterOperation = filterOperations[3]
        saturation.configSlider(0.0, maximumValue: 100.0, initialValue: 50.0)
        saturation.id = 3
        saturation.addTarget(self, action: #selector(RangeSliderView.updateUseRangeVal(_:)), for: .valueChanged)
        
        sharp = RangeSlider(frame: CGRect(x: 105, y: saturation.frame.origin.y + 50, width: width, height: 50))
        createLabel("Sharp", slider: sharp)
        sharp.filterOperation = filterOperations[4]
        sharp.configSlider(0.0, maximumValue: 100.0, initialValue: 50.0)
        sharp.id = 4
        sharp.addTarget(self, action: #selector(RangeSliderView.updateUseRangeVal(_:)), for: .valueChanged)
        
        /*tiltShift = RangeSlider(frame: CGRectMake(105, sharp.frame.origin.y + 50, width, 50))
        createLabel("Tilt Shift", slider: tiltShift)
        tiltShift.filterOperation = filterOperations[5]
        tiltShift.filterOperation(0.0, maximumValue: 1.0, initialValue: 0.0)
        tiltShift.id = 5
        tiltShift.useRange = false
        tiltShift.addTarget(self, action: "updateNoneRangeVal:", forControlEvents: .ValueChanged)*/
        
        //Change the frame if uncomment!!
        
        vignette = RangeSlider(frame: CGRect(x: 105, y: sharp.frame.origin.y + 50, width: width, height: 50))
        createLabel("Vignette", slider: vignette)
        vignette.filterOperation = filterOperations[6]
        vignette.configSlider(0.0, maximumValue: 100.0, initialValue: 0.0)
        vignette.id = 6
        vignette.useRange = false
        vignette.addTarget(self, action: #selector(RangeSliderView.updateNoneRangeVal(_:)), for: .valueChanged)
        
        self.contentSize = CGSize(width: screenWidth, height: 50 * 6 + 10)
        
        addSubview(contrast)
        addSubview(brightness)
        addSubview(temp)
        addSubview(saturation)
        addSubview(sharp)
        //addSubview(tiltShift)
        addSubview(vignette)
    }
    func createLabel(_ text:String, slider:RangeSlider) {
        let label = UILabel(frame: CGRect(x: 0, y: slider.frame.origin.y, width: 90, height: 50))
        label.text = text
        label.textAlignment = .right
        label.textColor = UIColor.white
        label.font = UIFont(name: "HelveticaNeue", size: 14)
        self.addSubview(label)
    }
    func updateUseRangeVal(_ sender:RangeSlider) {
        if sender.isTracking1 {
            sender.filterOperation!.updateBasedOnSliderValue(CGFloat(sender.value))
            switch sender.filterOperation!.titleName {
            case "Contrast":
                if addContrast {
                    updateDelegate?.addFilterToGroup(sender.filterOperation!)
                    addContrast = false
                }
            case "Brightness":
                if addBrightness {
                    updateDelegate?.addFilterToGroup(sender.filterOperation!)
                    addBrightness = false
                }
            case "Temperature":
                if addTemp {
                    updateDelegate?.addFilterToGroup(sender.filterOperation!)
                    addTemp = false
                }
            case "Saturation":
                if addSaturation {
                    updateDelegate?.addFilterToGroup(sender.filterOperation!)
                    addSaturation = false
                }
            case "Sharp":
                if addSharp {
                    updateDelegate?.addFilterToGroup(sender.filterOperation!)
                    addSharp = false
                }
            default:
                break
            }
        } else {
            sender.filterOperation!.updateBasedOnSliderValue(0.5)
            switch sender.filterOperation!.titleName {
            case "Contrast":
                if !addContrast {
                    updateDelegate?.removeFilterFromGroup(sender.filterOperation!)
                    addContrast = true
                }
            case "Brightness":
                if !addBrightness {
                    updateDelegate?.removeFilterFromGroup(sender.filterOperation!)
                    addBrightness = true
                }
            case "Temperature":
                if !addTemp {
                    updateDelegate?.removeFilterFromGroup(sender.filterOperation!)
                    addTemp = true
                }
            case "Saturation":
                if !addSaturation {
                    updateDelegate?.removeFilterFromGroup(sender.filterOperation!)
                    addSaturation = true
                }
            case "Sharp":
                if !addSharp {
                    updateDelegate?.removeFilterFromGroup(sender.filterOperation!)
                    addSharp = true
                }
            default:
                break
            }
            updateDelegate?.isUpdating()
        }
    }
    func updateNoneRangeVal(_ sender:RangeSlider) {
        if sender.isHighlighted {
            sender.filterOperation!.updateBasedOnSliderValue(CGFloat(sender.value))
            if sender.filterOperation!.titleName == "Tilt Shift" {
                if addTiltShift {
                    updateDelegate?.addFilterToGroup(sender.filterOperation!)
                    addTiltShift = false
                }
            } else if sender.filterOperation!.titleName == "Vignette" {
                if addVignette {
                    updateDelegate?.addFilterToGroup(sender.filterOperation!)
                    addVignette = false
                }
            }
        } else {
            sender.filterOperation!.updateBasedOnSliderValue(0.0)
            if sender.filterOperation!.titleName == "Tilt Shift" {
                if !addTiltShift {
                    updateDelegate?.removeFilterFromGroup(sender.filterOperation!)
                    addTiltShift = true
                }
            } else if sender.filterOperation!.titleName == "Vignette" {
                if !addVignette {
                    updateDelegate?.removeFilterFromGroup(sender.filterOperation!)
                    addVignette = true
                }
            }
        }
    }
    func reset() {
        contrast.resetSlider()
        brightness.resetSlider()
        temp.resetSlider()
        saturation.resetSlider()
        sharp.resetSlider()
        //tiltShift.resetSlider()
        vignette.resetSlider()
        addContrast = true
        addBrightness = true
        addTemp = true
        addSaturation = true
        addSharp = true
        addTiltShift = true
        addVignette = true
    }
}
