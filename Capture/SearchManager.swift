//
//  SearchManager.swift
//  Capture
//
//  Created by Mathias Palm on 2016-06-14.
//  Copyright © 2016 capture. All rights reserved.
//

import Alamofire
import Crashlytics

typealias SearchUserResponseBlock = (_ users: [User]?, _ error: Error?) -> ()
typealias GetUserResponseBlock = (_ users: User?, _ error: Error?) -> ()
typealias SearchTagsResponseBlock = (_ tags: [Tag]?, _ error: Error?) -> ()
typealias SearchVideosResponseBlock = (_ posts: [Posts]?, _ error: Error?) -> ()


class SearchManager: BaseManager {
    
    override class var sharedInstance: SearchManager {
        struct Singleton {
            static let instance = SearchManager()
        }
        return Singleton.instance
    }
    
    func searchTags(_ query: String, page: Int = 0, completion: @escaping SearchTagsResponseBlock) {
        if query.characters.count > 0 {
            let router = SearchRouter(endpoint: .searchTag(query: query, page: page))
            
            authenticateRequestWithRouter(router) { (result, dict, error) in
                if result, let responseDict = dict as? Array<[String:AnyObject]> {
                    if responseDict.count > 0 {
                        let contents = responseDict.map({ Tag(dictionary: $0) })
                        completion(contents, nil)
                    } else {
                        completion(nil, error)
                    }
                } else {
                    completion(nil, error)
                }
            }
        }
    }
    
    func searchUser(_ query: String, page: Int = 0, completion: @escaping SearchUserResponseBlock) {
        if query.characters.count > 0 {
            let router = SearchRouter(endpoint: .searchUser(query: query, page: page))
            
            authenticateRequestWithRouter(router) { (result, dict, error) in
                if result, let responseDict = dict as? Array<[String:AnyObject]> {
                    if responseDict.count > 0 {
                        let contents = responseDict.map({ User(dictionary: $0) })
                        completion(contents, nil)
                    } else {
                        completion(nil, error)
                    }
                } else {
                    completion(nil, error)
                }
            }
        }
    }
    
    func getUserForName(_ name: String, completion: @escaping GetUserResponseBlock) {
        if name.characters.count > 0 {
            let router = SearchRouter(endpoint: .getUserForName(name:name))
            
            authenticateRequestWithRouter(router) { (result, dict, error) in
                if result, let userDict = dict as? [String:AnyObject] {
                    let user = User(dictionary: userDict)
                    completion(user, nil)
                } else {
                    completion(nil, error)
                }
            }
        }
    }
    
    func popularUsers(_ completion: @escaping SearchUserResponseBlock) {
        let router = SearchRouter(endpoint: .popluarPeople())
        
        authenticateRequestWithRouter(router) { (result, dict, error) in
            if result, let responseDict = dict as? Array<[String:AnyObject]> {
                if responseDict.count > 0 {
                    let contents = responseDict.map({ User(dictionary: $0) })
                    completion(contents, nil)
                } else {
                    completion(nil, error)
                }
            } else {
                completion(nil, error)
            }
        }
    }
    
    func popularTags(_ completion: @escaping SearchTagsResponseBlock) {
        let router = SearchRouter(endpoint: .popluarTags())
        
        authenticateRequestWithRouter(router) { (result, dict, error) in
            if result, let responseDict = dict as? Array<[String:AnyObject]> {
                if responseDict.count > 0 {
                    let contents = responseDict.map({ Tag(dictionary: $0) })
                    completion(contents, nil)
                } else {
                    completion(nil, error)
                }
            } else {
                completion(nil, error)
            }
        }
    }
    
    func popularVideos(_ completion: @escaping SearchVideosResponseBlock) {
        let router = SearchRouter(endpoint: .popluarVideos())
        
        authenticateRequestWithRouter(router) { (result, dict, error) in
            if result, let responseDict = dict as? Array<[String:AnyObject]> {
                if responseDict.count > 0 {
                    let contents = responseDict.map({ Posts(dictionary: $0) })
                    completion(contents, nil)
                } else {
                    completion(nil, error)
                }
            } else {
                completion(nil, error)
            }
        }
    }
}
