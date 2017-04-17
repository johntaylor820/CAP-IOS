//
//  LoopingPlayer.swift
//  Capture
//
//  Created by Mathias Palm on 2016-03-28.
//  Copyright © 2016 capture. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation


class LoopingPlayer: VideoPlayer {
    override func commonInit() {
        self.actionAtItemEnd = .none
        NotificationCenter.default.addObserver(self, selector:#selector(LoopingPlayer.restartVideoFromBeginning), name:NSNotification.Name.AVPlayerItemDidPlayToEndTime, object:nil)
        //self.addObserver(self, forKeyPath: "rate", options: NSKeyValueObservingOptions(), context: nil)
    }
    override func restartVideoFromBeginning()  {
        let seconds : Int64 = 0
        let preferredTimeScale : Int32 = 1
        let seekTime : CMTime = CMTimeMake(seconds, preferredTimeScale)
        self.seek(to: seekTime)
        self.play()
    }
}















