//
//  Posts.swift
//  Capture
//
//  Created by Mathias Palm on 2016-05-27.
//  Copyright © 2016 capture. All rights reserved.
//

import AVFoundation
import Haneke

private let kAPIKeyId = "id"
private let kAPIKeyVideo = "video"
private let kAPIKeyUser = "user"
private let kAPIKeyVideoThumb = "thumb"
private let kAPIKeyUserLikes = "user_like"
private let kAPIKeyPostsText = "text"
private let kAPIKeyPostsLikes = "likes"
private let kAPIKeyPostsComments = "comments"
private let kAPIKeyDate = "date"
private let kAPIKeyLocation = "location"


class Posts: Equatable {
    var id: Int = 0
    var file: String?
    var videoThumb = ""
    var userLikes = false
    var postText = ""
    var date: Date?
    var location = ""
    var likesCount: Int = 0
    var commentCount: Int = 0
    var user: User?
    
    init(dictionary:[String:AnyObject]) {
        let plistName = "Capture_API"
        let infoDict = Bundle.main.object(forInfoDictionaryKey: plistName) as! NSDictionary
        let isDev = infoDict["is-dev"] as! Bool
        if let id = dictionary[kAPIKeyId] as? Int {
            self.id = id
        }
        if let file = dictionary[kAPIKeyVideo] as? String {
            if let url = URL(string: file) {
                self.file = file
                let item = AVPlayerItem(url: url)
                let player = Player(playerItem: item)
                player.key = file
                MPCacher.sharedInstance.setObjectForKey(player, key: file)
            }
            
        }
        if let videoThumb = dictionary[kAPIKeyVideoThumb] as? String {
            if isDev {
                self.videoThumb = BaseRouter.baseUrl + "api" + videoThumb
            } else {
                self.videoThumb = videoThumb
            }
        }
        if let postText = dictionary[kAPIKeyPostsText] as? String {
            self.postText = postText
        }
        if let date = dictionary[kAPIKeyDate] as? String {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
            if let parsedDateTimeString = dateFormatter.date(from: date) {
                self.date = parsedDateTimeString
            } else {
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZ"
                if let parsedDateTimeString = dateFormatter.date(from: date) {
                    self.date = parsedDateTimeString
                } else {
                    print("Could not parse date")
                }
            }
        }
        if let location = dictionary[kAPIKeyLocation] as? String {
            self.location = location
        }
        if let userLikes = dictionary[kAPIKeyUserLikes] as? Int {
            if userLikes == 1 {
                self.userLikes = true
            }
        }
        if let likesCount = dictionary[kAPIKeyPostsLikes] as? Int {
            self.likesCount = likesCount
        }
        if let commentCount = dictionary[kAPIKeyPostsComments] as? Int {
            self.commentCount = commentCount
        }
        if let user = dictionary[kAPIKeyUser] as? [String:AnyObject] {
            self.user = User(dictionary: user)
        }
    }
}
func == (lhs: Posts, rhs: Posts) -> Bool {
    return lhs.id == rhs.id
}
/*
 "id": 13,
 "video": "/media/0capture_movie_zwQsT8l.m4v",
 "thumb": "/media/0image_pxxJxDF.png",
 "location": "",
 "text": "",
 "date": "2016-06-09T11:21:28Z",
 "likes": 3,
 "user": {
 "id": 3,
 "username": "test2",
 "fullname": ""
 */
