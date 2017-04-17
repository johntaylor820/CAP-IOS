//
//  Tag.swift
//  Capture
//
//  Created by Mathias Palm on 2016-06-14.
//  Copyright © 2016 capture. All rights reserved.
//

import UIKit

private let kAPIKeyName = "name"
private let kAPIKeyPost = "posts"
private let ApiKeyExplorerImg = "explorer_header_img"

class Tag: Equatable {

    var name = ""
    var postid: Int?
    var tagimage = ""
    var width: CGFloat = 0.0
    lazy var label: UILabel = {
        let l = UILabel()
        if let font = UIFont.init(name: "HelveticaNeue", size: 16) {
            l.font = font
        }
        return l
    }()
    
    init(dictionary:[String:AnyObject]) {
        if let name = dictionary[kAPIKeyName] as? String {
            self.name = name
            width = {
                label.text = name
                label.sizeToFit()
                return label.bounds.width
            }()
        }
        if let postid = dictionary[kAPIKeyPost] as? Int {
            self.postid = postid
        }
        if let tagimage = dictionary[ApiKeyExplorerImg] as? String{
            self.tagimage = tagimage
        }
    }
}
func == (lhs: Tag, rhs: Tag) -> Bool {
    return lhs.name == rhs.name
}
