//
//  CaptureCache.swift
//  Capture
//
//  Created by Mathias Palm on 2016-07-24.
//  Copyright © 2016 capture. All rights reserved.
//

import UIKit

class CaptureCache: NSCache<AnyObject, AnyObject> {
    static let sharedInstance = CaptureCache()
    
    fileprivate var observer: NSObjectProtocol!
    
    fileprivate override init() {
        super.init()
        
        observer = NotificationCenter.default.addObserver(forName: NSNotification.Name.UIApplicationDidReceiveMemoryWarning, object: nil, queue: nil) { [unowned self] notification in
            self.removeAllObjects()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(observer)
    }
    
    subscript(key: AnyObject) -> AnyObject? {
        get {
            return object(forKey: key)
        }
        set {
            if let value: AnyObject = newValue {
                setObject(value, forKey: key)
            } else {
                removeObject(forKey: key)
            }
        }
    }
    
    
}
