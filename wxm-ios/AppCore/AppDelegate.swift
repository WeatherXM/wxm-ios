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
    func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
		FirebaseManager.shared.launch()
        return true
    }
}
