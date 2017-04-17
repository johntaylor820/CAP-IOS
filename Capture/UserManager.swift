//
//  UserManager.swift
//  Capture
//
//  Created by Mathias Palm on 2016-06-09.
//  Copyright © 2016 capture. All rights reserved.
//

import UIKit
import Alamofire
import Crashlytics
import FBSDKLoginKit

private let kUserDefaultsUserPassword = "kUserDefaultsUserPassword"
private let kUserKeychainKeyPassword = "kUserKeychainKeyPassword"

typealias UserSuccessResponseBlock = (_ success: Bool, _ error: Error?) -> ()
typealias registerResponseBlock = (_ id: Int, _ success: Bool, _ error: Error?) -> ()

typealias UserResponseBlock = (_ user: User?, _ error: Error?) -> ()
typealias UsersResponseBlock = (_ users: [User]?, _ error: Error?) -> ()

typealias ActivityResponseBlock = (_ activity: [Activity]?, _ error: Error?) -> ()

typealias ForgotPasswordResponseBlock = (_ success: Bool, _ error: Error?) -> ()


class UserManager: BaseManager {
    var user: User?
    
    override class var sharedInstance: UserManager {
        struct Singleton {
            static let instance = UserManager()
        }
        return Singleton.instance
    }
    
    func storeUser(_ user: User) {
        self.user = user
    }
    
    func currentAuthorizedUser(_ completion: @escaping (_ user: User?) -> ()) {
        if hasAccessToken {
            UserManager.sharedInstance.getCurrentUser() { (user, _) in
                if let user = user {
                    self.storeUser(user)
                    completion(user)
                } else {
                    completion(nil)
                }
            }
        } else {
            print("Did not find any access token")
            completion(nil)
        }
    }

    // MARK: - Authentication

    func authenticateWithUsername(_ username: String, password: String, completion: @escaping UserResponseBlock) {
        requestTokens(username: username, password: password, completion: { success, error in
            if success {
                UserManager.sharedInstance.getCurrentUser() { (user, error) in
                    if let user = user {
                        self.storeUser(user)
                        completion(user, nil)
                    } else if let error = error {
                        completion(nil, error)
                    }
                }
            } else {
                completion(nil, error)
            }
        })
//        heimdallr.requestAccessToken(username: username, password: password) { result in
//            switch result {
//            case .success:
//                UserManager.sharedInstance.getCurrentUser() { (user, error) in
//                    if let user = user {
//                        self.storeUser(user)
//                        completion(user, nil)
//                    } else if let error = error {
//                        completion(nil, error)
//                    }
//                }
//            case .failure(let error):
//                completion(nil, error)
//            }
//        }
    }
//    func authenticateWithFacebookToken(_ facebookToken: String, completion: @escaping UserResponseBlock) {
//        let parameters = [
//            "backend": "facebook",
//            "token" : facebookToken
//        ]
//        heimdallr.requestAccessToken(grantType: "convert_token", parameters: parameters) { result in
//            switch result {
//            case .success:
//                UserManager.sharedInstance.getCurrentUser { (user, error) in
//                    if let user = user {
//                        self.storeUser(user)
//                        completion(user, nil)
//                    } else if let error = error {
//                        completion(nil, error)
//                    }
//                }
//            case .failure(let error):
//                completion(nil, error)
//            }
//        }
//    }
    
//    func loginWithFacebookLoginUI(_ completion: @escaping UserResponseBlock) {
//        let loginManager: FBSDKLoginManager = FBSDKLoginManager()
//        
//        if FBSDKAccessToken.current() != nil {
//            fetchFacebookUserInfo(completion)
//        } else if let appDelegate = UIApplication.shared.delegate as? AppDelegate,
//            let rootController = appDelegate.window?.rootViewController {
//            
//            loginManager.logInWithReadPermissions(["email"], fromViewController: rootController, handler: { (result: FBSDKLoginManagerLoginResult!, error: NSError!) in
//                if error != nil {
//                    debugPrint("FB Login Error: \( error.localizedDescription )")
//                } else if result.isCancelled {
//                    debugPrint("FB Login Error: Login was cancelled")
//                } else {
//                    if result.grantedPermissions.contains("email") {
//                        self.fetchFacebookUserInfo(completion)
//                    } else {
//                        debugPrint("FB Login Error: Facebook email permission error")
//                    }
//                }
//            })
//        } else {
//            debugPrint("FB Login Error: no root view controller")
//        }
//    }
//    func fetchFacebookUserInfo(_ completion: @escaping UserResponseBlock) {
//        FBSDKGraphRequest(graphPath: "me", parameters: ["fields" : "id, name, email"]).startWithCompletionHandler { (connection: FBSDKGraphRequestConnection!, result: AnyObject!, error: NSError!) in
//            
//            if error != nil {
//                debugPrint("FB Users info Error: \( error.localizedDescription )")
//            } else {
//                let accessToken: FBSDKAccessToken = FBSDKAccessToken.currentAccessToken()
//                FBSDKAccessToken.setCurrentAccessToken(accessToken)
//                self.authenticateWithFacebookToken(accessToken.tokenString, completion: completion)
//            }
//        }
//    }
    
