//
//  NotificationView.swift
//  Capture
//
//  Created by Mathias Palm on 2016-07-08.
//  Copyright © 2016 capture. All rights reserved.
//

import UIKit

class NotificationView: UIView {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    func setup() {
        layer.cornerRadius = 6
    }
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
class NetworkNotificationView: UIView {
    
    var label:UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "HelveticaNeue-Light",size: 20)
        label.textColor = UIColor.white
        label.text = "We could not connect to your network"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var image:UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "addcommentbutton")
        view.translatesAutoresizingMaskIntoConstraints = false
        return view 
    }()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    func setup() {
        layer.cornerRadius = 6
        backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.8)
        label.sizeToFit()
        addSubview(label)
        addSubview(image)
        
        let leading = NSLayoutConstraint(item: image, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: 25)
        let centerY = NSLayoutConstraint(item: self, attribute: .centerY, relatedBy: .equal, toItem: image, attribute: .centerY, multiplier: 1.0, constant: 4)
        let height = NSLayoutConstraint(item: image, attribute: .height, relatedBy: .equal, toItem: self, attribute: .height, multiplier: 0.45, constant: 0)
        let ratio = NSLayoutConstraint(item: image, attribute: .width, relatedBy: .equal, toItem: image, attribute: .height, multiplier: 1.0, constant: 0)
        addConstraints([ratio,height,centerY,leading])
        
        let labelTrailing = NSLayoutConstraint(item: label, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1.0, constant: 25)
        let labelLeading = NSLayoutConstraint(item: label, attribute: .leading, relatedBy: .equal, toItem: image, attribute: .trailing, multiplier: 1.0, constant: 10)
        let labelCenterY = NSLayoutConstraint(item: label, attribute: .centerY, relatedBy: .equal, toItem: image, attribute: .centerY, multiplier: 1.0, constant: 0)
        addConstraints([labelTrailing,labelCenterY,labelLeading])
        layoutIfNeeded()
        
    }
}
