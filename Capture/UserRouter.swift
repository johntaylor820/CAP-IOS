//
//  UserRouter.swift
//  Capture
//
//  Created by Mathias Palm on 2016-06-09.
//  Copyright © 2016 capture. All rights reserved.
//

import UIKit
import Alamofire

enum UserEndpoint {
    case getCurrentUser()
    case getUser(id:Int)
    case updateUser(user: User)
    case changePassword(password: String, newPassword: String)
    case restorePassword(email: String)
    
    case registerUser(param: [String:String])
    case checkUsername(username: String)
    case checkEmail(email: String)
    
    case uploadNewProfilePic()
    case uploadNewBackgroundPic()
    
    case getActivity()
    
    case follow(id:Int)
    case unFollow(id:Int)
}


class UserRouter: BaseRouter {
    var endpoint: UserEndpoint
    
    init(endpoint: UserEndpoint) {
        self.endpoint = endpoint
    }
    
    override var method: Alamofire.HTTPMethod {
        switch endpoint {
            case .getCurrentUser: return .get
            case .getUser: return .get
            case .updateUser: return .patch
            case .changePassword: return .patch
            case .restorePassword: return .post
            
            case .registerUser: return .post
            case .checkUsername: return .post
            case .checkEmail: return .post

            
            case .uploadNewProfilePic: return .patch
            case .uploadNewBackgroundPic: return .patch
            
            case .getActivity: return .get
            
            case .follow: return .put
            case .unFollow: return .delete
        }
    }
    
    override var path: String {
        switch endpoint {
            case .getCurrentUser(): return "api/userpage/me/"
            case .getUser(let id): return "api/userpage/\(id)/"
            case .updateUser(_): return "api/userpage/1/"
            case .changePassword(_,_): return "api/changepassword/me/"
            case .restorePassword(_): return "api/restorepassword/"
            case .registerUser(_): return "api/register/"
            
            case .checkUsername(_): return "api/check/username/"
            case .checkEmail(_): return "api/check/email/"
            
            case .uploadNewProfilePic(): return "api/profilepic/"
            case .uploadNewBackgroundPic(): return "api/profilebackground/"
            
            case .getActivity(): return "api/getactivity/me/"
            
            case .follow(let id): return "api/relations/\(id)/"
            case .unFollow(let id): return "api/relations/\(id)/"
        }
    }
    
    override var encoding: Alamofire.ParameterEncoding? {
        switch endpoint {
            default: return JSONEncoding.default
        }
    }
    
    override var parameters: APIParams {
        switch endpoint {
            case .registerUser(let param):
                return param as APIParams
            case .checkUsername(let username):
                let param = ["username" : username]
                return param as APIParams
            case .checkEmail(let email):
                let param = ["email" : email]
                return param as APIParams
            
            case .updateUser(let user):
                return user.toDictionary()
            case .changePassword(let password, let newPassword):
                let param = ["password" : password, "new_password": newPassword]
                return param as APIParams
            case .restorePassword(let email):
                let param = ["email" : email]
                return param as APIParams
            default: return nil
        }
    }
}
