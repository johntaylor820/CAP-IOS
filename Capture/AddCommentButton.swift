//
//  AddCommentButton.swift
//  Capture
//
//  Created by Mathias Palm on 2016-05-30.
//  Copyright © 2016 capture. All rights reserved.
//

import UIKit

class AddCommentButton: UIButton {

    var activityIndicatorView: UIActivityIndicatorView = {
        let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        activityIndicatorView.hidesWhenStopped = true
        return activityIndicatorView
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    
    fileprivate func setup() {
        imageView?.contentMode = .scaleAspectFit
        layer.cornerRadius = 4
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(activityIndicatorView)
        
        addConstraint(NSLayoutConstraint(item: activityIndicatorView, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0))
        addConstraint(NSLayoutConstraint(item: activityIndicatorView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1.0, constant: 0))
    }
    
    // MARK: - Activity indicator
    
    func startLoading() {
        isEnabled = false
        self.imageView?.alpha = 0
        if !activityIndicatorView.isAnimating {
            activityIndicatorView.startAnimating()
        }
    }
    
    func stopLoading() {
        isEnabled = true
        self.imageView?.alpha = 1
        if activityIndicatorView.isAnimating {
            activityIndicatorView.stopAnimating()
        }
    }

}
