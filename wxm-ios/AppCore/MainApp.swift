//
//  MainApp.swift
//  MainApp
//
//  Created by Hristos Condrea on 6/5/22.
//

import Alamofire
import Combine
import DataLayer
import DomainLayer
import IQKeyboardManagerSwift
import Network
import SwiftUI

@main
enum MainApp {
    static func main() {
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = false
        IQKeyboardManager.shared.shouldShowToolbarPlaceholder = false
        IQKeyboardManager.shared.previousNextDisplayMode = IQPreviousNextDisplayMode.default
        IQKeyboardManager.shared.keyboardDistanceFromTextField = 20
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
        MyNewUI.main()
    }
}

struct MyNewUI: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var mainScreen: MainScreen

    init() {
        let swinjectHelper = SwinjectHelper.shared
        mainScreen = MainScreen(swinjectHelper: swinjectHelper)
    }

    var body: some Scene {
        WindowGroup {
            mainScreen
        }
    }
}
