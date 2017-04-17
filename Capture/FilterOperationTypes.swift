//
//  FilterOperationTypes.swift
//  Filterlapse
//
//  Created by Mathias on 2015-02-17.
//  Copyright (c) 2015 Mathias Palm. All rights reserved.
//

import UIKit
import Foundation
import GPUImage

enum FilterSliderSetting {
    case disabled
    case levels(min:CGFloat, gamma:CGFloat, max:CGFloat, minOut:CGFloat, maxOut:CGFloat)
    case enabled(minimumValue:Float, maximumValue:Float, initialValue:Float)
}

enum FilterOperationType {
    case singleInput
    case blend
    case custom(filterSetupFunction:FilterSetupFunction)
}
typealias FilterSetupFunction = (_ camera:GPUImageVideoCamera, _ outputView:GPUImageView) -> (filter:GPUImageOutput, secondOutput:GPUImageOutput?)
protocol FilterOperationInterface {
    var filter: GPUImageOutput { get }
    var listName: String { get }
    var titleName: String { get }
    var tag: Int { get }
    var image: UIImage? { get }
    var lookUpImage: GPUImagePicture? { get }
    var sliderConfiguration: FilterSliderSetting  { get }
    var filterOperationType: FilterOperationType  { get }
    func configureCustomFilter(_ input:(filter:GPUImageOutput, secondInput:GPUImageOutput?))
    func updateBasedOnSliderValue(_ sliderValue:CGFloat)
    func updateLelvelsSliderValue(_ color:Int, min:CGFloat, gamma:CGFloat, max:CGFloat, minOut:CGFloat, maxOut:CGFloat)
}

class FilterOperation<FilterClass: GPUImageOutput>: FilterOperationInterface where FilterClass: GPUImageInput{
    var internalFilter: FilterClass?
    var secondInput: GPUImageOutput?
    let listName: String
    let titleName: String
    var tag: Int
    var image: UIImage?
    var lookUpImage: GPUImagePicture?
    let sliderConfiguration: FilterSliderSetting
    let filterOperationType: FilterOperationType
    let sliderUpdateCallback: ((_ filter:FilterClass, _ sliderValue:CGFloat) -> ())?
    let sliderLevelsCallback: ((_ filter:FilterClass, _ color:Int, _ min:CGFloat, _ gamma:CGFloat, _ max:CGFloat, _ minOut:CGFloat, _ maxOut:CGFloat) -> ())?
    
    init(listName: String, titleName: String, tag: Int, image: UIImage? = nil, lookUpImage: GPUImagePicture? = nil,  sliderConfiguration: FilterSliderSetting, sliderUpdateCallback:((_ filter:FilterClass, _ sliderValue:CGFloat) -> ())?, sliderLevelsCallback: ((_ filter:FilterClass, _ color:Int, _ min:CGFloat, _ gamma:CGFloat, _ max:CGFloat, _ minOut:CGFloat, _ maxOut:CGFloat) -> ())?, filterOperationType: FilterOperationType) {
        self.listName = listName
        self.titleName = titleName
        self.tag = tag
        self.image = image
        self.lookUpImage = lookUpImage
        self.sliderConfiguration = sliderConfiguration
        self.filterOperationType = filterOperationType
        self.sliderUpdateCallback = sliderUpdateCallback
        self.sliderLevelsCallback = sliderLevelsCallback
        switch filterOperationType {
        case .custom:
            break
        default:
            self.internalFilter = FilterClass()
        }
    }
    
    var filter: GPUImageOutput {
        return internalFilter!
    }
    
    func configureCustomFilter(_ input:(filter:GPUImageOutput, secondInput:GPUImageOutput?)) {
        self.internalFilter = (input.filter as! FilterClass)
        self.secondInput = input.secondInput
    }
    func updateBasedOnSliderValue(_ sliderValue:CGFloat) {
        if let updateFunction = sliderUpdateCallback {
            updateFunction(internalFilter!, sliderValue)
        }
    }
    func updateLelvelsSliderValue(_ color:Int, min:CGFloat, gamma:CGFloat, max:CGFloat, minOut:CGFloat, maxOut:CGFloat) {
        if let levelsUpdate = sliderLevelsCallback {
            levelsUpdate(internalFilter!, color, min, gamma, max, minOut, maxOut)
        }
    }
    
}

