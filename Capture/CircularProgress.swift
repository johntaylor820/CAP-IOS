//
//  ViewController.swift
//  Filterlapse
//
//  Created by Mathias on 2014-09-12.
//  Copyright (c) 2014 Mathias Palm. All rights reserved.
//

import Foundation
import UIKit

// MARK: - CircularProgress
class CircularProgress: UIView {
    typealias progressChangedHandler = (_ progress: Double, _ circularView: CircularProgress) -> ()
    var progressChangedClosure: progressChangedHandler?
    var progressView: circularShapeView!
    var gradientLayer: CAGradientLayer!
    var progress: Double = 0.0 {
        didSet(newValue) {
            let clipProgress = max( min(newValue, 1.0), 0.0)
            self.progressView.updateProgress(clipProgress)
            
            if let progressChanged = progressChangedClosure {
                progressChanged(clipProgress, self)
            }
        }
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    func setup() {
        self.progressView = circularShapeView(frame: self.bounds)
        self.progressView.shapeLayer().fillColor = UIColor.clear.cgColor
        self.progressView.shapeLayer().lineWidth = 6.0
        
        gradientLayer = CAGradientLayer(layer: layer)
        gradientLayer.frame = self.progressView.frame
        gradientLayer.mask = self.progressView.shapeLayer();
        let c = UIColor.white.cgColor
        gradientLayer.colors = [c, c]
        
        self.layer.addSublayer(gradientLayer)
        self.progressView.shapeLayer().strokeColor = c
    }
    
    func progressChangedBlock(_ completion: @escaping progressChangedHandler) {
        progressChangedClosure = completion
    }
}

// MARK: - CircularShapeView
class circularShapeView: UIView {
    var startAngle = -1.57079633
    var endAngle = -1.57079633
    
    override class var layerClass : AnyClass {
        return CAShapeLayer.self
    }
    
    func shapeLayer() -> CAShapeLayer {
        return self.layer as! CAShapeLayer
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.updateProgress(0)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if self.startAngle == self.endAngle {
            self.endAngle = self.startAngle + M_PI * 2
        }
        self.shapeLayer().path = self.shapeLayer().path ?? self.layoutPath().cgPath
    }
    
    func layoutPath() -> UIBezierPath {
        let halfWidth = CGFloat(self.frame.size.width / 2.0)
        return UIBezierPath(arcCenter: CGPoint(x: halfWidth, y: halfWidth), radius: halfWidth - self.shapeLayer().lineWidth, startAngle: CGFloat(self.startAngle), endAngle: CGFloat(self.endAngle), clockwise: true)
    }
    
    func updateProgress(_ progress: Double) {
        CATransaction.begin()
        CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
        self.shapeLayer().strokeEnd = CGFloat(progress)
        CATransaction.commit()
    }
}
