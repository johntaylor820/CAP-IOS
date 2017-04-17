//
//  FlowLayoutWithAnimations.swift
//  Filterlapse
//
//  Created by Mathias Palm on 2015-07-29.
//  Copyright (c) 2015 Mathias Palm. All rights reserved.
//

import UIKit

class FlowLayoutWithAnimations: UICollectionViewFlowLayout {
    var indexPathsToAnimate:[IndexPath]?
    
    override init() {
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.scrollDirection = .horizontal
        self.sectionInset = UIEdgeInsetsMake(0, 5, 0, 5)
    }
    
    override func initialLayoutAttributesForAppearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        
        var attributes: UICollectionViewLayoutAttributes? =
        super.initialLayoutAttributesForAppearingItem(at: itemIndexPath)
        
        if let insertIndexPaths = indexPathsToAnimate {
            if insertIndexPaths.contains(itemIndexPath) {
                if attributes == nil {
                    attributes = layoutAttributesForItem(at: itemIndexPath)
                }
                attributes!.alpha = 0.0
            }
        }
        return attributes
        
    }
    override func finalLayoutAttributesForDisappearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let attr = self.layoutAttributesForItem(at: itemIndexPath)
        if let pat = indexPathsToAnimate {
            if pat.contains(itemIndexPath) {
                var frame = attr!.frame
                frame.origin.y = 400
                attr!.frame = frame
                indexPathsToAnimate!.remove(at: pat.index(of: itemIndexPath)!)
            }
        }
        return attr
    }
    
    override func prepare(forCollectionViewUpdates updateItems: [UICollectionViewUpdateItem]) {
        super.prepare(forCollectionViewUpdates: updateItems)
        indexPathsToAnimate = [IndexPath]()
        for updateItem in updateItems {
            switch updateItem.updateAction {
            case .delete:
                indexPathsToAnimate!.append(updateItem.indexPathBeforeUpdate!)
            case .insert:
                indexPathsToAnimate!.append(updateItem.indexPathAfterUpdate!)
            default:
                break
            }
        }
    }
    override func finalizeCollectionViewUpdates() {
        indexPathsToAnimate = nil
        super.finalizeCollectionViewUpdates()
    }
}
