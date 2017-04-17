//
//  FeedViewController.swift
//  Capture
//
//  Created by Mathias Palm on 2016-04-10.
//  Copyright © 2016 capture. All rights reserved.
//

import UIKit
import Alamofire

class MainFeedViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UITextViewDelegate {

    let screenWidth = UIScreen.main.bounds.width
    let screenHeight = UIScreen.main.bounds.height
    
    var refreshControl: UIRefreshControl!
    
    @IBOutlet weak var emptyFeedView: UIView!
    var posts = [Posts]()
    var atEnd = false
    
    var currentPostId: Int?
    var page = 1
    var userIdToPass:Int?
    var usernameToPass:String?
    var userID = 0
    
    @IBOutlet weak var mainFeedCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let user = UserManager.sharedInstance.user {
            userID = user.id
        } else {
            UserManager.sharedInstance.getCurrentUser() { user, _ in
                if let user = user {
                    self.userID = user.id
                }
            }
        }
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(MeViewController.refresh(_:)), for: UIControlEvents.valueChanged)
        mainFeedCollectionView.addSubview(self.refreshControl)
        getFeed(page)
        NotificationCenter.default.addObserver(self, selector: #selector(newPost(_:)), name: NSNotification.Name(rawValue: "newPost"), object: nil)
    }
    func refresh(_ sender: AnyObject) {
        getPageOne()
    }
    func newPost(_ sender:Notification) {
        getPageOne()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }

    func getPageOne() {
        page = 1
        atEnd = false
        posts.removeAll()
        mainFeedCollectionView.reloadData()
        mainFeedCollectionView.setContentOffset(CGPoint.zero, animated: false)
        FeedManager.sharedInstance.resetPosts()
        getFeed(page)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    // MARK: - Data Source
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var num = 4
        if section == posts.count-1 {
            num = 3
        }
        return num
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if (indexPath as NSIndexPath).item == (posts.count-1) && !atEnd {
            getFeed(page)
        }
        let cell: UICollectionViewCell
        let row = (indexPath as NSIndexPath).row
        if posts.count > (indexPath as NSIndexPath).section {
            let post = posts[(indexPath as NSIndexPath).section]
            switch row {
            case 0:
                cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FeedItem", for: indexPath) as! FeedItem
                cell.layer.shouldRasterize = true
                cell.layer.rasterizationScale = UIScreen.main.scale
                cell.contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                cell.contentView.frame = cell.bounds
                if let c = cell as? FeedItem {
                    if let user = post.user {
                        if userID == user.id {
                            c.isUser = true
                        } else {
                            c.isUser = false
                        }
                        c.userId = user.id
                        c.delegate = self
                        c.image = user.profileImage
                        c.name = user.fullName
                        c.username = user.username
                    }
                    c.setupTimeAndLocation(post.date, location: post.location)
                    c.thumb = post.videoThumb
                    if let file = post.file {
                        c.setupPlayer(file)
                    }
                    c.postId = post.id
                }
            case 1:
                cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UtilsItem", for: indexPath) as! UtilsItem
                if let u = cell as? UtilsItem {
                    if let user = post.user {
                        if userID == user.id {
                            u.isUser = true
                        } else {
                            u.isUser = false
                        }
                    }
                    u.delegate = self
                    u.likes = post.likesCount
                    u.comments = post.commentCount
                    u.postId = post.id
                    u.userLikes = post.userLikes
                }
            case 2:
                cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TextItem", for: indexPath) as! TextItem
                if let t = cell as? TextItem {
                    t.setPostLabel(post.postText)
                }
            default:
                cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Comp", for: indexPath)
            }
        } else {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Comp", for: indexPath)
        }
        cell.layer.shouldRasterize = true
        cell.layer.rasterizationScale = UIScreen.main.scale
        cell.contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        cell.contentView.frame = cell.bounds
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        var size = CGSize(width: screenWidth, height: screenWidth+50)
        let row = (indexPath as NSIndexPath).row
        switch row {
        case 1:
            //Utils Item Cell
            size.height = 58
        case 2:
            //Text Item Cell
            let font = UIFont(name: "HelveticaNeue", size: 17)!
            size.height = posts[(indexPath as NSIndexPath).section].postText.heightWithConstrainedWidth(screenWidth-20, font: font) + 40
            if size.height < 50 {size.height = 50}
        case 3:
            size.height = 28
        default:
            break
        }

        return size
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        if let cell = cell as? FeedItem {
            cell.play()
        }
    }
    @IBAction func findFriendsPressed(_ sender: UIButton) {
        tabBarController?.selectedIndex = 1
    }
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = cell as? FeedItem {
            cell.pause()
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "commentView" {
            let vc = segue.destination as! CommentViewController
            vc.postID = currentPostId!
        } else if segue.identifier == "showUser" {
            let vc = segue.destination as! UserViewController
            if let id = userIdToPass {
                vc.userId = id
            }
            vc.username = usernameToPass
        }
    }
}

