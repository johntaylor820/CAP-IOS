//
//  ExplorerManager.swift
//  Capture
//
//  Created by Mathias Palm on 2016-10-24.
//  Copyright © 2016 capture. All rights reserved.
//

import Alamofire
import Crashlytics

typealias ExplorerTagResponseBlock = (_ users: [Tag]?, _ error: Error?) -> ()

class ExplorerManager: BaseManager {
    
    override class var sharedInstance: ExplorerManager {
        struct Singleton {
            static let instance = ExplorerManager()
        }
        return Singleton.instance
    }
    
    
}
