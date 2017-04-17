//
//  FeedItem.swift
//  Capture
//
//  Created by Mathias Palm on 2016-04-10.
//  Copyright © 2016 capture. All rights reserved.
//

import UIKit
import AVFoundation
import Haneke

protocol FeedItemDelegate {
    func userPressed(_ id:Int)
}

class FeedItem: UICollectionViewCell {
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var videoImageView: ImageView!
    @IBOutlet weak var playImage: ShadowImageView!
    @IBOutlet weak var userImageView: CircularImageViewWithOutBorder!
    @IBOutlet weak var nameButton: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var timeAndLocationLabel: ShadowLabel!
    @IBOutlet weak var chopperHeight: NSLayoutConstraint!
    
    var postId:Int?
    var userId:Int?
    var isUser = false {
        didSet {
            if isUser {
                isUserImageView.isHidden = true
            } else {
                isUserImageView.isHidden = true
            }
        }
    }
    
    
    var delegate:FeedItemDelegate?
    var player:Player?
    var playerLayer: AVPlayerLayer?
    var playerIsShowing = false

    @IBOutlet weak var isUserImageView: UIImageView!
    
    @IBOutlet weak var timeAndLocationConstraint: NSLayoutConstraint!
    @IBOutlet weak var nameWidthConstraint: NSLayoutConstraint!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        chopperHeight.constant = 1/UIScreen.main.scale
        layoutIfNeeded()
    }
    var thumb:String? {
        didSet {
            videoImageView.alpha = 1
            if let thumb = thumb {
                videoImageView.loadImage(thumb)
            }
        }
    }
    var image: String? {
        didSet {
            if let imgUrl = image {
                let tap = UITapGestureRecognizer(target: self, action: #selector(userPressed))
                userImageView.addGestureRecognizer(tap)
                userImageView.loadImage(imgUrl)
            }
        }
    }
    var name: String? {
        didSet {
            if let name = name {
                nameButton.setTitle(name, for: UIControlState())
                var width = name.widthWithConstrainedHeight(nameButton.frame.height, font: UIFont(name: "HelveticaNeue-Bold", size: 18)!)
                if width > 200 {
                    width = 200
                }
                nameWidthConstraint.constant = width
                self.layoutIfNeeded()
            }
        }
    }
    
    @IBAction func usernamePressed(_ sender: AnyObject) {
        userPressed()
    }
    func userPressed() {
        if let id = userId {
            delegate?.userPressed(id)
        }
    }

    var username: String? {
        didSet {
            if let username = username {
                nameLabel.text = "@\(username)"
            }
        }
    }
    func setupTimeAndLocation(_ date:Date?, location:String?) {
        var text = NSMutableAttributedString(string: "")
        if let date = date {
            text = NSMutableAttributedString(string: date.getElapsedInterval())
        }
        if let location = location {
            if location.characters.count > 0 {
                let attachment = NSTextAttachment()
                attachment.image = UIImage(named: "locationdotfeed")
                text.append(NSAttributedString(attachment: attachment))
                text.append(NSMutableAttributedString(string: location))
                timeAndLocationConstraint.constant = 0
                layoutIfNeeded()
            }
        }
        timeAndLocationLabel.attributedText = text
    }
    func setupPlayer(_ file: String) {
        let item = MPCacher.sharedInstance.getObjectForKey(file) as? Player
        if let item = item {
            setup(item)
        }
    }
    fileprivate func setup(_ player: Player) {
        if self.player != player {
            self.player = player
            self.player?.delegate = self
            setupLayer(player)
        }
    }
    
    fileprivate func setupLayer(_ player: Player) {
        playerLayer?.removeFromSuperlayer()
        playerLayer = AVPlayerLayer(player: player)
        if let playerLayer = playerLayer {
            playerLayer.frame = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.width)
            playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
            videoView.layer.addSublayer(playerLayer)
            self.playImage.layer.zPosition = 1000

        }
    }
    
    func play() {
        playerIsShowing = true
        if let player = player {
            if player.rate > 0 {
                pause()
            } else {
                player.pushPlay()
            }
        }
    }
    
    func pause() {
        playerIsShowing = false
        if let player = player {
            player.pushPause()
        }
        self.playImage.alpha = 1
    }
    func animteHideImages() {
        UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseOut, animations: {
            self.videoImageView.alpha = 0
            self.playImage.alpha = 0
            }, completion: nil)
    }
}
extension FeedItem: PlayerDelegate {
    func playbackLikelyToKeepUp() {
        if let player = player , playerIsShowing && player.rate == 0 {
            player.play()
            animteHideImages()
        }
    }
    func didPlayToEnd() {
        pause()
    }
}
