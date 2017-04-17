//
//  CellAnimator.swift
//  Filterlapse
//
//  Created by Mathias on 2014-12-14.
//  Copyright (c) 2014 Mathias Palm. All rights reserved.
//

import UIKit

class CellAnimator: NSObject {
    class func animate(_ cell:UICollectionViewCell, timer:TimeInterval) {
        let screenHeight = UIScreen.main.bounds.height
        var rect = cell.frame
        let yVal = rect.origin.y
        rect.origin.y = screenHeight
        cell.frame = rect
        rect.origin.y = yVal
        UIView.animate(withDuration: 0.5, delay: timer, options: [], animations: {
            cell.frame = rect
            }, completion:nil)
    }
}
