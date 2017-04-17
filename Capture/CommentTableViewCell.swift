//
//  CommentTableViewCell.swift
//  Capture
//
//  Created by Mathias Palm on 2016-06-02.
//  Copyright © 2016 capture. All rights reserved.
//

import UIKit

protocol CommentTableViewCellDelegate {
    func userPressed(_ id: Int)
}

class CommentTableViewCell: UITableViewCell {
    
    @IBOutlet weak var profileImageView: CircularImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var commentLabel: CommentLabel!
    var commentId: Int?
    var userID: Int?
    var delegate: CommentTableViewCellDelegate?

    @IBOutlet weak var chopperHeight: NSLayoutConstraint!
    var imgURL:String? {
        didSet {
            if let imgURL = imgURL {
                profileImageView.loadImage(imgURL)
            }
        }
    }
    
    var name:String? {
        didSet {
            if let name = name {
                usernameLabel.text = name
            }
        }
    }
    
    var comment:String? {
        didSet {
            if let comment = comment {
                chopperHeight.constant = 1/UIScreen.main.scale
                self.layoutIfNeeded()
                commentLabel.text = comment
                commentLabel.sizeToFit()
            }
        }
    }
    var dateString: String?
    var date: Date? {
        didSet {
            if let date = date {
                dateString = date.getElapsedInterval()
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = UITableViewCellSelectionStyle.none

        // Initialization code
    }


    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }

}

class CommentLabel: ActiveLabel {
    override func drawText(in rect: CGRect) {
        let insets: UIEdgeInsets = UIEdgeInsets(top: -5.0, left: 0.0, bottom: -5.0, right: 0.0)
        super.drawText(in: UIEdgeInsetsInsetRect(rect, insets))
        
    }
}
