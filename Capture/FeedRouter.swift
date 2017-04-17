//
//  FeedRouter.swift
//  Capture
//
//  Created by Mathias Palm on 2016-06-10.
//  Copyright © 2016 capture. All rights reserved.
//

import UIKit
import Alamofire

enum FeedEndpoint {
    case streamFeed(page:Int)
    case likePost(id:Int)
    case deleteLike(id:Int)
    
    case makePost()
    case finishPost(id:Int, location:String, lat: Float, long: Float, text:String, tags: String)
    case deletePost(id:Int)
    
    case getPost(id:Int)
}

class FeedRouter: BaseRouter {
    var endpoint: FeedEndpoint
    
    init(endpoint: FeedEndpoint) {
        self.endpoint = endpoint
    }
    
    override var method: Alamofire.HTTPMethod {
        switch endpoint {
            case .streamFeed: return .get
            case .likePost: return .put
            case .deleteLike: return .delete
            
            case .makePost: return .put
            case .finishPost: return .patch
            case .deletePost: return .delete
            case .getPost: return .get
        }
    }
    
    override var path: String {
        switch endpoint {
            case .streamFeed(_): return "api/feed/"
            case .likePost(let id): return "api/postlikes/\(id)/"
            case .deleteLike(let id): return "api/postlikes/\(id)/"
            
            case .makePost(): return "api/uploads/"
            case .finishPost(_): return "api/handleupload/"
            case .deletePost(let id): return "api/post/\(id)/"
            
            case .getPost(let id): return "api/post/\(id)/"
        }
    }
    
    override var encoding: Alamofire.ParameterEncoding? {
        switch endpoint {
            case .streamFeed(_): return URLEncoding.default
            default: return JSONEncoding.default
        }
    }
    
    override var parameters: APIParams {
        switch endpoint {
            case .streamFeed(let page):
                let param = ["page" : "\(page)"]
                return param as APIParams
            case .finishPost(let id, let location, let lat, let long, let text, let tags):
                let param = [
                    "tags"  : tags,
                    "id" : "\(id)",
                    "location" : location,
                    "latitude" : lat,
                    "longitude" : long,
                    "text" : text
                ] as [String : Any]
                return param as APIParams
            default: return nil
        }
    }
    
}
