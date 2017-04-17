//
//  AcitivityTableViewCell.swift
//  Capture
//
//  Created by Mathias Palm on 2016-06-22.
//  Copyright © 2016 capture. All rights reserved.
//

import UIKit

protocol ActivityTableViewCellDelegate {
    func userPressed(_ id: Int)
}

class AcitivityTableViewCell: UITableViewCell {

    @IBOutlet weak var taskImageView: UIImageView!
    
    @IBOutlet weak var userImageview: CircularImageView!
    
    @IBOutlet weak var taskLabel: UILabel!
    @IBOutlet weak var chopperHeight: NSLayoutConstraint!
    
    var delegate: ActivityTableViewCellDelegate?
    var userID:Int?
    var taskImage:UIImage? {
        didSet {
            if let taskImage = taskImage {
                taskImageView.image = taskImage
            }
        }
    }
    var userImgURL:String? {
        didSet {
            if let userImgURL = userImgURL {
                userImageview.loadImage(userImgURL)
            }
        }
    }
    var taskString:NSMutableAttributedString?
    
    var username:String? {
        didSet {
            if let username = username, let taskString = taskString {
                chopperHeight.constant = 1/UIScreen.main.scale
                self.layoutIfNeeded()
                let string = NSAttributedString(string: username, attributes: [NSFontAttributeName: UIFont(name: "HelveticaNeue", size: 20.0)!, NSForegroundColorAttributeName: UIColor(red: 29/255, green: 165/255, blue: 223/255, alpha: 1.0)])
                taskString.append(string)
            }
        }
    }
    var taskText:String? {
        didSet {
            if let taskText = taskText, let taskString = taskString  {
                taskString.append(NSAttributedString(string: taskText))
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = UITableViewCellSelectionStyle.none
    }
    func usertapped() {
        if let id = userID {
            delegate?.userPressed(id)
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func startText() {
        taskString = NSMutableAttributedString()
    }
    func finnishUpText() {
        
        taskLabel.attributedText = taskString
        taskLabel.sizeToFit()
    }
}
