//
//  NavigationControllerDelegate.swift
//  Filterlapse
//
//  Created by Mathias Palm on 2015-06-04.
//  Copyright (c) 2015 Mathias Palm. All rights reserved.
//

import UIKit

class NavigationControllerDelegate: NSObject, UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if toVC is EditsViewController {
            return PresentAnimator()
        } else if toVC is FeedViewController && fromVC is EditsViewController {
            return EditAnimator()
        } else {
            return StartOverAnimator()
        }
    }
}
