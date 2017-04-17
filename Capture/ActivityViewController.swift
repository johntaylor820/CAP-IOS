//
//  ActivityViewController.swift
//  Capture
//
//  Created by Mathias Palm on 2016-04-25.
//  Copyright © 2016 capture. All rights reserved.
//

import UIKit

class ActivityViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var userIdToPass:Int?
    var isAtEnd = false
    
    let followImg = UIImage(named: "followImg")
    let commentImg = UIImage(named: "commentImg")
    let likeImg = UIImage(named: "likeImg")
    
    @IBOutlet weak var emptyScreenView: UIView!
    var activitys = [Activity]()

    @IBOutlet weak var activityTableView: UITableView!
    
    var refreshControl: UIRefreshControl!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        getActivitys()
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(ActivityViewController.refresh(_:)), for: UIControlEvents.valueChanged)
        activityTableView.addSubview(self.refreshControl)
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func ActicityEditPushed(_ sender: AnyObject) {
        performSegue(withIdentifier: "test", sender: nil)
    }
    
    func refresh(_ sender:AnyObject) {
        getActivitys()
    }
    // MARK: - Navigation
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

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return activitys.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 86.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "activityCell", for: indexPath) as! AcitivityTableViewCell
        let activity = activitys[(indexPath as NSIndexPath).row]
        if let from = activity.from {
            cell.startText()
            cell.username = from.username
            cell.userImgURL = from.profileImage
            cell.userID = from.id
            var taskText = ""
            var taskImg = UIImage()
            if let task = activity.task {
                switch task {
                case .follow:
                    taskText = " started following you"
                    taskImg = followImg!
                case .comment:
                    taskText = " left a comment on your video"
                    taskImg = commentImg!
                case .like:
                    taskText = " liked your video"
                    taskImg = likeImg!
                }
            }
            cell.taskImage = taskImg
            cell.taskText = taskText
            cell.finnishUpText()
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! AcitivityTableViewCell
        if let id = cell.userID, let user = UserManager.sharedInstance.user {
            if id != user.id {
                userPressed(id)
            }
        }
    }
    @IBAction func exploreButtonPressed(_ sender: AnyObject) {
        tabBarController?.selectedIndex = 1
    }
}

extension ActivityViewController: ActivityTableViewCellDelegate {
    func userPressed(_ id: Int) {
        userIdToPass = id
        performSegue(withIdentifier: "showUser", sender: nil)
    }
}

extension ActivityViewController {
    func getActivitys(_ page: Int = 0, refresh: Bool = false) {
        UserManager.sharedInstance.getActivity({ activitys, error in
            self.refreshControl.endRefreshing()
            if let activitys = activitys {
                if activitys.count == 0 {
                    self.emptyScreenView.isHidden = false
                } else {
                    self.emptyScreenView.isHidden = true
                }
            } else {
                if self.activitys.count == 0 {
                    self.emptyScreenView.isHidden = false
                } else {
                    self.emptyScreenView.isHidden = true
                }
            }
            guard activitys != nil && error == nil else {
                self.isAtEnd = true
                return
            }
            DispatchQueue.main.async(execute: {
                self.activitys = activitys!
                self.activityTableView.reloadData()
            })
        })

    }
}
