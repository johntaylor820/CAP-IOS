//
//  MeFollowersCollectionViewCell.swift
//  Capture
//
//  Created by Mathias Palm on 2016-06-30.
//  Copyright © 2016 capture. All rights reserved.
//

import UIKit

protocol FollowersCellDelegate {
    func reportUserButtonPressed()
}

class MeFollowersCollectionViewCell: UICollectionViewCell {
    
    var delegate:FollowersCellDelegate?
    
    @IBOutlet weak var followersLabel: UILabel!
    @IBOutlet weak var followingLabel: UILabel!
    @IBOutlet weak var videosLabel: UILabel!
    
    var followers: Int? {
        didSet {
            if let followers = followers {
                followersLabel.text = "\(followers)"
            }
        }
    }
    var following: Int? {
        didSet {
            if let following = following {
                followingLabel.text = "\(following)"
            }
        }
    }
    var videos: Int? {
        didSet {
            if let videos = videos {
                videosLabel.text = "\(videos)"
            }
        }
    }
    @IBAction func reportButtonPressed(_ sender: AnyObject) {
        delegate?.reportUserButtonPressed()
    }
}