    func logoutUserWithCompletion(_ completion: (() -> ())?) {
        try! deleteKeychain()
        user = nil
        if let completion = completion {
            completion()
        }
    }
    
    func getCurrentUser(_ completion: @escaping UserResponseBlock) {
        let router = UserRouter(endpoint: .getCurrentUser())
        
        authenticateRequestWithRouter(router) { (result, dict, error) in
            if result, let userDict = dict as? [String:AnyObject] {
                let user = User(dictionary: userDict)
                self.storeUser(user)
                completion(user, nil)
            } else {
                completion(nil, error)
            }
        }
    }
    
    func getUser(_ id: Int, completion: @escaping UserResponseBlock) {
        let router = UserRouter(endpoint: .getUser(id: id))
        
        authenticateRequestWithRouter(router) { (result, dict, error) in
            if result, let userDict = dict as? [String:AnyObject] {
                let n_user = User(dictionary: userDict)
                completion(n_user, nil)
            } else {
                completion(nil, error)
            }
        }
    }
    
    func getActivity(_ completion: @escaping ActivityResponseBlock) {
        let router = UserRouter(endpoint: .getActivity())
        
        authenticateRequestWithRouter(router) { (result, dict, error) in
            if result, let responseDict = dict as? Array<[String:AnyObject]> {
                if responseDict.count > 0 {
                    let contents = responseDict.map({ Activity(dictionary: $0) })
                    completion(contents, nil)
                } else {
                    completion(nil, error)
                }
            } else {
                completion(nil, error)
            }
        }
    }
    
    func registerUser(_ param: [String:String], completion: @escaping registerResponseBlock) {
        let router = UserRouter(endpoint: .registerUser(param: param))
        
        manager.request(router).validate().responseJSON(completionHandler: { response in
            switch response.result {
            case .success(_):
                if let username = param["username"], let password = param["password"] {
                    self.authenticateWithUsername(username, password: password, completion: { (user, error) in
                        if let user = self.user {
                            completion(user.id, true, nil)
                        } else {
                            completion(0, false, error)
                        }
                    })
                } else {
                    completion(0, false, nil)
                }
            case .failure(let error):
                completion(0, false, error)
            }
        })
    }
    
    func checkEmail(_ email: String, completion: @escaping UserSuccessResponseBlock) {
        let router = UserRouter(endpoint: .checkEmail(email: email))
        
        manager.request(router).validate().responseJSON(completionHandler: { response in
            switch response.result {
            case .success(_):
                completion(true, nil)
            case .failure(let error):
                completion(false, error)
            }
        })
    }
    
    func checkUsername(_ username: String, completion: @escaping UserSuccessResponseBlock) {
        let router = UserRouter(endpoint: .checkUsername(username: username))
        
        manager.request(router).validate().responseJSON(completionHandler: { response in
            switch response.result {
            case .success(_):
                completion(true, nil)
            case .failure(let error):
                completion(false, error)
            }
        })
    }
    
