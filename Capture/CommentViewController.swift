//
//  CommentViewController.swift
//  Capture
//
//  Created by Mathias Palm on 2016-05-30.
//  Copyright © 2016 capture. All rights reserved.
//

import UIKit

class CommentViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {

    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var commentTextView: BioTextView!
    @IBOutlet weak var doneButton: AddCommentButton!
    
    @IBOutlet weak var bottomCommentViewContstraint: NSLayoutConstraint!
    @IBOutlet weak var heightCommentViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var doneButtonHeightConstraint: NSLayoutConstraint!
    
    let screenHeight = UIScreen.main.bounds.height
    let screenWidth = UIScreen.main.bounds.width
    
    @IBOutlet weak var commentTableView: UITableView!
    var refreshControl: UIRefreshControl!
    
    var comments: [Comments] = []
    var isAtEnd = false
    var postID = 0
    var page = 1
    var userIdToPass:Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let tabBarController = tabBarController {
            if let tabBarController = tabBarController as? MainTabBarViewController {
                tabBarController.hideButton()
            }
        }
        commentTextView.text = commentTextView.placeholderText
        commentTextView.textColor = commentTextView.placeholderColor
        let contentSize = commentTextView.sizeThatFits(commentTextView.bounds.size)
        heightCommentViewConstraint.constant = contentSize.height + 20
        doneButtonHeightConstraint.constant = contentSize.height
        view.layoutIfNeeded()
        
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(CommentViewController.refresh(_:)), for: UIControlEvents.valueChanged)
        commentTableView.addSubview(self.refreshControl)
        
        commentTextView.selectedTextRange = commentTextView.textRange(from: commentTextView.beginningOfDocument, to: commentTextView.beginningOfDocument)
        NotificationCenter.default.addObserver(self, selector: #selector(CommentViewController.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(CommentViewController.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        getComments(page)
        commentTableView.contentInset = UIEdgeInsetsMake(20, 0, 0, 0)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let tabBarController = tabBarController {
            if let tabBarController = tabBarController as? MainTabBarViewController {
                tabBarController.showButton()
            }
        }
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    @IBAction func didPressDoneButton(_ sender: AddCommentButton) {
        if commentTextView.text != commentTextView.placeholderText {
            let postText = commentTextView.text
            var tags = ""
            let separationCharacters = CharacterSet(charactersIn: " ")
            let wordArray = postText?.components(separatedBy: separationCharacters)
            for a in wordArray! {
                if a.characters.first == "#" {
                    let a1 = a.substring(from: a.characters.index(a.startIndex, offsetBy: 1))
                    tags = "\(tags)\(a1) "
                }
            }
            if tags.characters.count > 1 {
                tags = tags.substring(to: tags.characters.index(tags.endIndex, offsetBy: -1))
            }
            doneButton.startLoading()
            addComment(commentTextView.text, tags: tags)
        }
    }
    func refresh(_ sender: AnyObject) {
        getPageOne()
    }
    func getPageOne() {
        page = 1
        isAtEnd = false
        comments.removeAll()
        getComments(page, refresh: true)
    }
    fileprivate func storeComments(_ newComments: [Comments]) {
        for comment in newComments {
            if !comments.contains(comment) {
                comments.append(comment)
            }
        }

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showUser" {
            let vc = segue.destination as! UserViewController
            if let id = userIdToPass {
                vc.userId = id
            } else {
                return
            }
        }
    }
    
    // MARK: - Table View
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let font = UIFont(name: "HelveticaNeue", size: 20)!
        var height = comments[(indexPath as NSIndexPath).row].text.heightWithConstrainedWidth(screenWidth/3*2, font: font) + 45
        if height < 80 {height = 80}
        return height
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = (indexPath as NSIndexPath).row
        if row + 2 == comments.count && !isAtEnd {
            page += 1
            getComments(page)
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "commentCell", for: indexPath) as! CommentTableViewCell
        let comment = comments[row]
        if let user = comment.user {
            cell.delegate = self
            cell.userID = user.id
            cell.name = user.getName()
            cell.imgURL = user.profileImage
            cell.comment = comment.text
            cell.commentId = comment.id
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath) as! CommentTableViewCell
        if let id = cell.userID, let user = UserManager.sharedInstance.user {
            if id == user.id {
                cell.isSelected = true
                let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                let deleteAction = UIAlertAction(title: "Delete", style: .default, handler: {
                    (alert: UIAlertAction!) -> Void in
                    cell.isSelected = false
                    self.deleteComment(cell.commentId!)
                })
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
                    (alert: UIAlertAction!) -> Void in
                    cell.isSelected = false
                })
                optionMenu.addAction(deleteAction)
                optionMenu.addAction(cancelAction)
                
                DispatchQueue.main.async(execute: {
                    self.present(optionMenu, animated: true, completion: nil)
                })
            } else {
                userPressed(id)
            }
        }
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if self.commentTextView.isFirstResponder {
            self.commentTextView.resignFirstResponder()
        }
    }
    @IBAction func homeButtonPressed(_ sender: UIBarButtonItem) {
        _ = navigationController?.popViewController(animated: true)
    }
}
extension CommentViewController: CommentTableViewCellDelegate {
    func userPressed(_ id: Int) {
        if id == UserManager.sharedInstance.user!.id {
            tabBarController?.selectedIndex = 4
        } else {
            userIdToPass = id
            performSegue(withIdentifier: "showUser", sender: nil)
        }
    }
}
extension CommentViewController {
    func getComments(_ page: Int, refresh: Bool = false) {
        CommentManager.sharedInstance.getComments(postID, page: page, completion: { comments, error in
            guard comments != nil && error == nil else {
                self.isAtEnd = true
                return
            }
            if refresh {
                self.comments = comments!
            } else {
                self.storeComments(comments!)
            }
            DispatchQueue.main.async(execute: {
                self.refreshControl.endRefreshing()
                self.commentTableView.reloadData()
            })
        })
    }
    func deleteComment(_ commentID: Int) {
        CommentManager.sharedInstance.deleteComment(commentID, completion: { success, error in
            if success {
                self.commentTableView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
                self.getPageOne()
            }
        })
    }
    func addComment(_ comment: String, tags: String) {
        CommentManager.sharedInstance.commentPost(postID, comment: comment, tags: tags, completion: {success, error in
            self.doneButton.stopLoading()
            self.commentTextView.resignFirstResponder()
            if success {
                self.commentTableView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
                self.commentTextView.text = ""
                self.getPageOne()
            }
        })
    }
}