extension MainFeedViewController: UtilsItemDelegate, FeedItemDelegate, TextItemDelegate {
    func reportButtonPressed(_ postId: Int) {
        let optionMenu = UIAlertController(title: nil, message: "If you found this post to be inappropriate, and violate our policies, please report it below:", preferredStyle: .actionSheet)
        let deleteAction = UIAlertAction(title: "Report Video", style: .destructive, handler: {
            (alert: UIAlertAction!) -> Void in
            ReportManager.sharedInstance.reportPost(postId)
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
            
        })
        optionMenu.addAction(deleteAction)
        optionMenu.addAction(cancelAction)
        
        DispatchQueue.main.async(execute: {
            self.present(optionMenu, animated: true, completion: nil)
        })
    }
    
    func isUserDeletePostPressed(_ postId: Int) {
        let optionMenu = UIAlertController(title: nil, message: "Are you sure you want to delete this post? This action cannot be undone.", preferredStyle: .actionSheet)
        let deleteAction = UIAlertAction(title: "Yes, Delete Video", style: .destructive, handler: {
            (alert: UIAlertAction!) -> Void in
            FeedManager.sharedInstance.deletePost(postId, completion: {success, error in
                if success {
                    DispatchQueue.main.async(execute: {
                        NotificationCenter.default.post(name: Notification.Name(rawValue: "newPost"), object: nil)
                    })
                }
            })
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
            
        })
        optionMenu.addAction(deleteAction)
        optionMenu.addAction(cancelAction)
        
        DispatchQueue.main.async(execute: {
            self.present(optionMenu, animated: true, completion: nil)
        })
    }
    
    func commentButtonPressed(_ postId: Int) {
        currentPostId = postId
        performSegue(withIdentifier: "commentView", sender: nil)
    }
    func userPressed(_ id: Int) {
        if id == UserManager.sharedInstance.user!.id {
            tabBarController?.selectedIndex = 4
        } else {
            userIdToPass = id
            performSegue(withIdentifier: "showUser", sender: nil)
        }
    }
    func userByUserName(_ name: String) {
        usernameToPass = name
        performSegue(withIdentifier: "showUser", sender: nil)
    }
}

extension MainFeedViewController {
    func getFeed(_ page: Int) {
        FeedManager.sharedInstance.feed(page, completion: { posts, error in
            guard posts != nil && error == nil else {
                self.atEnd = true
                self.emptyFeedView.isHidden = self.posts.count > 0
                return
            }
            DispatchQueue.main.async(execute: {
                self.page += 1
                self.posts = posts!
                self.refreshControl.endRefreshing()
                self.mainFeedCollectionView.reloadData()
            })
        })
    }
    @IBAction func refreshBarButtonPressed(_ sender: UIBarButtonItem) {
        getPageOne()
    }
    @IBAction func searchBarButtonPressed(_ sender: UIBarButtonItem) {
        tabBarController?.selectedIndex = 1
    }
}
