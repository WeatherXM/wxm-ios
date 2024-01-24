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
	let authorizationStatusPublisher: AnyPublisher<UNAuthorizationStatus?, Never>
	
	private let latestNotificationSubject: PassthroughSubject<UNNotificationResponse?, Never> = .init()
	private let authorizationStatusSubject: CurrentValueSubject<UNAuthorizationStatus?, Never> = .init(nil)
	private var cancellableSet: Set<AnyCancellable> = .init()

	override init() {
		latestNotificationPublisher = latestNotificationSubject.eraseToAnyPublisher()
		authorizationStatusPublisher = authorizationStatusSubject.eraseToAnyPublisher()
		super.init()
		UNUserNotificationCenter.current().delegate = self
		observeAuthorizationStatus()
	}

	func requestNotificationAuthorization() async throws {
		let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
		let granted = try await UNUserNotificationCenter.current().requestAuthorization(options: authOptions)
		if granted {
			await UIApplication.shared.registerForRemoteNotifications()
		}

		observeFCMToken()
		observeAuthorizationStatus()
	}

	func getFCMToken() async throws ->  String {
		try await Messaging.messaging().token()
	}

	func getAuthorizationStatus() async -> UNAuthorizationStatus {
		await UNUserNotificationCenter.current().notificationSettings().authorizationStatus		
	}
}

private extension NotificationsHandler {
	func observeFCMToken() {
		Messaging.messaging().delegate = self
	}

	func observeAuthorizationStatus() {
		NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification).sink { [weak self] _ in
			self?.refreshAuthorizationStatus()
		}.store(in: &cancellableSet)
	}

	func refreshAuthorizationStatus() {
		Task {
			let status = await getAuthorizationStatus()
			authorizationStatusSubject.send(status)
		}
	}
}

extension NotificationsHandler: UNUserNotificationCenterDelegate {
	func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
		completionHandler([.banner, .badge, .sound, .list])
	}

	@MainActor
	func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
		latestNotificationSubject.send(response)
	}
}

extension NotificationsHandler: MessagingDelegate {
	func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
		print("Firebase registration token: \(String(describing: fcmToken))")
	}
}
