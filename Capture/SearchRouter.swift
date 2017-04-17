//
//  SearchRouter.swift
//  Capture
//
//  Created by Mathias Palm on 2016-06-14.
//  Copyright © 2016 capture. All rights reserved.
//

import UIKit
import Alamofire

enum SearchEndpoint {
    case searchTag(query:String, page:Int)
    case searchUser(query:String, page:Int)
    case popluarPeople()
    case popluarTags()
    case popluarVideos()
    case getUserForName(name: String)
}

class SearchRouter: BaseRouter {
    var endpoint: SearchEndpoint
    
    init(endpoint: SearchEndpoint) {
        self.endpoint = endpoint
    }
    
    override var method: Alamofire.HTTPMethod {
        switch endpoint {
        case .searchTag: return .get
        case .searchUser: return .get
        case .popluarPeople: return .get
        case .popluarTags: return .get
        case .popluarVideos: return .get
        case .getUserForName: return .get
        }
    }
    
    override var path: String {
        switch endpoint {
        case .searchTag(_,_): return "api/searchtags/"
        case .searchUser(_,_): return "api/searchuser/"
        case .popluarPeople(): return "api/popularpeople/"
        case .popluarTags(): return "api/popularposts/"

        case .popluarVideos(): return "api/popularvideos/"
        case .getUserForName(let name): return "api/userpage/\(name)/"
        }
    }
    
    override var encoding: Alamofire.ParameterEncoding? {
        switch endpoint {
        default: return URLEncoding.default
        }
    }
    
    override var parameters: APIParams {
        switch endpoint {
        case .searchTag(let query, let page):
            let param = ["name" : "\(query)", "page": "\(page)"]
            return param as APIParams
        case .searchUser(let query, let page):
            let param = ["name" : "\(query)", "page": "\(page)"]
            return param as APIParams
        default:
            return nil
        }
    }
}
