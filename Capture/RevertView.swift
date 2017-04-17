//
//  RevertView.swift
//  Filterlapse
//
//  Created by Mathias Palm on 2015-08-09.
//  Copyright (c) 2015 Mathias Palm. All rights reserved.
//

import UIKit
import GPUImage

protocol RevertViewDelegate {
    func updateRevertView(_ array:[GPUImageOutput],value:[Int:(black:Float, gamma:Float, white:Float, min:Float, max:Float)])
}
class RevertView: UIView, UITableViewDelegate, UITableViewDataSource {
    var listOfItems:[(type:String,value:(black:Float, gamma:Float, white:Float, min:Float, max:Float),valueText:String, id:Int)]!
    
    var tableView:UITableView!
    var revertDelegate:RevertViewDelegate?
    var activeCells:[Int]!
    var deActiveCells:[Int]!
    var levelsItems:[Int : (black:Float, gamma:Float, white:Float, min:Float, max:Float)]!
    var levelsOtherAdded = false
    var levelsRGBadded = false

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        listOfItems = [(type:"As Shot", value:(black:0, gamma:0, white:0, min:0, max:0), valueText:"", id:79335)]
        tableView = UITableView(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: 200))
        activeCells = []
        deActiveCells = []
        levelsItems = [:]
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ListItemCell.self, forCellReuseIdentifier: "cell")
        if self.tableView.responds(to: #selector(setter: UIView.layoutMargins)) {
            self.tableView.layoutMargins = UIEdgeInsets.zero
        }
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.separatorColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.5)
        addSubview(tableView)
    }
    func setTableViewBG() {
        tableView.backgroundColor = UIColor.clear
    }
    func addEditToList(_ name:String, value:(black:Float, gamma:Float, white:Float, min:Float, max:Float), valueText:String, id:Int) {
        if !deActiveCells.isEmpty {
            var tempList = Array(listOfItems.reversed())
            if !tempList.isEmpty {
                for _ in deActiveCells {
                    tempList.removeLast()
                }
            }
            listOfItems = Array(tempList.reversed())
            deActiveCells.removeAll(keepingCapacity: false)
        }
        listOfItems.insert((type:name, value: value, valueText:valueText, id:id), at: 0)
        var temp:[Int] = []
        for a in 0..<listOfItems.count - 1 {
            temp.append(a)
        }
        activeCells = temp
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listOfItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! ListItemCell
        let activeItem = listOfItems[(indexPath as NSIndexPath).row]
        cell.typeLabel.text = activeItem.type
        cell.value = activeItem.value
        cell.id = activeItem.id
        cell.valueLabel.text = activeItem.valueText
        if activeCells.contains((indexPath as NSIndexPath).row) || activeItem.id == 79335 {
            cell.active = true
        } else {
            cell.active = false
        }
        return cell
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var tempDeactiveCells:[Int] = []
        for x in 0..<(indexPath as NSIndexPath).row {
            tempDeactiveCells.append(x)
            let cell = tableView.cellForRow(at: IndexPath(row: x, section: 0)) as? ListItemCell
            if cell != nil {
                cell!.active = false
            }
        }
        var tempActiveCells:[Int] = []
        for x in (indexPath as NSIndexPath).row..<listOfItems.count - 1 {
            tempActiveCells.append(x)
            let cell = tableView.cellForRow(at: IndexPath(row: x, section: 0)) as? ListItemCell
            if cell != nil {
                cell!.active = true
            }
        }
        
        activeCells = tempActiveCells
        deActiveCells = tempDeactiveCells
        var listOfActiveItems:[(type:Int,value:(black:Float, gamma:Float, white:Float, min:Float, max:Float))] = []
        var duplicateCheck:[Int] = []
        for j in activeCells {
            let item = listOfItems[j]
            if item.id > 6 {
                var check = false
                switch item.id {
                /*case 7, 8 , 9, 10, 11:
                    check = extendContains(duplicateCheck, values: [27])
                case 12, 13, 14, 15, 16:
                    check = extendContains(duplicateCheck, values: [28])
                case 17, 18, 19, 20, 21:
                    check = extendContains(duplicateCheck, values: [29])
                case 22, 23, 24, 25, 26:
                    check = extendContains(duplicateCheck, values: [30])*/
                case 7, 8 , 9, 10, 11, 27:
                    check = extendContains(duplicateCheck, values: [7,8,9,10,11,27])
                case 12, 13, 14, 15, 16, 28:
                    check = extendContains(duplicateCheck, values: [12,13,14,15,16,28])
                case 17, 18, 19, 20, 21, 29:
                    check = extendContains(duplicateCheck, values: [17,18,19,20,21,29])
                case 22, 23, 24, 25, 26, 30:
                    check = extendContains(duplicateCheck, values: [22,23,24,25,26,30])
                default:
                    break
                }
                if check {
                    if !duplicateCheck.contains(item.id) {
                        listOfActiveItems.append((type:item.id, value: item.value))
                        duplicateCheck.append(item.id)
                    }
                }
                
            } else {
                if !duplicateCheck.contains(item.id) {
                    listOfActiveItems.append((type:item.id, value: item.value))
                    duplicateCheck.append(item.id)
                }
            }
        }
        var items = getRevertFilters(listOfActiveItems)
        var tempArray = [Int]()
        for filter in items {
            let tag = extractTagFromFilter(filter)
            tempArray.append(tag)
        }
        _ = tempArray.sorted{$0 < $1}
        if tempArray.count != 0 {
            for i in 0 ..< tempArray.count - 1 {
                if tempArray[i] == tempArray[i + 1] {
                    tempArray.remove(at: i)
                }
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
        items = newArray
        revertDelegate?.updateRevertView(items, value: levelsItems)
    }
    func extendContains(_ array:[Int],values:[Int]) -> Bool {
        for x in values {
            if array.contains(x) {
                return false
            }
        }
        return true
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
    func getRevertFilters(_ activeItems:[(type:Int,value:(black:Float, gamma:Float, white:Float, min:Float, max:Float))]) -> [GPUImageOutput] {
        levelsOtherAdded = false
        levelsRGBadded = false
        var tempArray = [GPUImageOutput]()
        for item in activeItems {
            if let filter = updateFilterValues(item.type, value: item.value) {
                tempArray.append(filter)
            }
        }
        return tempArray
    }
    
    func updateFilterValues(_ filter:Int, value:(black:Float, gamma:Float, white:Float, min:Float, max:Float)) -> GPUImageOutput? {
        if filter < 7 {
            filterOperations[filter].updateBasedOnSliderValue(CGFloat(value.black))
            return filterOperations[filter].filter
        } else if filter < 12 || filter == 27 {
            //LEVELS RGB
            filterOperations[filterOperations.count-1].updateLelvelsSliderValue(0, min: CGFloat(value.black), gamma: CGFloat(value.gamma), max: CGFloat(value.white), minOut: CGFloat(value.min), maxOut: CGFloat(value.max))
            levelsItems[0] = (black:value.black, gamma:value.gamma, white:value.white, min:value.min, max:value.max)
            return filterOperations[filterOperations.count-1].filter
        } else {
            //LEVELS OTERHS
            var color:Int = 1
            switch filter {
            case 17, 18, 19, 20, 21, 29:
                color = 2
            case 22, 23, 24, 25, 26, 30:
                color = 3
            default:
                break
            }
            filterOperations[filterOperations.count-2].updateLelvelsSliderValue(color, min: CGFloat(value.black), gamma: CGFloat(value.gamma), max: CGFloat(value.white), minOut: CGFloat(value.min), maxOut: CGFloat(value.max))
            levelsItems[color] = (black:value.black, gamma:value.gamma, white:value.white, min:value.min, max:value.max)
            return filterOperations[filterOperations.count-2].filter
        }
    }
    
}

class ListItemCell:UITableViewCell {
    var typeLabel:UILabel!
    var valueLabel:UILabel!
    var id:Int?
    var value:(black:Float, gamma:Float, white:Float, min:Float, max:Float)?
    var active:Bool? {
        didSet{
            toggleSelectedStatus()
        }
    }
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = UIColor.clear
        if typeLabel == nil {
            typeLabel = UILabel(frame: CGRect(x: 20, y: 0, width: frame.size.width - 20, height: frame.size.height))
        }
        typeLabel.font = UIFont(name: "HelveticaNeue", size: 16)
        typeLabel.textColor = UIColor(red: 102/255, green: 102/255, blue: 102/255, alpha: 1.0)
        
        if valueLabel == nil {
            valueLabel = UILabel(frame: CGRect(x: 0, y: 0, width: frame.size.width - 20, height: frame.size.height))
        }
        valueLabel.textColor = UIColor(red: 102/255, green: 102/255, blue: 102/255, alpha: 0.7)
        valueLabel.font = UIFont(name: "HelveticaNeue", size: 12)
        valueLabel.textAlignment = .right
        addSubview(typeLabel)
        addSubview(valueLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    func toggleSelectedStatus() {
        if active == true {
            typeLabel.textColor = UIColor(red: 102/255, green: 102/255, blue: 102/255, alpha: 1.0)
            valueLabel.textColor = UIColor(red: 102/255, green: 102/255, blue: 102/255, alpha: 0.7)
        } else {
            typeLabel.textColor = UIColor(red: 102/255, green: 102/255, blue: 102/255, alpha: 0.5)
            valueLabel.textColor = UIColor(red: 102/255, green: 102/255, blue: 102/255, alpha: 0.35)
        }
    }
    
}
