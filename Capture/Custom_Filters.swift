//
//  Custom_Filters.swift
//  Filterlapse
//
//  Created by Mathias Palm on 2015-05-19.
//  Copyright (c) 2015 Mathias Palm. All rights reserved.
//

import Foundation
import CoreData
import GPUImage

//@objc(Custom_Filters)
class Custom_Filters: NSManagedObject {

    //Name
    @NSManaged var filterName: String
    @NSManaged var id: Int16
    @NSManaged var isCustom: Bool
    //Image
    @NSManaged var image: Data
    
    //Sliders
    @NSManaged var contrast: NSNumber?
    @NSManaged var brightness: NSNumber?
    @NSManaged var temperature: NSNumber?
    @NSManaged var saturation: NSNumber?
    @NSManaged var sharp: NSNumber?
    @NSManaged var tiltShift: NSNumber?
    @NSManaged var vignette: NSNumber?
    
    //Levels
    @NSManaged var levelsRGBBlack: NSNumber?
    @NSManaged var levelsRGBWhite: NSNumber?
    @NSManaged var levelsRGBGamma: NSNumber?
    @NSManaged var levelsRGBMax: NSNumber?
    @NSManaged var levelsRGBMin: NSNumber?
    
    @NSManaged var levelsRBlack: NSNumber?
    @NSManaged var levelsRGamma: NSNumber?
    @NSManaged var levelsRMax: NSNumber?
    @NSManaged var levelsRWhite: NSNumber?
    @NSManaged var levelsRMin: NSNumber?
    
    @NSManaged var levelsGBlack: NSNumber?
    @NSManaged var levelsGGamma: NSNumber?
    @NSManaged var levelsGMax: NSNumber?
    @NSManaged var levelsGMin: NSNumber?
    @NSManaged var levelsGWhite: NSNumber?
    
    @NSManaged var levelsBBlack: NSNumber?
    @NSManaged var levelsBGamma: NSNumber?
    @NSManaged var levelsBMax: NSNumber?
    @NSManaged var levelsBMin: NSNumber?
    @NSManaged var levelsBWhite: NSNumber?

    
    class func whatFiltersIsSet(_ filter:Custom_Filters) -> [GPUImageOutput] {
        var filters = [GPUImageOutput]()
        if filter.contrast != nil {
            filters.append(filterOperations[0].filter)
        }
        if filter.brightness != nil {
            filters.append(filterOperations[1].filter)
        }
        if filter.temperature != nil {
            filters.append(filterOperations[2].filter)
        }
        if filter.saturation != nil {
            filters.append(filterOperations[3].filter)
        }
        if filter.sharp != nil {
            filters.append(filterOperations[4].filter)
        }
        if filter.tiltShift != nil {
            filters.append(filterOperations[5].filter)
        }
        if filter.vignette != nil {
            filters.append(filterOperations[6].filter)
        }
        if filter.levelsRBlack != nil || filter.levelsRWhite != nil || filter.levelsRGamma != nil || filter.levelsRMax != nil || filter.levelsRMin != nil || filter.levelsGBlack != nil || filter.levelsGWhite != nil || filter.levelsGGamma != nil || filter.levelsGMax != nil || filter.levelsGMin != nil || filter.levelsBBlack != nil || filter.levelsBWhite != nil || filter.levelsBGamma != nil || filter.levelsBMax != nil || filter.levelsBMin != nil  {
            filters.append(filterOperations[filterOperations.count-2].filter)
        }
        if filter.levelsRGBBlack != nil || filter.levelsRGBWhite != nil || filter.levelsRGBGamma != nil || filter.levelsRGBMax != nil || filter.levelsRGBMin != nil {
            filters.append(filterOperations[filterOperations.count-1].filter)
        }
        if filters.isEmpty || filters.count < 1  {
            filters.append(filterOperations[7].filter)
        }
        return filters
    }
    class func createInManagedObjectContext(_ moc: NSManagedObjectContext, id: Int16, custom:Bool, filter: String, filterImage: Data, filterValues:Dictionary<String, Float>) -> Custom_Filters {
        let newItem = NSEntityDescription.insertNewObject(forEntityName: "Custom_Filters", into: moc) as! Custom_Filters
        
        newItem.filterName = filter
        newItem.id = id
        newItem.image = filterImage
        newItem.isCustom = custom
        
