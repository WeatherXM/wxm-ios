//
//  OverlayAnimator.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 15/3/23.
//

import Foundation
import UIKit

public class OverlayAnimator: NSObject, UIViewControllerAnimatedTransitioning, UIViewControllerTransitioningDelegate {

    private var incoming = true
    private let duration = 0.15

    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        duration
    }

    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self
    }

    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        incoming = false
        return self
    }

    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {

        guard
            let fromVC = transitionContext.viewController(forKey: .from),
            let toVC = transitionContext.viewController(forKey: .to) else {
                return
            }

        let containerView = transitionContext.containerView

        switch incoming {
            case true:

                toVC.view.alpha = 0.0

                toVC.view.frame = containerView.bounds
                containerView.addSubview(toVC.view)

                UIView.animate(withDuration: duration, delay: 0.0, options: .curveEaseIn) {
                    toVC.view.alpha = 1.0
                } completion: { _ in
                    transitionContext.completeTransition(true)
                }

            case false:

                UIView.animate(withDuration: duration, delay: 0.0, options: .curveEaseIn) {
                    fromVC.view.alpha = 0.0
                } completion: { _ in
                    fromVC.view.removeFromSuperview()
                    transitionContext.completeTransition(true)
                }
        }
    }
}
