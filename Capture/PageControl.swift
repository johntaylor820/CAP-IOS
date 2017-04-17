//
//  PageControl.swift
//  Capture
//
//  Created by Mathias Palm on 2016-07-14.
//  Copyright © 2016 capture. All rights reserved.
//

import UIKit

class PageControl: UIPageControl {

    var activeImage: UIImage!
    var inactiveImage: UIImage!
    var dotSize:CGSize?
    override var currentPage: Int {
        didSet {
            self.updateDots()
        }
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.pageIndicatorTintColor = UIColor.clear
        self.currentPageIndicatorTintColor = UIColor.clear
        setPageImages()
    }
    func setPageImages() {
        activeImage = UIImage(named: "introactive")!
        inactiveImage = UIImage(named: "introdeactive")!
        dotSize = CGSize(width: 32, height: 32)
    }
    
    func updateDots() {
        if let dotSize = dotSize {
            for i in 0 ..< subviews.count {
                let view: UIView = subviews[i]
                if view.subviews.count == 0 {
                    self.addImageViewOnDotView(view, imageSize: dotSize)
                }
                let imageView: UIImageView = view.subviews.first as! UIImageView
                imageView.image = self.currentPage == i ? activeImage : inactiveImage
            }
        }
    }
    
    // MARK: - Private
    
    func addImageViewOnDotView(_ view: UIView, imageSize: CGSize) {
        var frame = view.frame
        frame.origin = CGPoint.zero
        frame.size = imageSize
        frame.size.height /= 3
        frame.size.width /= 3
        let imageView = UIImageView(frame: frame)
        imageView.contentMode = .scaleAspectFit
        view.addSubview(imageView)
    }
}
class WhitePageControl: PageControl {
    override func setPageImages() {
        activeImage = UIImage(named: "active-page")!
        inactiveImage = UIImage(named: "inactive-page")!
        dotSize = CGSize(width: 22, height: 22)
    }
}
