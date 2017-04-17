//
//  ReportRouter.swift
//  Capture
//
//  Created by Mathias Palm on 2016-07-19.
//  Copyright © 2016 capture. All rights reserved.
//

import UIKit
import Alamofire

enum ReportEndpoint {
    case reportPost(id:Int)
    case reportUser(id:Int)
}

class ReportRouter: BaseRouter {
    var endpoint: ReportEndpoint
    
    init(endpoint: ReportEndpoint) {
        self.endpoint = endpoint
    }
    
    override var method: Alamofire.HTTPMethod {
        switch endpoint {
        case .reportPost: return .put
        case .reportUser: return .put
        }
    }
    
    override var path: String {
        switch endpoint {
        case .reportPost(let id): return "api/report/user/\(id)/"
        case .reportUser(let id): return "api/report/post/\(id)/"
        }
    }
    
    override var encoding: Alamofire.ParameterEncoding? {
        switch endpoint {
        default: return URLEncoding.default
        }
    }
    
    override var parameters: APIParams {
        switch endpoint {
        default: return nil
        }
    }
}
