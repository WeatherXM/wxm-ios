//
//  UIKitUtils.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 8/3/23.
//

import UIKit
import Toolkit

extension Notification.Name {
	static let deviceDidShake = Notification.Name("deviceDidShake")
}


extension UIApplication {

    var currentKeyWindow: UIWindow? {
        UIApplication.shared.connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .map { $0 as? UIWindowScene }
            .compactMap { $0 }
            .first?.windows
            .filter { $0.isKeyWindow }
            .first
    }

    var rootViewController: UIViewController? {
        currentKeyWindow?.rootViewController
    }

    var topViewController: UIViewController? {
        var top = self.rootViewController
        while true {
            if let presented = top?.presentedViewController {
                top = presented
            } else if let nav = top as? UINavigationController {
                top = nav.visibleViewController
            } else if let tab = top as? UITabBarController {
                top = tab.selectedViewController
            } else {
                break
            }
        }
        return top
    }
}

extension UIWindow {
    func show() {
        guard let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? UIWindowSceneDelegate,
              let window = sceneDelegate.window,
              let currentScene = window?.windowScene else {
            return
        }

        windowScene = currentScene
        makeKeyAndVisible()
    }

    func dismiss() {
        isHidden = true
        windowScene = nil
    }

	open override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
		guard motion == .motionShake else {
			return
		}

		NotificationCenter.default.post(name: .deviceDidShake, object: nil)
	}
}

/// Used for keeping weak refs on hosting controllers
class HostingWrapper {
    weak var hostingController: UIViewController?
}
