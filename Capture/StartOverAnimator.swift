//
//  StartOverAnimator.swift
//  Filterlapse
//
//  Created by Mathias Palm on 2015-06-04.
//  Copyright (c) 2015 Mathias Palm. All rights reserved.
//

import UIKit

class StartOverAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    let screenWidth = UIScreen.main.bounds.width
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let container = transitionContext.containerView
        let screens : (from:UIViewController, to:UIViewController) = (transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)!, transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)!)
        
        let fromViewController = screens.from as UIViewController
        let toView = screens.to.view
        
        let fromSnapshotView = fromViewController.view.resizableSnapshotView(from: fromViewController.view.frame, afterScreenUpdates: true, withCapInsets: UIEdgeInsets.zero)
        container.addSubview(toView!)
        container.addSubview(fromSnapshotView!)
        toView?.alpha = 0
        UIView.animate(withDuration: self.transitionDuration(using: transitionContext), animations: {
            toView?.alpha = 1
            fromSnapshotView?.alpha = 0
            }, completion: { (value:Bool) in
                transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)?.view.layer.mask = nil
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }
}
