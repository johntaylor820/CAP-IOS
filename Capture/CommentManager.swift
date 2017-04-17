//
//  CommentManager.swift
//  Capture
//
//  Created by Mathias Palm on 2016-06-14.
//  Copyright © 2016 capture. All rights reserved.
//

import UIKit
import Alamofire
import Crashlytics

typealias CommentResponseBlock = (_ comments: [Comments]?, _ error: Error?) -> ()
typealias CommentSuccesResponse = (_ succes: Bool, _ error: Error?) -> ()

class CommentManager: BaseManager {
    
    override class var sharedInstance: CommentManager {
        struct Singleton {
            static let instance = CommentManager()
        }
        return Singleton.instance
    }
    
    func getComments(_ id: Int, page:Int, completion: @escaping CommentResponseBlock) {
        let router = CommentRouter(endpoint: .getComments(id: id, page: page))
        
        authenticateRequestWithRouter(router) { (result, dict, error) in
            if result,let responseDict = dict as? Array<[String:AnyObject]> {
                if responseDict.count > 0 {
                    let contents = responseDict.map({ Comments(dictionary: $0) })
                    completion(contents, nil)
                } else {
                    completion(nil, error)
                }
            } else {
                completion(nil, error)
            }
        }
    }
    
    func commentPost(_ id: Int, comment:String, tags:String, completion: @escaping CommentSuccesResponse) {
        let router = CommentRouter(endpoint: .commentPost(id: id, comment:comment, tags: tags))
        
        authenticateRequestWithRouter(router) { (result, dict, error) in
            if result {
                completion(true, error)
            } else {
                completion(false, error)
            }
        }
    }
    
    func deleteComment(_ id: Int, completion: @escaping CommentSuccesResponse) {
        let router = CommentRouter(endpoint: .deleteComment(id: id))
        
        authenticateRequestWithRouter(router) { (result, dict, error) in
            if result {
                completion(true, error)
            } else {
                completion(false, error)
            }
        }
    }
}
