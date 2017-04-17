//
//  ExplorerRouter.swift
//  Capture
//
//  Created by Mathias Palm on 2016-10-07.
//  Copyright © 2016 capture. All rights reserved.
//

import UIKit
import Alamofire

enum ExplorerEndpoint {
    case getTags()
    case getPosts()
    case getPeople()
    case getMap()
    case getTagCluster()
}

class ExplorerRouter: BaseRouter {
    var endpoint: ExplorerEndpoint
    
    init(endpoint: ExplorerEndpoint) {
        self.endpoint = endpoint
    }
    
    override var method: Alamofire.HTTPMethod {
        switch endpoint {
        case .getTags: return .get
        case .getPosts: return .get
        case .getPeople: return .get
        case .getMap: return .get
        case .getTagCluster: return .get
        }
    }
    
    override var path: String {
        switch endpoint {
        case .getTags(): return "api/explorer/tags/"
        case .getPosts(): return "api/explorer/posts/"
        case .getPeople(): return "api/explorer/people/"
        case .getMap(): return "api/explorer/map/"
        case .getTagCluster(): return "api/explorer/map/"
        }
    }
}
