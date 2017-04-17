//
//  Player.swift
//  Capture
//
//  Created by Mathias Palm on 2016-08-16.
//  Copyright © 2016 capture. All rights reserved.
//

import AVFoundation

protocol PlayerDelegate {
    func playbackLikelyToKeepUp()
    func didPlayToEnd()
}

open class Player: AVPlayer {
    var delegate: PlayerDelegate?
    
    var shouldReact = false
    var key = ""
    
    override init(url: URL) {
        super.init(url: url)
        self.setup()
    }
    
    override init(playerItem item: AVPlayerItem?) {
        super.init(playerItem: item)
        self.setup()
    }
    
    override init() {
        super.init()
        self.setup()
    }
    
    func setup() {
        isMuted = false
        if let currentItem = currentItem {
            currentItem.addObserver(self, forKeyPath: "playbackLikelyToKeepUp", options: NSKeyValueObservingOptions(), context: nil)
            currentItem.addObserver(self, forKeyPath: "status", options: NSKeyValueObservingOptions(), context: nil)
        }
    }
    
    deinit {
        if let currentItem = currentItem {
            currentItem.removeObserver(self, forKeyPath: "playbackLikelyToKeepUp")
            currentItem.removeObserver(self, forKeyPath: "status")
        }
    }
    
    override open func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let key = keyPath {
            if key == "playbackLikelyToKeepUp" || key == "status" {
                if let currentItem = currentItem {
                    let duration = currentItem.duration
                    let currentTime = currentItem.currentTime()
                    if duration == currentTime {
                        restartFromBeginning()
                    } else {
                        testKeepUp()
                    }
                }
            }
        }
    }
    func pushPlay() {
        shouldReact = true
        testKeepUp()
    }
    func pushPause() {
        shouldReact = false
        pause()
    }
    func restartFromBeginning()  {
        let seekTime: CMTime = CMTimeMake(0, 1)
        seek(to: seekTime)
        delegate?.didPlayToEnd()
    }
    func testKeepUp() {
        if let currentItem = currentItem , currentItem.isPlaybackLikelyToKeepUp && currentItem.status == .readyToPlay {
            if shouldReact {
                delegate?.playbackLikelyToKeepUp()
            }
        }
    }
}

