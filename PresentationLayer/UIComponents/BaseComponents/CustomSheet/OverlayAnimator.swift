//
//  OverlayAnimator.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 15/3/23.
//

import Foundation
import UIKit
import Toolkit

public class OverlayAnimator: NSObject, UIViewControllerAnimatedTransitioning, UIViewControllerTransitioningDelegate {

	var tapOutsideCallback: VoidCallback?
	private var tapGesture: UITapGestureRecognizer?
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
				toVC.view.translatesAutoresizingMaskIntoConstraints = false
                containerView.addSubview(toVC.view)
				toVC.view.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
				toVC.view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
				toVC.view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor).isActive = true
				toVC.view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor).isActive = true

				let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleContainerViewTap))
				containerView.addGestureRecognizer(tapGesture)
				self.tapGesture = tapGesture

                UIView.animate(withDuration: duration, delay: 0.0, options: .curveEaseIn) {
                    toVC.view.alpha = 1.0
                } completion: { _ in
                    transitionContext.completeTransition(true)
                }

            case false:
				if let tapGesture {
					containerView.removeGestureRecognizer(tapGesture)
				}

                UIView.animate(withDuration: duration, delay: 0.0, options: .curveEaseIn) {
                    fromVC.view.alpha = 0.0
                } completion: { _ in
                    fromVC.view.removeFromSuperview()
                    transitionContext.completeTransition(true)
                }
        }
    }

	@objc
	func handleContainerViewTap(gesture: UITapGestureRecognizer) {
		tapOutsideCallback?()
	}
}
