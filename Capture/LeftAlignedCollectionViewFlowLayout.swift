//
//  LeftAlignedCollectionViewFlowLayout.swift
//  Capture
//
//  Created by Mathias Palm on 2016-09-04.
//  Copyright © 2016 capture. All rights reserved.
//

import UIKit

class LeftAlignedCollectionViewFlowLayout: UICollectionViewFlowLayout {
//    var numberOfColums = 3
//    private var lastPoints = [Int:(CGFloat, CGFloat)]()

    override init() {
        super.init()
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    fileprivate func setup() {
        sectionInset = UIEdgeInsetsMake(0, 18, 0, 18)
//        scrollDirection = .Horizontal
        minimumLineSpacing = 8
        minimumInteritemSpacing = 8
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let superArray = super.layoutAttributesForElements(in: rect) else { return nil }
        
        guard let attributes = NSArray(array: superArray, copyItems: true) as? [UICollectionViewLayoutAttributes] else { return nil }
        
//        attributes.forEach { layoutAttribute in
//            
//            if let (origin, width) = lastPoints[layoutAttribute.indexPath.row] {
//                layoutAttribute.frame.origin.x = origin + width
//            } else {
//                var newPoint = sectionInset.left
//                if let (origin, width) = lastPoints[layoutAttribute.indexPath.row - numberOfColums] {
//                    newPoint = origin + width
//                }
//                lastPoints[layoutAttribute.indexPath.row] = (newPoint, layoutAttribute.frame.width + minimumInteritemSpacing)
//                layoutAttribute.frame.origin.x = newPoint
//            }
//        }
        var leftMargin = sectionInset.left
        var maxY: CGFloat = -1.0
        attributes.forEach { layoutAttribute in
            if layoutAttribute.frame.origin.y >= maxY {
                leftMargin = sectionInset.left
            }
            
            layoutAttribute.frame.origin.x = leftMargin
            
            leftMargin += layoutAttribute.frame.width + minimumInteritemSpacing
            maxY = max(layoutAttribute.frame.maxY , maxY)
        }
        
        return attributes
    }
}
