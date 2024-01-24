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

class AppDelegate: NSObject, UIApplicationDelegate {
	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
		FirebaseManager.shared.launch()
		Task {
			try await FirebaseManager.shared.requestNotificationAuthorization()
		}

        return true
    }

	func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
		print(error)
	}
}
