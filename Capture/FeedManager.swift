//
//  FeedManager.swift
//  Capture
//
//  Created by Mathias Palm on 2016-06-13.
//  Copyright © 2016 capture. All rights reserved.
//

import UIKit
import Alamofire
import Crashlytics

typealias FeedResponseBlock = (_ posts: [Posts]?, _ error: Error?) -> ()
typealias FeedSuccesResponse = (_ succes: Bool, _ error: Error?) -> ()
typealias FeedMakePostResponse = (_ id: Int?, _ error: Error?) -> ()
typealias PostResponseBlock = (_ post: Posts?, _ error: Error?) -> ()



class FeedManager: BaseManager {
    var posts: [Posts] = []
    var lastPage = 0
    
    override class var sharedInstance: FeedManager {
        struct Singleton {
            static let instance = FeedManager()
        }
        return Singleton.instance
    }
    
    fileprivate func storePosts(_ newPosts: [Posts]) {
        for post in newPosts {
            if !posts.contains(post) {
                posts.append(post)
            }
        }
    }
    func resetPosts() {
        lastPage = 0
        posts.removeAll()
    }
    
    func feed(_ page: Int, completion: @escaping FeedResponseBlock) {
        if page > lastPage {
            lastPage = page
            let router = FeedRouter(endpoint: .streamFeed(page: page))
            
            authenticateRequestWithRouter(router) { (result, dict, error) in
                if let responseDict = dict as? Array<[String:AnyObject]> {
                    if responseDict.count > 0 {
                        let contents = responseDict.map({ Posts(dictionary: $0) })
                        self.storePosts(contents)
                        completion(self.posts, nil)
                    } else {
                        completion(nil, nil)
                    }
                } else {
                    completion(nil, error)
                }
            }
        }
    }
    
    func likePost(_ id: Int, completion: @escaping FeedSuccesResponse) {
        let router = FeedRouter(endpoint: .likePost(id: id))
        
        authenticateRequestWithRouter(router) { (result, dict, error) in
            if result {
                for post in self.posts {
                    if post.id == id {
                        post.userLikes = true
                        post.likesCount += 1
                    }
                }
                completion(true, error)
            } else {
                completion(false, error)
            }
        }
    }
    
    func deleteLike(_ id: Int, completion: @escaping FeedSuccesResponse) {
        let router = FeedRouter(endpoint: .deleteLike(id: id))
        
        authenticateRequestWithRouter(router) { (result, dict, error) in
            if result {
                for post in self.posts {
                    if post.id == id {
                        post.userLikes = false
                        post.likesCount -= 1
                    }
                }
                completion(true, error)
            } else {
                completion(false, error)
            }
        }
    }
    
    func deletePost(_ id: Int, completion: @escaping FeedSuccesResponse) {
        let router = FeedRouter(endpoint: .deletePost(id: id))
        
        authenticateRequestWithRouter(router) { (result, dict, error) in
            if result {
                completion(true, error)
            } else {
                completion(false, error)
            }
        }
    }
    
    func startUploadPost(_ id: Int, video: Data, thumb: UIImage, progressLabel: UILabel, completion: @escaping FeedMakePostResponse) {
        guard let pictureData: Data = UIImagePNGRepresentation(thumb) else {
            completion(nil, nil)
            return
        }
        let dateString = "\(Date())"
        let imageFileName = "\(id)-\(dateString.removeWhitespace()).png"
        let videFileName = "\(id)-\(dateString.removeWhitespace()).m4v"
        let router = FeedRouter(endpoint: .makePost())
        var request: URLRequest?
        do {
            request = try router.asURLRequest()
        } catch _ {
            completion(nil, nil)
        }
        if let request = request {
            manager.upload(multipartFormData: { multipartFormData in
                multipartFormData.append(pictureData, withName: "thumb", fileName: imageFileName, mimeType: "image/png")
                multipartFormData.append(video, withName: "video", fileName: videFileName, mimeType: "video/m4v")
                }, with: request, encodingCompletion: { (result) in
                    switch result {
                    case .success(let upload, _, _):
                        upload.validate()
                        upload.responseJSON { response in
                            switch response.result {
                            case .success(let dict):
                                if let responseDict = dict as? [String:AnyObject], let id = responseDict["id"] as? Int {
                                    completion(id, nil)
                                } else {
//                                    completion(id, nil)
                                    completion(nil, nil)
                                }
                            case .failure(let error):
                                Crashlytics.sharedInstance().recordError(error)
                                completion(nil, error)
                            }
                        }
                        upload.uploadProgress { progress in
                            progressLabel.text = "\(Int(progress.fractionCompleted))"
                        }
                    case .failure(_):
                        completion(nil, nil)
                    }
            })
        }
    }

    func patchPost(_ id:Int, location:String, lat: Float, long: Float, text:String, tags: String, completion: @escaping FeedSuccesResponse) {
        let router = FeedRouter(endpoint: .finishPost(id:id, location:location, lat:lat, long:long, text:text, tags: tags))
        
        authenticateRequestWithRouter(router) { (result, dict, error) in
            if result {
                completion(true, error)
            } else {
                completion(false, error)
            }
        }
    }
    
    func getPost(_ id: Int, completion: @escaping PostResponseBlock) {
        let router = FeedRouter(endpoint: .getPost(id: id))
        
        authenticateRequestWithRouter(router) { (result, dict, error) in
            if result, let userDict = dict as? [String:AnyObject] {
                let post = Posts(dictionary: userDict)
                completion(post, nil)
            } else {
                completion(nil, error)
            }
        }
    }
}
