//
//  Activity.swift
//  Capture
//
//  Created by Mathias Palm on 2016-06-27.
//  Copyright © 2016 capture. All rights reserved.
//

import UIKit

private let kAPIKeyFrom = "from_user"
private let kAPIKeyTask = "task"

enum ActivityTask {
    case follow
    case comment
    case like
}

class Activity: NSObject {
    var from: User?
    var task: ActivityTask?
    
    init(dictionary:[String:AnyObject]) {
        if let user = dictionary[kAPIKeyFrom] as? [String:AnyObject] {
            self.from = User(dictionary: user)
        }
        if let task = dictionary[kAPIKeyTask] as? String {
            switch task {
            case "follow":
                self.task = .follow
            case "like":
                self.task = .like
            case "comment":
                self.task = .comment
            default:
                break
            }
        }
    }
}
