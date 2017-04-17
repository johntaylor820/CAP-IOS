//
//  CommentRouter.swift
//  Capture
//
//  Created by Mathias Palm on 2016-06-14.
//  Copyright © 2016 capture. All rights reserved.
//

import UIKit
import Alamofire

enum CommentEndpoint {
    case getComments(id:Int, page: Int)
    case commentPost(id:Int, comment:String, tags:String)
    case deleteComment(id:Int)
}

class CommentRouter: BaseRouter {
    var endpoint: CommentEndpoint
    
    init(endpoint: CommentEndpoint) {
        self.endpoint = endpoint
    }
    
    override var method: Alamofire.HTTPMethod {
        switch endpoint {
        case .getComments: return .get
        case .commentPost: return .post
        case .deleteComment: return .delete
        }
    }
    
    override var path: String {
        switch endpoint {
        case .getComments(let id,_): return "api/comments/\(id)/"
        case .commentPost(let id,_,_): return "api/comments/\(id)/"
        case .deleteComment(let id): return "api/comments/\(id)/"
        }
    }
    
    override var encoding: Alamofire.ParameterEncoding? {
        switch endpoint {
        case .getComments(_): return URLEncoding.default
        default: return JSONEncoding.default
        }
    }
    
    override var parameters: APIParams {
        switch endpoint {
        case .getComments(_,let page):
            let param = ["page" : "\(page)"]
            return param as APIParams
        case .commentPost(_,let comment, let tags):
            let param = ["text" : "\(comment)", "tags": tags]
            return param as APIParams
        default: return nil
        }
    }
}
