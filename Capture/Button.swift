//
//  Button.swift
//  Capture
//
//  Created by Mathias Palm on 2016-06-23.
//  Copyright © 2016 capture. All rights reserved.
//

import UIKit

class Button: UIButton {
    
    var activityIndicatorView: UIActivityIndicatorView = {
        let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        activityIndicatorView.hidesWhenStopped = true
        return activityIndicatorView
    }()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        imageView?.contentMode = .scaleAspectFit
        
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(activityIndicatorView)
        
        addConstraint(NSLayoutConstraint(item: activityIndicatorView, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0))
        addConstraint(NSLayoutConstraint(item: activityIndicatorView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1.0, constant: 0))
        setup()
    }
    func setup() {
        
    }

    func startLoading() {
        isEnabled = false
        setTitleColor(UIColor(red: 29/255, green: 168/255, blue: 224/255, alpha: 0.6), for: UIControlState())
        if !activityIndicatorView.isAnimating {
            activityIndicatorView.startAnimating()
        }
    }
    
    func stopLoading() {
        isEnabled = true
        setTitleColor(UIColor(red: 29/255, green: 168/255, blue: 224/255, alpha: 1.0), for: UIControlState())
        if activityIndicatorView.isAnimating {
            activityIndicatorView.stopAnimating()
        }
    }
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
class FillButton: UIButton {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        imageView?.contentMode = .scaleAspectFill
    }
}
class RoundButton: UIButton {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        imageView?.contentMode = .scaleAspectFill
        
        layer.borderWidth = 2.0
        layer.borderColor = UIColor.white.cgColor
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.width/2.0
    }
}
class LikeButton: Button {
    let rectShape = CAShapeLayer()
    
    func setActive() {
        // fill with yellow
        let bounds = CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.width)
        
        // Create CAShapeLayerS
        rectShape.bounds = bounds
        rectShape.position = center
        rectShape.cornerRadius = bounds.width / 2
        layer.addSublayer(rectShape)
        
        // Apply effects here
        
        // fill with yellow
        rectShape.fillColor = UIColor.yellow.cgColor
        
        // 1
        // begin with a circle with a 50 points radius
        let startShape = UIBezierPath(roundedRect: bounds, cornerRadius: 50).cgPath
        // animation end with a large circle with 500 points radius
        let endShape = UIBezierPath(roundedRect: CGRect(x: -30, y: -30, width: frame.size.width, height: frame.size.height), cornerRadius: frame.size.width/2).cgPath
        
        // set initial shape
        rectShape.path = startShape
        
        // 2
        // animate the `path`
        let animation = CABasicAnimation(keyPath: "path")
        animation.toValue = endShape
        animation.duration = 0.2 // duration is 1 sec
        // 3
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut) // animation curve is Ease Out
        animation.fillMode = kCAFillModeBoth // keep to value after finishing
        animation.isRemovedOnCompletion = false // don't remove after finishing
        // 4
        rectShape.add(animation, forKey: animation.keyPath)
    }
    func setDeactive() {
        rectShape.removeFromSuperlayer()
    }
}


class SignUpButton: Button {
    override func setup() {
        layer.cornerRadius = 6.0
        layer.borderWidth = 1.0
        layer.borderColor = titleLabel?.textColor.cgColor
    }
}

class ResetPasswordButton: Button {

    override func setup() {
        layer.cornerRadius = 6.0
        layer.borderWidth = 1.0
        layer.borderColor = UIColor(red: 29/255, green: 168/255, blue: 224/255, alpha: 1.0).cgColor
    }
}

class OvalButton: Button {
    
    override func setup() {
        layer.cornerRadius = 5.0
    }
}
