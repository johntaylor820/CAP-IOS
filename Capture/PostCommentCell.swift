//
//  PostCommentCell.swift
//  Capture
//
//  Created by Mathias Palm on 2016-06-30.
//  Copyright © 2016 capture. All rights reserved.
//

import UIKit

class PostCommentCell: UICollectionViewCell {
    
    @IBOutlet weak var postCommentLabel: ActiveLabel!
    var userID: Int?
    var activeComment:String?
    
    var name:String? {
        didSet {
            if let name = name {
                activeComment = "@\(name)"
            }
        }
    }
    
    var comment:String? {
        didSet {
            if let comment = comment, let activeComment = activeComment {
                self.activeComment = "\(activeComment) \(comment)"
            }
        }
    }
    
    func finnishComment() {
        if let activeComment = activeComment {
            postCommentLabel.shouldShowAt = false
            postCommentLabel.text = activeComment
            postCommentLabel.numberOfLines = 0
            postCommentLabel.lineSpacing = 0
            
            postCommentLabel.handleMentionTap { self.alert("Mention", message: $0) }
            postCommentLabel.handleHashtagTap { self.alert("Hashtag", message: $0) }
            postCommentLabel.handleURLTap { self.alert("URL", message: $0.description) }
            self.layoutIfNeeded()
        }
    }
    
    func alert(_ title: String, message: String) {
        print(message)
    }
}
