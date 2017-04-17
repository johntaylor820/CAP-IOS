//
//  MeViewController.swift
//  Capture
//
//  Created by Mathias Palm on 2016-04-22.
//  Copyright © 2016 capture. All rights reserved.
//

import UIKit
import AVFoundation
import Alamofire

class MeViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, EditMeViewControllerDelegate {

    @IBOutlet weak var editMeButton: UIBarButtonItem!
    
    @IBOutlet weak var meVideosCollectionView: UICollectionView!
    
    let screenWidht = UIScreen.main.bounds.width
    let layout = UserCollectionFlowLayout()

    var user:User?
    
    var headerHeight:CGFloat! {
        didSet {
            layout.headerReferenceSize = CGSize(width: screenWidht, height: headerHeight)
        }
    }
    
    var passId:Int?
    var passImg:UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if user == nil {
            user = UserManager.sharedInstance.user
        }
        headerHeight = view.frame.size.height * 0.3
        NotificationCenter.default.addObserver(self, selector: #selector(refresh), name: NSNotification.Name(rawValue: "newPost"), object: nil)
        layout.headerReferenceSize = CGSize(width: screenWidht, height: headerHeight)
        meVideosCollectionView.setCollectionViewLayout(layout, animated: false)
        meVideosCollectionView.reloadData()
    }
    func refresh(_ sender: AnyObject) {
        UserManager.sharedInstance.getCurrentUser() { (user, _) in
            if let user = user {
                self.user = user
                self.meVideosCollectionView.reloadData()
            }
        }
    }
    func refreshInfo(_ profilePic:Bool, bg:Bool) {
        hitRefresh()
    }
    func hitRefresh() {
        user = UserManager.sharedInstance.user
        self.meVideosCollectionView.reloadData()
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showPost" {
            let navVC = segue.destination as! UINavigationController
            let vc = navVC.viewControllers.first as! PostViewController
            vc.postThumb = passImg
            vc.postID = passId
        } else if segue.identifier == "editSegue" {
            let navVC = segue.destination as! UINavigationController
            let vc = navVC.viewControllers.first as! EditMeViewController
            if let user = user {
                vc.user = user
            } else {
                UserManager.sharedInstance.getCurrentUser({ user, error in
                    DispatchQueue.main.async(execute: {
                        vc.user = user
                    })
                })
            }
            vc.delegate = self
        }
    }

    @IBAction func editButtonPresesd(_ sender: AnyObject) {
        performSegue(withIdentifier: "editSegue", sender: nil)
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
                    cell.thumb = post.videoThumb
                    cell.postID = post.id
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