    func updateUser(_ user: User, completion: @escaping UserResponseBlock) {
        let router = UserRouter(endpoint: .updateUser(user: user))
        
        authenticateRequestWithRouter(router) { (result, dict, error) in
            if result, let userDict = dict as? [String:AnyObject] {
                let user = User(dictionary: userDict)
                self.storeUser(user)
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "refreshUserInfo"), object: nil)
                completion(user, nil)
            } else {
                completion(nil, error)
            }
        }
    }
    
    func changeUserPassword(_ password: String, newPassword: String, completion: @escaping UserSuccessResponseBlock) {
        let router = UserRouter(endpoint: .changePassword(password: password, newPassword: newPassword))
        
        authenticateRequestWithRouter(router) { (result, dict, error) in
            if result {
                completion(true, nil)
            } else {
                completion(false, error)
            }
        }
    }
    
    func restoreUserPassword(_ email: String, completion: @escaping UserSuccessResponseBlock) {
        let router = UserRouter(endpoint: .restorePassword(email: email))
        manager.request(router).validate().responseJSON(completionHandler: { response in
            switch response.result {
            case .success(_):
                completion(true, nil)
            case .failure(let error):
                completion(false, error)
            }
        })
    }
    
    func updateProfilePictureForUser(_ userId: Int, profilePicture: UIImage, completion: @escaping UserSuccessResponseBlock) {
        guard let pictureData: Data = UIImagePNGRepresentation(profilePicture) else {
            let error = NSError(domain: "Profile Image", code: 400, userInfo: [NSLocalizedDescriptionKey:"Profile Image Upload Failure"])
            completion(false, error)
            return
        }
        let dateString = "\(Date())"
        let imageFileName = "\(userId)-\(dateString.removeWhitespace()).png"
        let router = UserRouter(endpoint: .uploadNewProfilePic())
        var request: URLRequest?
        do {
            request = try router.asURLRequest()
        } catch _ {
            completion(false, nil)
        }
        if let request = request {
            manager.upload(multipartFormData: { multipartFormData in
                multipartFormData.append(pictureData, withName: "profilepic", fileName: imageFileName, mimeType: "image/png")
                }, with: request, encodingCompletion: { (result) in
                    switch result {
                    case .success(let upload, _, _):
                        upload.validate()
                        upload.responseJSON { response in
                            completion(true, nil)
                            switch response.result {
                            case .success(let dict):
                                if let responseDict = dict as? [String:AnyObject], let profileImageUrlString = responseDict["profilepic"] as? String {
                                    if let user = self.user {
                                        user.setProfilePicture(profileImageUrlString)
                                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "refreshUserInfo"), object: nil)
                                    }
                                    completion(true, nil)
                                } else {
                                    completion(false, nil)
                                }
                                
                            case .failure(let error):
                                completion(false, error)
                            }
                            
                        }
                    case .failure(_):
                        completion(false, nil)
                    }
            })
        }
    }
    
    func updateBackgroundPhotoForUser(_ userId: Int, backgroundPhoto: UIImage, completion: @escaping UserSuccessResponseBlock) {
        guard let pictureData: Data = UIImagePNGRepresentation(backgroundPhoto) else {
            let error = NSError(domain: "bg Image", code: 400, userInfo: [NSLocalizedDescriptionKey:"bg Image Upload Failure"])
            completion(false, error)
            return
        }
        let dateString = "\(Date())"
        let imageFileName = "\(userId)-\(dateString.removeWhitespace()).png"
        let router = UserRouter(endpoint: .uploadNewBackgroundPic())
        var request: URLRequest?
        do {
            request = try router.asURLRequest()
        } catch _ {
            completion(false, nil)
        }
        if let request = request {
            manager.upload(multipartFormData: { multipartFormData in
                multipartFormData.append(pictureData, withName: "profilebackground", fileName: imageFileName, mimeType: "image/png")
                }, with: request, encodingCompletion: { (result) in
                    switch result {
                    case .success(let upload, _, _):
                        upload.validate()
                        upload.responseJSON { response in
                            switch response.result {
                            case .success(let dict):
                                if let responseDict = dict as? [String:AnyObject], let profileImageUrlString = responseDict["profilebackground"] as? String {
                                    if let user = self.user {
                                        user.setBackgroundPhoto(profileImageUrlString)
                                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "refreshUserInfo"), object: nil)
                                    }
                                    completion(true, nil)
                                } else {
                                    completion(false, nil)
                                }
                                
                            case .failure(let error):
                                completion(false, error)
                            }
                        }
                    case .failure(_):
                        completion(false, nil)
                    }
            })
        }
    }
    
    func followUser(_ id:Int, completion: @escaping UserSuccessResponseBlock) {
        let router = UserRouter(endpoint: .follow(id: id))
        
        authenticateRequestWithRouter(router) { (result, dict, error) in
            if result {
                completion(true, nil)
            } else {
                completion(false, error)
            }
        }
    }
    
    func unFollowUser(_ id:Int, completion: @escaping UserSuccessResponseBlock) {
        let router = UserRouter(endpoint: .unFollow(id: id))
        
        authenticateRequestWithRouter(router) { (result, dict, error) in
            if result {
                completion(true, nil)
            } else {
                completion(false, error)
            }
        }
    }
}
extension User {
    
    var isCurrentUser: Bool {
        get {
            guard let currentUser = UserManager.sharedInstance.user else {
                return false
            }
            return (self.id == currentUser.id)
        }
    }
}
