//
//  PresentAnimator.swift
//  Filterlapse
//
//  Created by Mathias Palm on 2015-06-04.
//  Copyright (c) 2015 Mathias Palm. All rights reserved.
//

import UIKit

class PresentAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    let screenWidth = UIScreen.main.bounds.width
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let container = transitionContext.containerView
        let screens : (from:UIViewController, to:UIViewController) = (transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)!, transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)!)
        
        let fromViewController = screens.from as UIViewController
        let toView = screens.to.view
        
        let fromSnapshotView = fromViewController.view.resizableSnapshotView(from: fromViewController.view.frame, afterScreenUpdates: true, withCapInsets: UIEdgeInsets.zero)
        container.addSubview(fromSnapshotView!)
        container.addSubview(toView!)
        var fromFrame = fromSnapshotView?.frame
        var toFrame = toView?.frame
        toFrame?.origin.x = screenWidth
        toView?.frame = toFrame!
        fromFrame?.origin.x = -screenWidth
        toFrame?.origin.x = 0
        UIView.animate(withDuration: self.transitionDuration(using: transitionContext), animations: {
            fromSnapshotView?.frame = fromFrame!
            toView?.frame = toFrame!
            }, completion: { (value:Bool) in
                transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)?.view.layer.mask = nil
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }
}
