//
//  User.swift
//  Capture
//
//  Created by Mathias Palm on 2016-06-09.
//  Copyright © 2016 capture. All rights reserved.
//

import Foundation

private let kAPIKeyId = "id"
private let kAPIKeyUsername = "username"
private let kAPIKeyEmail = "email"
private let kAPIKeyFullName = "fullname"
private let kAPIKeyInfoText = "infotext"
private let kAPIKeyWebsite = "website"
private let kAPIKeyLocation = "location"
private let kAPIKeyIsUser = "isuser"
private let kAPIKeyIsFollowed = "isfollowed"
private let kAPIKeyProfileImage = "profilepic"
private let kAPIKeyProfileBackgroundImage = "profilebackground"
private let kAPIKeyProfileFollowing = "following"
private let kAPIKeyProfileFollowers = "followers"
private let kAPIKeyProfilePosts = "posts"


class User: Equatable {
    var id: Int = 0
    var username = ""
    var email = ""
    var fullName = ""
    var info = ""
    var website = ""
    var location = ""
    var isUser = false
    var isFollowed = false
    var profileImage = ""
    var profileBackgroundImage = ""
    var following: Int = 0
    var followers: Int = 0
    var post: [Posts]?
    
    init(dictionary: [String:AnyObject]) {
        if let id = dictionary[kAPIKeyId] as? Int {
            self.id = id
        }
        if let username = dictionary[kAPIKeyUsername] as? String {
            self.username = username
        }
        if let email = dictionary[kAPIKeyEmail] as? String {
            self.email = email
        }
        if let fullName = dictionary[kAPIKeyFullName] as? String {
            self.fullName = fullName
        }
        if let info = dictionary[kAPIKeyInfoText] as? String {
            self.info = info
        }
        if let website = dictionary[kAPIKeyWebsite] as? String {
            self.website = website
        }
        if let location = dictionary[kAPIKeyLocation] as? String {
            self.location = location
        }
        if let isUser = dictionary[kAPIKeyIsUser] as? Bool {
            self.isUser = isUser
        }
        if let isFollowed = dictionary[kAPIKeyIsFollowed] as? Bool {
            self.isFollowed = isFollowed
        }
        if let profileImage = dictionary[kAPIKeyProfileImage] as? String {
            setProfilePicture(profileImage)
        }
        if let profileBackgroundImage = dictionary[kAPIKeyProfileBackgroundImage] as? String {
            setBackgroundPhoto(profileBackgroundImage)
        }
        if let following = dictionary[kAPIKeyProfileFollowing] as? Int {
            self.following = following
        }
        if let followers = dictionary[kAPIKeyProfileFollowers] as? Int {
            self.followers = followers
        }
        if let postArray = dictionary[kAPIKeyProfilePosts] as? Array<[String:AnyObject]> {
            self.post = postArray.map({ Posts(dictionary: $0) })
        }
    }
    
    func setProfilePicture(_ imageUrl:String) {
        let plistName = "Capture_API"
        let infoDict = Bundle.main.object(forInfoDictionaryKey: plistName) as! NSDictionary
        let isDev = infoDict["is-dev"] as! Bool
        if isDev {
            self.profileImage = BaseRouter.baseUrl + "api" + imageUrl
        } else {
            self.profileImage = imageUrl
        }
    }
    
    func setBackgroundPhoto(_ imageUrl:String) {
        let plistName = "Capture_API"
        let infoDict = Bundle.main.object(forInfoDictionaryKey: plistName) as! NSDictionary
        let isDev = infoDict["is-dev"] as! Bool
        if isDev {
            self.profileBackgroundImage = BaseRouter.baseUrl + "api" + imageUrl
        } else {
            self.profileBackgroundImage = imageUrl
        }
    }
    
    func toDictionary() -> [String:AnyObject] {
        var dict: [String: AnyObject] = [:]
        dict[kAPIKeyUsername] = username as AnyObject?
        dict[kAPIKeyEmail] = email as AnyObject?
        dict[kAPIKeyFullName] = fullName as AnyObject?
        dict[kAPIKeyInfoText] = info as AnyObject?
        dict[kAPIKeyWebsite] = website as AnyObject?
        dict[kAPIKeyLocation] = location as AnyObject?
        return dict
    }
    
    func getName() -> String {
        if fullName.characters.count > 0 {
            return fullName
        } else {
            return username
        }
    }
    
}
func == (lhs: User, rhs: User) -> Bool {
    return lhs.id == rhs.id
}
/*
 {
     "isuser": true,
     "id": 1,
     "username": "admin",
     "email": "info@mathiaspalm.me",
     "fullname": "Mathias Palm",
     "profilepic": "/media/e24f37ff335c5017999270ec1496827d.jpg",
     "profilebackground": "/media/e24f37ff335c5017999270ec1496827d_eq64cWi.jpg",
     "infotext": "Developer",
     "website": "mathiaspalm.me",
     "location": "Stockholm, sweden",
     "following": 2,
     "followers": 0,
     "posts": [
             {
             "video": "/media/0capture_movie_1B3OM2U.m4v",
             "thumb": "/media/0image_lgpNpgn.png",
             "post_ready": true
             }
         ]
 }
 */

