//
//  IntroViewController.swift
//  Capture
//
//  Created by Mathias Palm on 2016-07-12.
//  Copyright © 2016 capture. All rights reserved.
//

import UIKit

class IntroViewController: UIViewController {
    
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var containerView: UIView!
    
    var introPageViewController: IntroPageViewController? {
        didSet {
            introPageViewController?.introDelegate = self
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        pageControl.addTarget(self, action: #selector(IntroViewController.didChangePageControlValue), for: .valueChanged)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let introPageViewController = segue.destination as? IntroPageViewController {
            self.introPageViewController = introPageViewController
        }
    }
    
    @IBAction func didButton(_ sender: UIButton) {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            appDelegate.navigateToLogin(true)
        }
    }

//    override var prefersStatusBarHidden : Bool {
//        return true
//    }
    
    @IBAction func didTapSkipButton(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let loginVC = storyboard.instantiateViewController(withIdentifier: "loginVC") as! UINavigationController
        loginVC.modalTransitionStyle = .coverVertical
        loginVC.modalPresentationStyle = .fullScreen
        
        present(loginVC, animated: true, completion: nil)
        /*dispatch_async(dispatch_get_main_queue(), {
            
            //self.window?.rootViewController = introVC
        })*/
    }
    /**
     Fired when the user taps on the pageControl to change its current page.
     */
    func didChangePageControlValue() {
        introPageViewController?.scrollToViewController(index: pageControl.currentPage)
    }
}
extension IntroViewController: IntroPageViewControllerDelegate {
    
    func introPageViewController(_ introPageViewController: IntroPageViewController, didUpdatePageCount count: Int) {
        pageControl.numberOfPages = count
    }
    
    func introPageViewController(_ introPageViewController: IntroPageViewController, didUpdatePageIndex index: Int) {
        pageControl.currentPage = index
    }
    
}
