//
//  VideoPlayer.swift
//  Capture
//
//  Created by Mathias Palm on 2016-06-15.
//  Copyright © 2016 capture. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

protocol VideoPlayerAtEndDelegate {
    func videoDidCompletePlaying()
}

class VideoPlayer: AVPlayer {
    var delegate: VideoPlayerAtEndDelegate?
    var shouldPlay = false
    override init(url: URL) {
        super.init(url: url)
        self.commonInit()
    }
    override init(playerItem item: AVPlayerItem?) {
        super.init(playerItem: item)
        self.commonInit()
    }
    override init() {
        super.init()
        commonInit()
    }
    func commonInit() {
        actionAtItemEnd = .none
        isMuted = false
        NotificationCenter.default.addObserver(self, selector:#selector(VideoPlayer.isAtEnd), name:NSNotification.Name.AVPlayerItemDidPlayToEndTime, object:nil)
        //self.addObserver(self, forKeyPath: "rate", options: NSKeyValueObservingOptions(), context: nil)
    }
    var quedKVO = false
    func queStartPlay() {
        quedKVO = true
        self.addObserver(self, forKeyPath: "AVPlayerStatusReadyToPlay", options: NSKeyValueObservingOptions(), context: nil)
    }
    func isAtEnd() {
        delegate?.videoDidCompletePlaying()
        restartVideoFromBeginning()
    }
    func restartVideoFromBeginning()  {
        let seconds : Int64 = 0
        let preferredTimeScale : Int32 = 1
        let seekTime : CMTime = CMTimeMake(seconds, preferredTimeScale)
        self.seek(to: seekTime)
    }
//    func deallocObservers() {
//        if quedKVO {
//            quedKVO = false
//            self.removeObserver(self, forKeyPath: "AVPlayerStatusReadyToPlay")
//        }
//        //self.removeObserver(self, forKeyPath: "rate")
//        NotificationCenter.default.removeObserver(NSNotification.Name.AVPlayerItemDidPlayToEndTime)
//    }
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let key = keyPath {
            if key == "rate" {
                if let item = self.currentItem {
                    if self.rate == 0 && CMTimeGetSeconds(item.duration) != CMTimeGetSeconds(item.currentTime()) && shouldPlay {
                        continuePlaying()
                    }
                }
            } else if key == "AVPlayerStatusReadyToPlay" {
                if shouldPlay {
                    if quedKVO {
                        quedKVO = false
                        self.removeObserver(self, forKeyPath: "AVPlayerStatusReadyToPlay")
                    }
                    continuePlaying()
                }
            }
        }
    }
    var tryies = 0
    func continuePlaying() {
        if let item = self.currentItem {
            if item.isPlaybackLikelyToKeepUp {
                self.play()
            } else {
                tryies += 1
                if tryies < 11 {
                    continuePlaying()
                } else {
                    self.play()
                }
            }
        }
    }
}
