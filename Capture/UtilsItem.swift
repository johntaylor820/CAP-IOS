//
//  UtilsItem.swift
//  Capture
//
//  Created by Mathias Palm on 2016-04-10.
//  Copyright © 2016 capture. All rights reserved.
//

import UIKit
protocol UtilsItemDelegate {
    func reportButtonPressed(_ postId: Int)
    func commentButtonPressed(_ postId: Int)
    func isUserDeletePostPressed(_ postId: Int)
}

class UtilsItem: UICollectionViewCell {
    
    var delegate: UtilsItemDelegate?
    
    @IBOutlet weak var likesButton: UIButton!
    @IBOutlet weak var numberLikesButton: UIButton!
    @IBOutlet weak var numberCommentsButton: UIButton!
    @IBOutlet weak var reportButton: UIButton!
    
    @IBOutlet weak var commentImageView: UIImageView!
    @IBOutlet weak var likesWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var commentWidthConstraint: NSLayoutConstraint!
    var postId: Int?
    
    let addLike = UIImage(named: "addlike")
    let liked = UIImage(named: "like")
    
    var isUser = false {
        didSet {
            if isUser {
                reportButton.setImage(UIImage(named: "delete"), for: UIControlState())
            } else {
                reportButton.setImage(UIImage(named:"report"), for: UIControlState())
            }
        }
    }
    
    var userLikes = false {
        didSet {
            if userLikes {
                self.likesButton.setImage(self.liked, for: UIControlState())
                self.likesButton.alpha = 0
                UIView.animate(withDuration: 0.2, animations:  {
                    self.likesButton.alpha = 1
                })
            } else {
                self.likesButton.setImage(self.addLike, for: UIControlState())
            }
        }
    }
    
    var likes: Int = 0 {
        didSet {
            let likesAsString = "\(likes)"
            numberLikesButton.setTitle(likesAsString, for: UIControlState())
            var width = likesAsString.widthWithConstrainedHeight(numberLikesButton.frame.height, font: UIFont(name: "Helvetica-Bold", size: 18)!) + 10
            if width > 100 {
                width = 100
            }
            likesWidthConstraint.constant = width
            self.layoutIfNeeded()
        }
    }
    var comments: Int = 0 {
        didSet {
            let tap = UITapGestureRecognizer(target: self, action: #selector(commentButtonPressed(_:)))
            commentImageView.addGestureRecognizer(tap)
            let commentsAsString = "\(comments)"
            numberCommentsButton.setTitle(commentsAsString, for: UIControlState())
            var width = commentsAsString.widthWithConstrainedHeight(numberCommentsButton.frame.height, font: UIFont(name: "Helvetica-Bold", size: 18)!) + 10
            if width > 100 {
                width = 100
            }
            commentWidthConstraint.constant = width
            self.layoutIfNeeded()
        }
    }
    @IBAction func likeButtonPressed(_ sender: AnyObject) {
        UIView.animate(withDuration: 0.2 , animations: {
            self.likesButton.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
            }, completion: { finish in
                UIView.animate(withDuration: 0.2, animations: {
                    self.likesButton.transform = CGAffineTransform.identity
                })
        })
        
        if let postId = postId {
            if !userLikes {
                setLiked()
                //likesButton.setActive()
                FeedManager.sharedInstance.likePost(postId, completion: {success, error in
                    if !success {
                        self.setUnLiked()
                    }
                })
            } else {
                setUnLiked()
                //likesButton.setDeactive()
                FeedManager.sharedInstance.deleteLike(postId, completion: {success, error in
                    if !success {
                        self.setLiked()
                    }
                })
            }
        }
    }
    @IBAction func reportButtonPressed(_ sender: UIButton) {
        if let postId = postId {
            if isUser  {
                delegate?.isUserDeletePostPressed(postId)
            } else {
                    delegate?.reportButtonPressed(postId)
            }
        }
    }
    
    func setLiked() {
        self.userLikes = true
        self.likes += 1
    }
    func setUnLiked() {
        self.userLikes = false
        self.likes -= 1
    }
    
    @IBAction func commentButtonPressed(_ sender: AnyObject) {
        if let postId = postId {
            delegate?.commentButtonPressed(postId)
        }
    }
}
