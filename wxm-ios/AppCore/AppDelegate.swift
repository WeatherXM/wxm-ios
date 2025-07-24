//
//  AppDelegate.swift
//  wxm-ios
//
//  Created by Hristos Condrea on 6/5/22.
//

import Combine
import Foundation
import Toolkit
import UIKit
import Network

class AppDelegate: NSObject, UIApplicationDelegate {

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
		// Fixe the crash in iOS 26
		nw_tls_create_options()

		FirebaseManager.shared.launch()

		if let mixpanelToken: String = Bundle.main.getConfiguration(for: .mixpanelToken) {
			WXMAnalytics.shared.launch(with: [.firebase, .mixpanel(mixpanelToken)])
		}

		return true
    }

	func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
		print(error)
	}

	func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
		FirebaseManager.shared.setApnsToken(deviceToken)
	}
}
