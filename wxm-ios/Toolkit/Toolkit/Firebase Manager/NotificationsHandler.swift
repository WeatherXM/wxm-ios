//
//  NotificationsHandler.swift
//  Toolkit
//
//  Created by Pantelis Giazitsis on 18/1/24.
//

import Foundation
import FirebaseMessaging
import UIKit
import Combine

class NotificationsHandler: NSObject {
	let latestNotificationPublisher: AnyPublisher<UNNotificationResponse?, Never>

	private let latestNotificationSubject: CurrentValueSubject<UNNotificationResponse?, Never> = .init(nil)

	override init() {
		latestNotificationPublisher = latestNotificationSubject.eraseToAnyPublisher()
		super.init()
	}

	func requestNotificationAuthorization() async throws {
		UNUserNotificationCenter.current().delegate = self

		let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
		let granted = try await UNUserNotificationCenter.current().requestAuthorization(options: authOptions)
		if granted {
			await UIApplication.shared.registerForRemoteNotifications()
		}

		observeFCMToken()
	}

	func getFCMToken() async throws ->  String {
		try await Messaging.messaging().token()
	}

	func getAuthorizationStatus() async -> UNAuthorizationStatus {
		await withUnsafeContinuation { continuation in
			UNUserNotificationCenter.current().getNotificationSettings { settings in
				continuation.resume(returning: settings.authorizationStatus)
			}
		}
	}
}

private extension NotificationsHandler {
	private func observeFCMToken() {
		Messaging.messaging().delegate = self
	}
}

extension NotificationsHandler: UNUserNotificationCenterDelegate {
	func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
		completionHandler([.banner, .badge, .sound, .list])
	}

	func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
		latestNotificationSubject.send(response)
	}
}

extension NotificationsHandler: MessagingDelegate {
	func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
		print("Firebase registration token: \(String(describing: fcmToken))")
	}
}
