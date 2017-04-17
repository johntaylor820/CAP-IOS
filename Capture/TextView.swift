//
//  TextView.swift
//  Capture
//
//  Created by Mathias Palm on 2016-05-30.
//  Copyright © 2016 capture. All rights reserved.
//

import UIKit

class TextView: UITextView {

    fileprivate let horizontalPadding: CGFloat = 8.0
    fileprivate let verticalPadding: CGFloat = 0.0
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    fileprivate func setup() {
        layer.cornerRadius = 4
    }
}

class CommentTextView: TextView {
    var placeholderColor: UIColor = UIColor(red: 223/255, green: 223/255, blue: 223/255, alpha: 1.0)

    let placeholderText = "Add comment"

}
class BioTextView: TextView {
    var placeholderColor: UIColor = UIColor(red: 197/255, green: 197/255, blue: 197/255, alpha: 1.0)
    var nonPlaceholderColor: UIColor =  UIColor(red: 102/255, green: 102/255, blue: 102/255, alpha: 1)
    let placeholderText = "Enter a personal bio..."
    
}
