//
//  BaseRouter.swift
//  Capture
//
//  Created by Mathias Palm on 2016-06-09.
//  Copyright © 2016 capture. All rights reserved.
//

import Foundation
import Alamofire

public typealias APIParams = [String : AnyObject]?

protocol APIConfiguration {
    var method: Alamofire.HTTPMethod { get }
    var encoding: Alamofire.ParameterEncoding? { get }
    var path: String { get }
    var parameters: APIParams { get }
    static var baseUrl: String { get }
}

open class BaseRouter: URLRequestConvertible, APIConfiguration {

    fileprivate static let plistName = "Capture_API"
    
    public init() {
        
    }
    
    open var method: Alamofire.HTTPMethod {
        fatalError("[\(Mirror(reflecting: self).description) - \( #function ))] Must be overridden in subclass")
    }
    
    open var encoding: Alamofire.ParameterEncoding? {
        fatalError("[\(Mirror(reflecting: self).description) - \( #function ))] Must be overridden in subclass")
    }
    
    open var path: String {
        fatalError("[\(Mirror(reflecting: self).description) - \( #function ))] Must be overridden in subclass")
    }
    
    open var parameters: APIParams {
        fatalError("[\(Mirror(reflecting: self).description) - \( #function ))] Must be overridden in subclass")
    }
    
    open static var baseUrl: String {
        if let dict = Bundle.main.object(forInfoDictionaryKey: plistName) as? NSDictionary, let baseUrl = dict["API_URL"] as? String {
            return baseUrl
        }
        fatalError("[\(Mirror(reflecting: self).description) - \( #function ))] API url not found in .plist with name: '\( plistName )'")
    }
    
    
    open func asURLRequest() throws -> URLRequest {
        let url = URL(string: BaseRouter.baseUrl)!
        var urlRequest = URLRequest(url: url.appendingPathComponent(path))
        urlRequest.httpMethod = method.rawValue
        
        if let encoding = encoding {
            return try encoding.encode(urlRequest, with: parameters)
        }
        return urlRequest
    }

}
