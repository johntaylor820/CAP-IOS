//
//  BaseManager.swift
//  Capture
//
//  Created by Mathias Palm on 2016-06-09.
//  Copyright © 2016 capture. All rights reserved.
//

import UIKit
import Alamofire
import Crashlytics
import Locksmith

typealias RequestResponseBlock = (_ result: Bool,_ request: Any?, _ error: Error?) -> ()

class BaseManager: RequestAdapter, RequestRetrier  {
    
    public typealias RequestRetryCompletion = (_ shouldRetry: Bool, _ timeDelay: TimeInterval) -> Void

    struct OAuthAccount: ReadableSecureStorable, CreateableSecureStorable, DeleteableSecureStorable, GenericPasswordSecureStorable {
        var accessToken: String = ""
        var refreshToken: String = ""
        var tokenType: String = ""
        
        let service = "OAuth"
        
        var account: String { return "OAuthAccount" }
        
        var data: [String: Any] {
            return ["access_token": accessToken, "refresh_token": refreshToken, "token_type": tokenType]
        }
    }
    
    var tokens: OAuthAccount!
    var hasAccessToken: Bool

    var clientID: String
    var clientSecret: String
    var baseURLString: String
    
    var accessToken: String
    var refreshToken: String
    var tokenType: String

    var isRefreshing = false
    var requestsToRetry: [RequestRetryCompletion] = []
    let lock = NSLock()
    
    let manager = SessionManager()

    init() {
        tokens = OAuthAccount()
        
        let plistName = "Capture_API"
        let infoDict = Bundle.main.object(forInfoDictionaryKey: plistName) as! NSDictionary
        let authorizationDict = infoDict["Authorization"] as! NSDictionary
        let clientId = authorizationDict["ClientId"] as! String
        let clientSecret = authorizationDict["ClientSecret"] as! String
        self.clientID = clientId
        self.clientSecret = clientSecret
        self.baseURLString = BaseRouter.baseUrl
        
        self.accessToken = ""
        self.refreshToken = ""
        self.tokenType = ""
        self.hasAccessToken = false
        self.hasAccessToken = hasTookenInKeychain()

        manager.adapter = self
        manager.retrier = self
    }
    
    
    // MARK: - View life cycle
    
    class var sharedInstance: BaseManager {
        struct Singleton {
            static let instance = BaseManager()
        }
        return Singleton.instance
    }
    
    func updateKeys(accessToken: String, refreshToken: String, tokenType: String) {
        tokens.accessToken = accessToken
        tokens.refreshToken = refreshToken
        tokens.tokenType = tokenType
        
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.tokenType = tokenType
        
        do {
            try updateKeychain()
        } catch {
            debugPrint("Could not update Keychain")
        }
    }
    
    func hasTookenInKeychain() -> Bool {
        let oAuthData = tokens.readFromSecureStore()
        if let oAuthData = oAuthData, let data = oAuthData.data, let accessToken = data["access_token"] as? String, let refreshToken = data["refresh_token"] as? String, let tokenType = data["token_type"] as? String {
            self.accessToken = accessToken
            self.refreshToken = refreshToken
            self.tokenType = tokenType
            return true
        } else {
            return false
        }
    }
    
    func saveToKeychain() throws {
        try tokens.createInSecureStore()
    }
    
    func updateKeychain() throws {
        try self.deleteKeychain()
        try self.saveToKeychain()
    }
    
    func deleteKeychain() throws {
        try tokens.deleteFromSecureStore()
    }
    
    // MARK: - Authentication
    
    func authenticateRequestWithRouter(_ router: BaseRouter, completion: @escaping RequestResponseBlock) {
        
        if accessToken.characters.count == 0 {
            let getTokens = hasTookenInKeychain()
            if !getTokens {
                if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                    appDelegate.navigateToLogin(true)
                }
                completion(false, nil, nil)
            }
        }
        var request: URLRequest?
        do {
            request = try router.asURLRequest()
        } catch _ {
            completion(false, nil, nil)
        }
        if let request = request {
            manager.request(request).validate().responseJSON(completionHandler: { response in
                switch response.result {
                case .success(let data):
                    completion(true, data, nil)
                case .failure(let error):
                    completion(false, nil, error)
                }
            })
        } else {
            completion(false, nil, nil)
        }
    }
}
extension BaseManager {
    // MARK: - RequestAdapter
    
    public func adapt(_ urlRequest: URLRequest) -> URLRequest {
        if let url = urlRequest.url , url.absoluteString.hasPrefix(baseURLString) {
            var mutableURLRequest = urlRequest
            mutableURLRequest.setValue(tokenType + " " + accessToken, forHTTPHeaderField: "Authorization")
            return mutableURLRequest
        }
        
        return urlRequest
    }
    
    // MARK: - RequestRetrier
    
    public func should(_ manager: SessionManager, retry request: Request, with error: Error, completion: @escaping RequestRetryCompletion) {
        lock.lock() ; defer { lock.unlock() }
        
        if let response = request.task?.response as? HTTPURLResponse, response.statusCode == 401 {
            requestsToRetry.append(completion)
            
            if !isRefreshing {
                refreshTokens(completion: {
                    [weak self]  success, error in
                    
                    guard let strongSelf = self else { return }
                    strongSelf.lock.lock() ; defer { strongSelf.lock.unlock() }
                    
                    strongSelf.requestsToRetry.forEach { $0(success, 0.0) }
                    strongSelf.requestsToRetry.removeAll()
                })
            }
        } else {
            completion(false, 0.0)
        }
    }
    
    // MARK: - Private - Refresh Tokens
    
    private func refreshTokens(completion: @escaping (Bool, Error?) -> ()) {
        let urlString = "\(baseURLString)o/token/"
        
        let parameters: [String: Any] = [
            "access_token": tokens.accessToken,
            "refresh_token": tokens.refreshToken,
            "client_id": clientID,
            "client_secret": clientSecret,
            "grant_type": "refresh_token"
        ]
        request(urlString: urlString, parameters: parameters, completion: { success, error in
            completion(success, error)
        })
    }
    
    public func requestTokens(username: String, password: String, completion: @escaping (Bool, Error?) -> ()) {
        let urlString = "\(baseURLString)o/token/"
        
        let parameters: [String: Any] = [
            "username": username,
            "password": password,
            "client_id": clientID,
            "client_secret": clientSecret,
            "grant_type": "password"
        ]
        request(urlString: urlString, parameters: parameters, completion: { success, error in
            completion(success, error)
        })
    }
    
    func request(urlString: String, parameters: [String: Any], completion: @escaping (Bool, Error?) -> ()) {
        if accessToken.characters.count == 0 {
            let getTokens = hasTookenInKeychain()
            if !getTokens {
                completion(false, nil)
            }
        }
        manager.request(urlString, method: .post, parameters: parameters, encoding: URLEncoding.default).responseJSON { response in
            if let json = response.result.value as? [String: Any], let accessToken = json["access_token"] as? String, let refreshToken = json["refresh_token"] as? String, let tokenType = json["token_type"] as? String {
                self.updateKeys(accessToken: accessToken, refreshToken: refreshToken, tokenType: tokenType)
                
                completion(true, nil)
            } else {
                completion(false, response.result.error)
            }
        }
    }
}
