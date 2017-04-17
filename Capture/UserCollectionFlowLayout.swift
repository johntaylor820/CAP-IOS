//
//  UserCollectionFlowLayout.swift
//  Capture
//
//  Created by Mathias Palm on 2016-06-30.
//  Copyright © 2016 capture. All rights reserved.
//

import UIKit
import GPUImage

class UserCollectionFlowLayout: UICollectionViewFlowLayout {
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let layoutAttributes = super.layoutAttributesForElements(in: rect)
        if let layoutAttributes = layoutAttributes {
            let insets = collectionView!.contentInset
            let offset = collectionView!.contentOffset
            let minY = -insets.top
            if (offset.y < minY) {
                let deltaY = fabs(offset.y - minY)
                for attributes in layoutAttributes {
                    if let elementKind = attributes.representedElementKind {
                        if elementKind == UICollectionElementKindSectionHeader {
                            var frame = attributes.frame
                            for subview in collectionView!.subviews {
                                if subview.isKind(of: MeHeaderCollectionReusableView.self) {
                                    for view in subview.subviews {
                                        if let v = view as? BackgroundImageView {
                                            let calc = deltaY / -16.5 + 7.8
                                            v.changeBluriness(calc)
                                        }
                                        if view.isKind(of: UIView.self) && view.tag != 1931 {
                                            let alpha = (100.5 - deltaY) / 100
                                            for v in view.subviews {
                                                if !(v is GPUImageView) && v.tag != 1931 {
                                                    v.alpha = alpha
                                                }
                                            }
                                            continue
                                        }
                                        continue
                                    }
                                    continue
                                }
                            }
                            frame.size.height = max(minY, headerReferenceSize.height + deltaY)
                            frame.origin.y = frame.minY - deltaY
                            attributes.frame = frame
                        }
                    }
                }
            }
        }
        return layoutAttributes
    }
}
