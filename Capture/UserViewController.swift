//
//  UserViewController.swift
//  Capture
//
//  Created by Mathias Palm on 2016-05-10.
//  Copyright © 2016 capture. All rights reserved.
//

import UIKit
import AVFoundation

class UserViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var meVideosCollectionView: UICollectionView!
    @IBOutlet weak var followButton: UIBarButtonItem!
    let layout = UserCollectionFlowLayout()
    
    @IBOutlet weak var notificationView: NotificationView!
    @IBOutlet weak var notificationViewLabel: UILabel!
    @IBOutlet weak var notificationViewTopConstraint: NSLayoutConstraint!

    let screenWidht = UIScreen.main.bounds.width
    
    var user:User? {
        didSet {
            if let _ = user {
                setup()
                meVideosCollectionView.reloadData()
            }
        }
    }
    var userIsFollowed = false
    var userId:Int!
    var username:String?
    
    var headerHeight:CGFloat! {
        didSet {
            layout.headerReferenceSize = CGSize(width: screenWidht, height: headerHeight)

        }
    }
    
    var passId:Int?
    var passImg:UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = false
        
        if let username = username {
            getUserFromName(username)
        } else {
            downloadUserData()
        }
        headerHeight = view.frame.size.height * 0.3
        layout.headerReferenceSize = CGSize(width: screenWidht, height: headerHeight)
        meVideosCollectionView.setCollectionViewLayout(layout, animated: false)
        meVideosCollectionView.reloadData()
        notificationViewTopConstraint.constant = 100
        view.layoutIfNeeded()
        // Do any additional setup after loading the view.
    }

    func setup() {
        if let user = user {
            self.navigationController?.navigationBar.topItem?.title = user.getName()
            userIsFollowed = user.isFollowed
            if userIsFollowed {
                followButton.image = nil
                followButton.title = "Unfollow"
            } else {
                followButton.image = UIImage(named: "followicon")
                followButton.title = nil
            }
        }
    }


    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showPost" {
            let navVC = segue.destination as! UINavigationController
            let vc = navVC.viewControllers.first as! PostViewController
            vc.postThumb = passImg
            vc.postID = passId!
        }
    }
    
    @IBAction func popButtonPressed(_ sender: UIBarButtonItem) {
        _ = navigationController?.popViewController(animated: true)
    }
    func getUserFromName(_ name: String) {
        SearchManager.sharedInstance.getUserForName(name , completion: { user, error in
            if let user = user {
                self.user = user
                self.userId = user.id
            }
        })
    }
    func downloadUserData() {
        UserManager.sharedInstance.getUser(userId, completion: {user, error in
            if let user = user {
                self.user = user
            }
        })
    }
    func refresh(_ sender:AnyObject) {
        downloadUserData()
    }
    @IBAction func followUserPressed(_ sender: AnyObject) {
        followButton.isEnabled = false
        if userIsFollowed {
            UserManager.sharedInstance.unFollowUser(self.userId, completion: {success, error in
                if success {
                    DispatchQueue.main.async(execute: {
                        self.downloadUserData()
                        self.animateNotification("You have unfollowed \(self.user!.getName())")
                    })
                }
            })
        } else {
            UserManager.sharedInstance.followUser(self.userId!, completion: {success, error in
                if success {
                    DispatchQueue.main.async(execute: {
                        self.downloadUserData()
                        self.animateNotification("You are now following \(self.user!.getName())")
                    })
                }
            })
        }
    }
    
    func animateNotification(_ name:String) {
        notificationViewLabel.text = name
        notificationViewTopConstraint.constant = 100
        notificationView.layoutIfNeeded()
        notificationViewTopConstraint.constant = 4
        UIView.animate(withDuration: 0.3, delay: 0.0, options: UIViewAnimationOptions(), animations: {
            self.notificationView.layoutIfNeeded()
            }, completion: {finnished in
            UIView.animate(withDuration: 0.3, delay: 1.5, options: UIViewAnimationOptions(), animations: {
                self.notificationViewTopConstraint.constant = 100
                self.notificationView.layoutIfNeeded()
                }, completion: {
                    f in
                    self.followButton.isEnabled = true
            })
        })
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            if let user = user, let post = user.post {
                return post.count
            }
        }
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: UICollectionViewCell!
        if (indexPath as NSIndexPath).section == 0 {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "followersCell", for: indexPath) as! MeFollowersCollectionViewCell
            if let cell = cell as? MeFollowersCollectionViewCell {
                if let user = user {
                    cell.delegate = self
                    cell.videos = user.post?.count
                    cell.followers = user.followers
                    cell.following = user.following
                }
            }
        } else {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "meViewCell", for: indexPath) as! MyCollectionViewCell
            if let cell = cell as? MyCollectionViewCell {
                if let user = user, let posts = user.post {
                    if (indexPath as NSIndexPath).row + 2 == posts.count && 10 % posts.count != 0 {
                        // TODO GET PAGE
                    }
                    let post = posts[(indexPath as NSIndexPath).row]
                    cell.postID = post.id
                    cell.thumb = post.videoThumb
                    
                }
            }
        }
        cell.contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        cell.contentView.frame = cell.bounds
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if (indexPath as NSIndexPath).section == 0 {
            switch kind {
            case UICollectionElementKindSectionHeader:
                let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "meHeaderView", for: indexPath) as! MeHeaderCollectionReusableView
                if let user = user {
                    headerView.setProfileImg(user.profileImage)
                    headerView.setBackgroundImg(user.profileBackgroundImage)
                    headerView.name = user.getName()
                    headerView.website = user.website
                    headerView.info = user.info
                    headerView.location = user.location
                    headerView.setHeight(headerHeight)
                }
                return headerView
            default:
                assert(false, "Unexpected element kind")
            }
        }
        return UICollectionReusableView()
    }
    
    var cellPlaying:IndexPath?
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        if let cell = cell as? MyCollectionViewCell {
            if let img = cell.videoImageView.image {
                passImg = img
            }
            if let id = cell.postID {
                passId = id
                performSegue(withIdentifier: "showPost", sender: nil)
            }
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        if section == 0 {
            return UIEdgeInsetsMake(0, 0, 0, 0)
        }
        return UIEdgeInsetsMake(10, 10, 10, 10)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if section == 0 {
            var bioHeight:CGFloat = 0
            if let user = user {
                bioHeight = user.info.heightWithConstrainedWidth(collectionView.frame.size.width, font: UIFont(name: "HelveticaNeue-Light", size: 15)!)
            }
            headerHeight = view.frame.size.height * 0.3 + bioHeight
            return CGSize(width: collectionView.frame.size.width, height: headerHeight)
        }
        return CGSize.zero
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        var widht = (collectionView.frame.size.width - 30) / 2
        var height:CGFloat = widht
        if (indexPath as NSIndexPath).section == 0 {
            widht = collectionView.frame.size.width
            height = 68
        }
        return CGSize(width: widht, height: height)
    }
}
extension UserViewController: FollowersCellDelegate {
    func reportUserButtonPressed() {
        let optionMenu = UIAlertController(title: nil, message: "If you found this user to be inappropriate, and violate our policies, please report it below:", preferredStyle: .actionSheet)
        let deleteAction = UIAlertAction(title: "Report User", style: .destructive, handler: {
            (alert: UIAlertAction!) -> Void in
            if let id = self.userId {
                ReportManager.sharedInstance.reportUser(id)
            }
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
}
