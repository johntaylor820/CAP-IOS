//
//  MainTabBarViewController.swift
//  Capture
//
//  Created by Mathias Palm on 2016-04-11.
//  Copyright © 2016 capture. All rights reserved.
//

import UIKit

class MainTabBarViewController: UITabBarController, UITabBarControllerDelegate, UINavigationControllerDelegate {

    var b:UIButton!
    var orginalFrame:CGRect!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        self.tabBar.isTranslucent = false
        
        print(UserManager.sharedInstance.accessToken)
        
        self.tabBar.tintColor = UIColor(red: 3/255, green: 167/255, blue: 227/255, alpha: 1.0)
        var i = 0
        if let tabbar = self.tabBar.items  {
            for item in tabbar {
                item.title = ""
                if item.tag == 2 {
                    let image = UIImage(named: "camera")!
                    b = UIButton()
                    b.frame = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
                    b.setImage(image, for: UIControlState())
                    b.setImage(image, for: .highlighted)
                    b.addTarget(self, action: #selector(addPostPressed(_:)), for: .touchUpInside)
                    var center = self.tabBar.center
                    center.y = center.y - 4
                    b.center = center
                    b.layer.zPosition = 1
                    self.view.addSubview(b)
                    orginalFrame = b.frame
                }
                if let image = item.image {
                    item.image = image.withRenderingMode(.alwaysOriginal)
                }
                i += 1
            }
        }
    }
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if let title = viewController.title {
            if title == "EditsFeedNavigation" {
                addPostPressed(UIButton())
                return false
            }
        }
        return true
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

    }
    func hideButton() {
        b.isUserInteractionEnabled = false
        var frame = b.frame
        frame.origin.x = frame.origin.x - frame.origin.x / 4
        self.b.isHidden = true
        UIView.animate(withDuration: 0.2, animations: {
            self.b.frame = frame
            self.b.alpha = 0
        })
    }
    func showButton() {
        b.isUserInteractionEnabled = true
        self.b.isHidden = false
        UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseIn, animations: {
            self.b.frame = self.orginalFrame
            self.b.alpha = 1
            self.view.bringSubview(toFront: self.b)
            }, completion:nil)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func addPostPressed(_ sender:AnyObject) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let actualController = storyboard.instantiateViewController(withIdentifier: "FeedViewController") as! UINavigationController
        present(actualController, animated: true, completion: nil)
    }
    
    // MARK: - Navigation

    
}

