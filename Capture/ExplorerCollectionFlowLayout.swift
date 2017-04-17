//
//  ExplorerCollectionFlowLayout.swift
//  Capture
//
//  Created by Mathias Palm on 2016-09-11.
//  Copyright © 2016 capture. All rights reserved.
//

import UIKit

class ExplorerCollectionFlowLayout: UICollectionViewFlowLayout {
    override init() {
        super.init()
        setup()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
    
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let layoutAttributes = super.layoutAttributesForElements(in: rect)
        if let layoutAttributes = layoutAttributes {
            let height = collectionView!.contentSize.height - footerReferenceSize.height
            let offset = collectionView!.contentOffset
            if (offset.y > height) {
                let deltaY = fabs(offset.y - height)
                for attributes in layoutAttributes {
                    if let elementKind = attributes.representedElementKind {
                        if elementKind == UICollectionElementKindSectionFooter {
                            var frame = attributes.frame
                            frame.size.height = max(footerReferenceSize.height, footerReferenceSize.height + deltaY)
                            attributes.frame = frame
                        }
                    }
                }
            }
        }
        return layoutAttributes
    }
}
