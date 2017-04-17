//
//  MusicButton.swift
//  Capture
//
//  Created by Mathias Palm on 2016-06-28.
//  Copyright © 2016 capture. All rights reserved.
//

import UIKit

class MusicButton: UIButton {

    var selectView = UIView()
    
    let selectedColor = UIColor(red: 3/255, green: 167/255, blue: 227/255, alpha: 1.0)
    let color = UIColor.white
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        imageView?.contentMode = .scaleAspectFill
        if isSelected {
            selectView.backgroundColor = selectedColor
        } else {
            selectView.backgroundColor = color
        }
        self.addSubview(selectView)
        let frame = imageView?.frame
        if let frame = frame, let title = titleLabel {
            imageEdgeInsets = UIEdgeInsets(top: 0, left: frame.size.width/2, bottom: 0, right: 0)
            titleEdgeInsets = UIEdgeInsets(top: frame.size.height+6, left: -frame.size.width, bottom: 0, right: 0)
            title.sizeToFit()
        }
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        selectView.frame = CGRect(x: 0, y: frame.size.height-3, width: frame.size.width, height: 3)

    }
    override var isSelected: Bool {
        didSet {
            if isSelected {
                selectView.backgroundColor = selectedColor
            } else {
                selectView.backgroundColor = color
            }
        }
    }
}
