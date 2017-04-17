//
//  ReportManager.swift
//  Capture
//
//  Created by Mathias Palm on 2016-07-19.
//  Copyright © 2016 capture. All rights reserved.
//

import UIKit

class ReportManager: BaseManager {
    override class var sharedInstance: ReportManager {
        struct Singleton {
            static let instance = ReportManager()
        }
        return Singleton.instance
    }
    
    func reportPost(_ id: Int) {
        let router = ReportRouter(endpoint: .reportPost(id:id))
        
        authenticateRequestWithRouter(router) { (result, dict, error) in
            if let error = error {
                debugPrint(error)
            }
        }
    }
    
    func reportUser(_ id: Int) {
        let router = ReportRouter(endpoint: .reportUser(id:id))
       
        authenticateRequestWithRouter(router) { (result, dict, error) in
            if let error = error {
                debugPrint(error)
            }
        }
    }
}
