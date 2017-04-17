//
//  IntroPageViewController.swift
//  Capture
//
//  Created by Mathias Palm on 2016-07-12.
//  Copyright © 2016 capture. All rights reserved.
//

import UIKit

protocol IntroPageViewControllerDelegate {
    
    func introPageViewController(_ introPageViewController: IntroPageViewController, didUpdatePageCount count: Int)
    
    func introPageViewController(_ introPageViewController: IntroPageViewController, didUpdatePageIndex index: Int)
    
}

class IntroPageViewController: UIPageViewController {
    
    var introDelegate: IntroPageViewControllerDelegate?
    
    fileprivate(set) lazy var orderedViewControllers: [UIViewController] = {
        // The view controllers will be shown in this order
        return [self.newViewController(1),
                self.newViewController(2),
                self.newViewController(3)]
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = self
        delegate = self
        
        if let initialViewController = orderedViewControllers.first {
            scrollToViewController(initialViewController)
        }
        
        introDelegate?.introPageViewController(self, didUpdatePageCount: orderedViewControllers.count)
    }
    
    func scrollToNextViewController() {
        if let visibleViewController = viewControllers?.first,
            let nextViewController = pageViewController(self,
                                                        viewControllerAfter: visibleViewController) {
            scrollToViewController(nextViewController)
        }
    }

    func scrollToViewController(index newIndex: Int) {
        if let firstViewController = viewControllers?.first,
            let currentIndex = orderedViewControllers.index(of: firstViewController) {
            let direction: UIPageViewControllerNavigationDirection = newIndex >= currentIndex ? .forward : .reverse
            let nextViewController = orderedViewControllers[newIndex]
            scrollToViewController(nextViewController, direction: direction)
        }
    }
    
    fileprivate func newViewController(_ num: Int) -> UIViewController {
        return UIStoryboard(name: "Intro", bundle: nil).instantiateViewController(withIdentifier: "\(num)ViewController")
    }
    
    fileprivate func scrollToViewController(_ viewController: UIViewController, direction: UIPageViewControllerNavigationDirection = .forward) {
        setViewControllers([viewController], direction: direction, animated: true, completion: { (finished) -> Void in
            self.notifyIntroDelegateOfNewIndex()
        })
    }
    
    fileprivate func notifyIntroDelegateOfNewIndex() {
        if let firstViewController = viewControllers?.first,
            let index = orderedViewControllers.index(of: firstViewController) {
            introDelegate?.introPageViewController(self, didUpdatePageIndex: index)
        }
    }


}

// MARK: UIPageViewControllerDataSource

extension IntroPageViewController: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else {
            return nil
        }
        let previousIndex = viewControllerIndex - 1

        guard previousIndex >= 0 else {
            return orderedViewControllers.last
        }
        
        guard orderedViewControllers.count > previousIndex else {
            return nil
        }
        
        return orderedViewControllers[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        let orderedViewControllersCount = orderedViewControllers.count
        
        guard orderedViewControllersCount != nextIndex else {
            return orderedViewControllers.first
        }
        
        guard orderedViewControllersCount > nextIndex else {
            return nil
        }
        
        return orderedViewControllers[nextIndex]
    }
    
}

extension IntroPageViewController: UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        notifyIntroDelegateOfNewIndex()
    }
    
}