        //Sliders
        if filterValues["contrast"] != nil {
            newItem.contrast = CGFloat(filterValues["contrast"]!) as NSNumber?
        }
        if filterValues["brightness"] != nil {
            newItem.brightness = CGFloat(filterValues["brightness"]!) as NSNumber?
        }
        if filterValues["temperature"] != nil {
            newItem.temperature = CGFloat(filterValues["temperature"]!) as NSNumber?
        }
        if filterValues["saturation"] != nil {
            newItem.saturation = CGFloat(filterValues["saturation"]!) as NSNumber?
        }
        if filterValues["sharp"] != nil {
            newItem.sharp = CGFloat(filterValues["sharp"]!) as NSNumber?
        }
        if filterValues["tiltShift"] != nil {
            newItem.tiltShift = CGFloat(filterValues["tiltShift"]!) as NSNumber?
        }
        if filterValues["vignette"] != nil {
            newItem.vignette = CGFloat(filterValues["vignette"]!) as NSNumber?
        }
        //Levels
        if filterValues["levelsRGBBlack"] != nil {
            newItem.levelsRGBBlack = CGFloat(filterValues["levelsRGBBlack"]!) as NSNumber?
        }
        if filterValues["levelsRGBWhite"] != nil {
            newItem.levelsRGBWhite = CGFloat(filterValues["levelsRGBWhite"]!) as NSNumber?
        }
        if filterValues["levelsRGBGamma"] != nil {
            newItem.levelsRGBGamma = CGFloat(filterValues["levelsRGBGamma"]!) as NSNumber?
        }
        if filterValues["levelsRGBMax"] != nil {
            newItem.levelsRGBMax = CGFloat(filterValues["levelsRGBMax"]!) as NSNumber?
        }
        if filterValues["levelsRGBMin"] != nil {
            newItem.levelsRGBMin = CGFloat(filterValues["levelsRGBMin"]!) as NSNumber?
        }
        if filterValues["levelsRBlack"] != nil {
            newItem.levelsRBlack = CGFloat(filterValues["levelsRBlack"]!) as NSNumber?
        }
        if filterValues["levelsRWhite"] != nil {
            newItem.levelsRWhite = CGFloat(filterValues["levelsRWhite"]!) as NSNumber?
        }
        if filterValues["levelsRGamma"] != nil {
            newItem.levelsRGamma = CGFloat(filterValues["levelsRGamma"]!) as NSNumber?
        }
        if filterValues["levelsRMax"] != nil {
            newItem.levelsRMax = CGFloat(filterValues["levelsRMax"]!) as NSNumber?
        }
        if filterValues["levelsRMin"] != nil {
            newItem.levelsRMin = CGFloat(filterValues["levelsRMin"]!) as NSNumber?
        }
        if filterValues["levelsGBlack"] != nil {
            newItem.levelsGBlack = CGFloat(filterValues["levelsGBlack"]!) as NSNumber?
        }
        if filterValues["levelsGWhite"] != nil {
            newItem.levelsGWhite = CGFloat(filterValues["levelsGWhite"]!) as NSNumber?
        }
        if filterValues["levelsGGamma"] != nil {
            newItem.levelsGGamma = CGFloat(filterValues["levelsGGamma"]!) as NSNumber?
        }
        if filterValues["levelsGMax"] != nil {
            newItem.levelsGMax = CGFloat(filterValues["levelsGMax"]!) as NSNumber?
        }
        if filterValues["levelsGMin"] != nil {
            newItem.levelsGMin = CGFloat(filterValues["levelsGMin"]!) as NSNumber?
        }
        if filterValues["levelsBBlack"] != nil {
            newItem.levelsBBlack = CGFloat(filterValues["levelsBBlack"]!) as NSNumber?
        }
        if filterValues["levelsBWhite"] != nil {
            newItem.levelsBWhite = CGFloat(filterValues["levelsBWhite"]!) as NSNumber?
        }
        if filterValues["levelsBGamma"] != nil {
            newItem.levelsBGamma = CGFloat(filterValues["levelsBGamma"]!) as NSNumber?
        }
        if filterValues["levelsBMax"] != nil {
            newItem.levelsBMax = CGFloat(filterValues["levelsBMax"]!) as NSNumber?
        }
        if filterValues["levelsBMin"] != nil {
            newItem.levelsBMin = CGFloat(filterValues["levelsBMin"]!) as NSNumber?
        }
        return newItem
    }
}