extension CommentViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let currentText:NSString = textView.text as NSString
        let updatedText = currentText.replacingCharacters(in: range, with:text)
        if updatedText.isEmpty {
            
            textView.text = commentTextView.placeholderText
            textView.textColor = commentTextView.placeholderColor
            doneButton.isEnabled = false
            textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
            
            return false
        }

        else if textView.textColor == commentTextView.placeholderColor && !text.isEmpty {
            textView.text = nil
            textView.textColor = UIColor.black
            doneButton.isEnabled = true
        }
        
        return true
    }
    func textViewDidChangeSelection(_ textView: UITextView) {
        if self.view.window != nil {
            if textView.textColor == commentTextView.placeholderColor {
                textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
            }
            let contentSize = textView.sizeThatFits(textView.bounds.size)
            heightCommentViewConstraint.constant = contentSize.height + 20
            view.layoutIfNeeded()
        }
    }
    func keyboardWillShow(_ notification: Notification) {
        if let userInfo = (notification as NSNotification).userInfo {
            let keyboardHeight = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.height
            let animationDurarion = userInfo[UIKeyboardAnimationDurationUserInfoKey] as! TimeInterval
            setTextViewBottomMargin(keyboardHeight, animationDurarion: animationDurarion)
        }
    }
    func keyboardWillHide(_ notification: Notification) {
        if let userInfo = (notification as NSNotification).userInfo {
            let animationDurarion = userInfo[UIKeyboardAnimationDurationUserInfoKey] as! TimeInterval
            setTextViewBottomMargin(0, animationDurarion: animationDurarion)
        }
    }
    
    func setTextViewBottomMargin(_ margin: CGFloat, animationDurarion: TimeInterval) {
        bottomCommentViewContstraint.constant = margin
        UIView.animate(withDuration: animationDurarion, animations: {
            self.view.layoutIfNeeded()
        })
    }

}
