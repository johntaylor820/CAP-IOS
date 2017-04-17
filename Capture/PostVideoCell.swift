//
//  PostVideoCell.swift
//  Capture
//
//  Created by Mathias Palm on 2016-06-30.
//  Copyright © 2016 capture. All rights reserved.
//

import UIKit
import AVFoundation

class PostVideoCell: UICollectionViewCell {
    
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var videoImageView: ImageView!
    @IBOutlet weak var playImage: ShadowImageView!
    
    var postId:Int?
    
    var delegate:FeedItemDelegate?
    var player:Player?
    var playerLayer: AVPlayerLayer?
    var playerIsShowing = false

    var thumb:UIImage? {
        didSet {
            videoImageView.alpha = 1
            playImage.alpha = 1
            if let thumb = thumb {
                videoImageView.image = thumb
            }
        }
    }
    
    func loadThumbFromString(_ stringUrl: String) {
        videoImageView.loadImage(stringUrl)
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
            }, completion:nil)
    }
}
extension PostVideoCell: PlayerDelegate {
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
