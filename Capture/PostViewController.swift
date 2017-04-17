//
//  PostViewController.swift
//  Capture
//
//  Created by Mathias Palm on 2016-06-30.
//  Copyright © 2016 capture. All rights reserved.
//

import UIKit

class PostViewController: UIViewController {

    @IBOutlet weak var profileImageView: CircularImageViewWithOutBorder!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var timeAndLocationLabel: ShadowLabel!
    
    @IBOutlet weak var postCollectionView: UICollectionView!
    
    let screenWidth = UIScreen.main.bounds.width
    
    var post:Posts?
    var comments = [Comments]()
    var isAtEnd = false
    var postID:Int? {
        didSet {
            if let postID = postID {
                getPostFromId(postID)
            }
        }
    }
    var page = 1
    var postThumb: UIImage?
    var userIdToPass:Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.isNavigationBarHidden = true
        // Do any additional setup after loading the view.
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func getPostFromId(_ id: Int) {
        FeedManager.sharedInstance.getPost(id, completion: { post, error in
            guard post != nil && error == nil else {
                debugPrint(error)
                return
            }
            DispatchQueue.main.async(execute: {
                self.post = post!
                self.postCollectionView.reloadData()
                self.setupTimeAndLocation()
            })
        })
        getComments(page)
    }
    func getComments(_ page: Int, refresh: Bool = false) {
        if let id = postID {
            CommentManager.sharedInstance.getComments(id, page: page, completion: { comments, error in
                guard comments != nil && error == nil else {
                    debugPrint(error)
                    self.isAtEnd = true
                    return
                }
                if refresh {
                    self.comments = comments!
                } else {
                    self.storeComments(comments!)
                }
                DispatchQueue.main.async(execute: {
                    self.postCollectionView.reloadData()
                })
            })
        }
    }
    fileprivate func storeComments(_ newComments: [Comments]) {
        for comment in newComments {
            comments.append(comment)
        }
        
    }
    func setupTimeAndLocation() {
        if let user = post!.user {
            nameLabel.text = user.getName()
        }
        let date = post!.date
        let location = post!.location
        var text = NSMutableAttributedString(string: "")
        if let date = date {
            text = NSMutableAttributedString(string: date.getElapsedInterval())
        }
        if location.characters.count > 0 {
            let attachment = NSTextAttachment()
            attachment.image = UIImage(named: "locationdotpost")
            text.append(NSAttributedString(attachment: attachment))
            text.append(NSMutableAttributedString(string: location))
        }
        timeAndLocationLabel.attributedText = text
    }
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "commentView" {
            let vc = segue.destination as! CommentViewController
            if let id = postID {
                vc.postID = id
            }
        } else if segue.identifier == "showUser" {
            let vc = segue.destination as! UserViewController
            if let id = userIdToPass {
                vc.userId = id
            } else {
                return
            }
        }
    }
    @IBAction func closeButtonPressed(_ sender: UIButton) {
        let cells = postCollectionView.visibleCells
        for cell in cells {
            if let cell = cell as? PostVideoCell {
                cell.pause()
            }
        }
        dismiss(animated: true, completion: nil)
    }

}
extension PostViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let _ = post {
            return comments.count + 3
        }
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: UICollectionViewCell
        let row = (indexPath as NSIndexPath).row
        if row + 2 == comments.count && !isAtEnd {
            page += 1
            getComments(page)
        }
        switch row {
        case 0:
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PostItem", for: indexPath) as! PostVideoCell
            if let c = cell as? PostVideoCell, let post = post {
                if let postThumb = postThumb {
                    c.thumb = postThumb
                } else {
                    c.loadThumbFromString(post.videoThumb)
                }
                if let file = post.file {
                    c.setupPlayer(file)
                }
                c.postId = post.id
            }
        case 1:
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UtilsItem", for: indexPath) as! UtilsItem
            if let u = cell as? UtilsItem, let post = post {
                u.delegate = self
                u.likes = post.likesCount
                u.comments = post.commentCount
                u.postId = post.id
                u.userLikes = post.userLikes
            }
        case 2:
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TextItem", for: indexPath) as! TextItem
            if let t = cell as? TextItem, let post = post {
                t.setPostLabel(post.postText)
            }
        default:
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CommentCell", for: indexPath) as! PostCommentCell
            if let c = cell as? PostCommentCell {
                let comment = comments[row - 3]
                if let user = comment.user {
                    c.userID = user.id
                    c.name = user.username
                }
                c.comment = comment.text
                c.finnishComment()
            }
        }
        cell.contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        cell.contentView.frame = cell.bounds
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        var size = CGSize(width: screenWidth, height: screenWidth)
        let row = (indexPath as NSIndexPath).row
        switch row {
        case 0:
            size = CGSize(width: screenWidth, height: screenWidth)
        case 1:
            //Utils Item Cell
            size.height = 58
        case 2:
            //Text Item Cell
            let font = UIFont(name: "HelveticaNeue", size: 20)!
            size.height = post!.postText.heightWithConstrainedWidth(screenWidth-20, font: font)+10
            if size.height < 50 {size.height = 50}
        default:
            //Comment
            let comment = comments[row - 3]
            let font = UIFont(name: "HelveticaNeue", size: 20)!
            size.height = comment.text.heightWithConstrainedWidth(screenWidth-20, font: font)+10
            if size.height < 50 {size.height = 50}
        }
        return size
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        if let cell = cell as? PostVideoCell {
            cell.play()
        }
    }
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = cell as? PostVideoCell {
            cell.pause()
        }
    }
}

extension PostViewController: UtilsItemDelegate {
    func reportButtonPressed(_ postId: Int) {
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let deleteAction = UIAlertAction(title: "Report Video", style: .default, handler: {
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
        let alertController = UIAlertController(title: "Delete?", message: "Are you sure you want to delete this post? This action cannot be undone", preferredStyle: UIAlertControllerStyle.alert)
        let DestructiveAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) { (result : UIAlertAction) -> Void in
        }
        let okAction = UIAlertAction(title: "Delete", style: .destructive) { (result : UIAlertAction) -> Void in
            FeedManager.sharedInstance.deletePost(postId, completion: {success, error in
                if success {
                    DispatchQueue.main.async(execute: {
                        NotificationCenter.default.post(name: Notification.Name(rawValue: "newPost"), object: nil)
                        self.dismiss(animated: true, completion: nil)
                    })
                }
            })
        }
        alertController.addAction(DestructiveAction)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    func commentButtonPressed(_ postId: Int) {
        performSegue(withIdentifier: "commentView", sender: nil)
    }
}
