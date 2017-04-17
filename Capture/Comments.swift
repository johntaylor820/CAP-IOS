//
//  Comments.swift
//  Capture
//
//  Created by Mathias Palm on 2016-06-14.
//  Copyright © 2016 capture. All rights reserved.
//

import AVFoundation

private let kAPIKeyId = "id"
private let kAPIKeyUser = "user"
private let kAPIKeyText = "text"
private let kAPIKeyDate = "date"

class Comments: Equatable {
    var id: Int = 0
    var user: User?
    var text: String = ""
    var date: Date?
    
    
    init(dictionary:[String:AnyObject]) {
        if let id = dictionary[kAPIKeyId] as? Int {
            self.id = id
        }
        if let postText = dictionary[kAPIKeyText] as? String {
            self.text = postText
        }
        if let date = dictionary[kAPIKeyDate] as? String {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
            if let parsedDateTimeString = dateFormatter.date(from: date) {
                self.date = parsedDateTimeString
            }
        }
        if let user = dictionary[kAPIKeyUser] as? [String:AnyObject] {
            self.user = User(dictionary: user)
        }
    }
}
func == (lhs: Comments, rhs: Comments) -> Bool {
    return lhs.id == rhs.id
}
