//
//  EditFilterGroup.swift
//  Filterlapse
//
//  Created by Mathias Palm on 2015-07-10.
//  Copyright (c) 2015 Mathias Palm. All rights reserved.
//

import UIKit
import GPUImage

class EditFilterGroup: NSObject {
    
    var groupEditsFilter = [GPUImageOutput]()
    
    //Get static filter options, from index.row
    func fetchStaticFilters(_ filter:Custom_Filters) -> [GPUImageOutput]  {
        groupEditsFilter = Custom_Filters.whatFiltersIsSet(filter)
        resetfiltervalues()
        return groupEditsFilter
    }
    
    //Remove filter
    func removeFilter(_ filterToRemove: GPUImageOutput) -> [GPUImageOutput]  {
        for filter in groupEditsFilter {
            if filter == filterToRemove {
                let index = groupEditsFilter.index(of: filter)
                groupEditsFilter.remove(at: index!)
            }
        }
        return groupEditsFilter
    }
    
    //Add filter
    func addFilter(_ newFilter: GPUImageOutput) -> [GPUImageOutput] {
        if groupEditsFilter.count < 1 {
            groupEditsFilter = [newFilter]
        } else {
            groupEditsFilter.append(newFilter)
            var tempArray = [Int]()
            for filter in groupEditsFilter {
                let tag = extractTagFromFilter(filter)
                tempArray.append(tag)
            }
            _ = tempArray.sorted{$0 < $1}
            for i in 0 ..< tempArray.count - 1 {
                if tempArray[i] == tempArray[i + 1] {
                    tempArray.remove(at: i)
                }
            }
            var newArray = [GPUImageOutput]()
            for x in tempArray {
                switch x {
                case 32:
                    newArray.append(filterOperations[filterOperations.count-2].filter)
                case 33:
                    newArray.append(filterOperations[filterOperations.count-1].filter)
                default:
                    newArray.append(filterOperations[x].filter)
                }
            }
            print(groupEditsFilter)
            groupEditsFilter = newArray
        }
        return groupEditsFilter
    }
    func extractTagFromFilter(_ filter: GPUImageOutput) -> Int{
        var tag:Int!
        for tagfilter in filterOperations {
            if tagfilter.filter == filter {
                tag = tagfilter.tag
                return tag
            }
        }
        return tag
    }
    func retriveValuesForFilter(_ levelsview:LevelsView) -> Dictionary<String, Float> {
        var filterDictionary = [String:Float]()
        if groupEditsFilter.contains(filterOperations[0].filter) {
            let filter = filterOperations[0].filter as! GPUImageContrastFilter
            filterDictionary["contrast"] = Float(filter.contrast)
        }
        if groupEditsFilter.contains(filterOperations[1].filter) {
            let filter = filterOperations[1].filter as! GPUImageBrightnessFilter
            filterDictionary["brightness"] = Float(filter.brightness)
        }
        if groupEditsFilter.contains(filterOperations[2].filter) {
            let filter = filterOperations[2].filter as! GPUImageWhiteBalanceFilter
            filterDictionary["temperature"] = Float(filter.temperature)
        }
        if groupEditsFilter.contains(filterOperations[3].filter) {
            let filter = filterOperations[3].filter as! GPUImageSaturationFilter
            filterDictionary["saturation"] = Float(filter.saturation)
        }
        if groupEditsFilter.contains(filterOperations[4].filter) {
            let filter = filterOperations[4].filter as! GPUImageSharpenFilter
            filterDictionary["sharp"] = Float(filter.sharpness)
        }
        if groupEditsFilter.contains(filterOperations[5].filter) {
            let filter = filterOperations[5].filter as! GPUImageGaussianSelectiveBlurFilter
            filterDictionary["tiltShift"] = Float(filter.excludeCircleRadius)
        }
        if groupEditsFilter.contains(filterOperations[6].filter) {
            let filter = filterOperations[6].filter as! GPUImageVignetteFilter
            filterDictionary["vignette"] = Float(filter.vignetteEnd)
        }
        if groupEditsFilter.contains(filterOperations[filterOperations.count-2].filter) {
            _ = filterOperations[filterOperations.count-2].filter as! GPUImageLevelsFilter
            let gammaG:CGFloat = 0.5
            let blackG:CGFloat = 0.0
            let whiteG:CGFloat = 1.0
            let maxG:CGFloat = 1.0
            let minG:CGFloat = 0.0
            //RED
            if levelsview.redLevelsControl.black != blackG {
                filterDictionary["levelsRBlack"] = Float(levelsview.redLevelsControl.black)
            }
            if levelsview.redLevelsControl.gamma != gammaG {
                filterDictionary["levelsRGamma"] = Float(levelsview.redLevelsControl.gamma)
            }
            if levelsview.redLevelsControl.white != whiteG {
                filterDictionary["levelsRWhite"] = Float(levelsview.redLevelsControl.white)
            }
            if levelsview.redLevelsMax.maxOut != maxG {
                filterDictionary["levelsRMax"] = Float(levelsview.redLevelsMax.maxOut)
            }
            if levelsview.redLevelsMax.minOut != minG {
                filterDictionary["levelsRMin"] = Float(levelsview.redLevelsMax.minOut)
            }
            //GREEN
            if levelsview.greenLevelsControl.black != blackG {
                filterDictionary["levelsGBlack"] = Float(levelsview.greenLevelsControl.black)
            }
            if levelsview.greenLevelsControl.gamma != gammaG {
                filterDictionary["levelsGGamma"] = Float(levelsview.greenLevelsControl.gamma)
            }
            if levelsview.greenLevelsControl.white != whiteG {
                filterDictionary["levelsGWhite"] = Float(levelsview.greenLevelsControl.white)
            }
            if levelsview.greenLevelsMax.maxOut != maxG {
                filterDictionary["levelsGMax"] = Float(levelsview.greenLevelsMax.maxOut)
            }
            if levelsview.greenLevelsMax.minOut != minG {
                filterDictionary["levelsGMin"] = Float(levelsview.greenLevelsMax.minOut)
            }
            //BLUE
            if levelsview.blueLevelsControl.black != blackG {
                filterDictionary["levelsBBlack"] = Float(levelsview.blueLevelsControl.black)
            }
            if levelsview.blueLevelsControl.gamma != gammaG {
                filterDictionary["levelsBGamma"] = Float(levelsview.blueLevelsControl.gamma)
            }
            if levelsview.blueLevelsControl.white != whiteG {
                filterDictionary["levelsBWhite"] = Float(levelsview.blueLevelsControl.white)
            }
            if levelsview.blueLevelsMax.maxOut != maxG {
                filterDictionary["levelsBMax"] = Float(levelsview.blueLevelsMax.maxOut)
            }
            if levelsview.blueLevelsMax.minOut != minG {
                filterDictionary["levelsBMin"] = Float(levelsview.blueLevelsMax.minOut)
            }
        }
        if groupEditsFilter.contains(filterOperations[filterOperations.count-1].filter) {
            _ = filterOperations[filterOperations.count-1].filter as! GPUImageLevelsFilter
            let gammaG:CGFloat = 0.5
            let blackG:CGFloat = 0.0
            let whiteG:CGFloat = 1.0
            let maxG:CGFloat = 1.0
            let minG:CGFloat = 0.0
            //RGB
            if levelsview.rgbLevelsControl.black != blackG {
                filterDictionary["levelsRGBBlack"] = Float(levelsview.rgbLevelsControl.black)
            }
            if levelsview.rgbLevelsControl.gamma != gammaG {
                filterDictionary["levelsRGBGamma"] = Float(levelsview.rgbLevelsControl.gamma)
            }
            if levelsview.rgbLevelsControl.white != whiteG {
                filterDictionary["levelsRGBWhite"] = Float(levelsview.rgbLevelsControl.white)
            }
            if levelsview.rgbLevelsMax.maxOut != maxG {
                filterDictionary["levelsRGBMax"] = Float(levelsview.rgbLevelsMax.maxOut)
            }
            if levelsview.rgbLevelsMax.minOut != minG {
                filterDictionary["levelsRGBMin"] = Float(levelsview.rgbLevelsMax.minOut)
            }
        }
        return filterDictionary
    }
    
    fileprivate func extractNonActivefilters() -> [FilterOperationInterface] {
        var filterOps = [FilterOperationInterface]()
        for filter in filterOperations {
            if !groupEditsFilter.contains(filter.filter) {
                filterOps.append(filter)
            }
        }
        return filterOps
    }
    fileprivate func resetfiltervalues() {
        let filtersToreset = extractNonActivefilters()
        for filter in filtersToreset {
            switch (filter.sliderConfiguration) {
            case let .enabled(_, _, initialValue):
                filter.updateBasedOnSliderValue(CGFloat(initialValue))
            case let .levels(min, gamma, max, minOut, maxOut):
                if filter.tag == 32 {
                    for i in 1...3 {
                        filter.updateLelvelsSliderValue(i, min: min, gamma: gamma, max: max, minOut: minOut, maxOut: maxOut)
                    }
                } else if filter.tag == 33 {
                    filter.updateLelvelsSliderValue(0, min: min, gamma: gamma, max: max, minOut: minOut, maxOut: maxOut)
                }
                break
            case .disabled:
                break
            }
        }
    }
}
