//
//  Music.swift
//  Capture
//
//  Created by Mathias Palm on 2016-06-28.
//  Copyright © 2016 capture. All rights reserved.
//

import UIKit

private let kName = "name"
private let kImage = "image"
private let kSong = "song"


class Music: NSObject {
    
    var name = ""
    var image: UIImage?
    var song = ""
    
    
    init(dictionary:[String:AnyObject]) {
        if let name = dictionary[kName] as? String {
            self.name = name
        }
        if let image = dictionary[kImage] as? String {
            self.image = UIImage(named: image)
        }
        if let song = dictionary[kSong] as? String {
            self.song = song
        }
    }
}
