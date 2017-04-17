//
//  TextItem.swift
//  Capture
//
//  Created by Mathias Palm on 2016-04-10.
//  Copyright © 2016 capture. All rights reserved.
//

import UIKit

protocol TextItemDelegate {
    func userByUserName(_ name: String)
}

class TextItem: UICollectionViewCell {
    
    var delegate: TextItemDelegate?
    @IBOutlet weak var postTextLabel: ActiveLabel!
    @IBOutlet weak var chopperHeight: NSLayoutConstraint!
    @IBOutlet weak var chopperHeightBottom: NSLayoutConstraint!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        chopperHeightBottom.constant = 1/UIScreen.main.scale
        chopperHeight.constant = 1/UIScreen.main.scale
        layoutIfNeeded()
    }
    
    func setPostLabel(_ text:String) {
        if text.characters.count > 0 {
            postTextLabel.text = text
            postTextLabel.numberOfLines = 0
            postTextLabel.lineSpacing = 0
            
            postTextLabel.handleMentionTap { self.alert("Mention", message: $0) }
            postTextLabel.handleHashtagTap { self.alert("Hashtag", message: $0) }
            postTextLabel.handleURLTap { self.alert("URL", message: $0.description) }
        } else {
            postTextLabel.text = " "
        }
        
    }
    
    func alert(_ title: String, message: String) {
        if title == "Mention" {
            delegate?.userByUserName(message)
        }
    }
}
