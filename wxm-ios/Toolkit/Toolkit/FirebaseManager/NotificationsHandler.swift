//
//  NotificationsHandler.swift
//  Toolkit
//
//  Created by Pantelis Giazitsis on 18/1/24.
//

import Foundation
import FirebaseMessaging
import UIKit
@preconcurrency import Combine

final class NotificationsHandler: NSObject, Sendable {
	let latestNotificationPublisher: AnyPublisher<UNNotificationResponse?, Never>
	let authorizationStatusPublisher: AnyPublisher<UNAuthorizationStatus?, Never>
	let fcmTokenPublisher: AnyPublisher<String?, Never>

	private let latestNotificationSubject: PassthroughSubject<UNNotificationResponse?, Never> = .init()
	private let authorizationStatusSubject: CurrentValueSubject<UNAuthorizationStatus?, Never> = .init(nil)
	private let fcmTokenSubject: PassthroughSubject<String?, Never> = .init()

	nonisolated(unsafe) private var cancellableSet: Set<AnyCancellable> = .init()

	override init() {
		latestNotificationPublisher = latestNotificationSubject.eraseToAnyPublisher()
		authorizationStatusPublisher = authorizationStatusSubject.eraseToAnyPublisher()
		fcmTokenPublisher = fcmTokenSubject.eraseToAnyPublisher()
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

	func getAuthorizationStatus() async -> UNAuthorizationStatus {
		await UNUserNotificationCenter.current().notificationSettings().authorizationStatus
	}

	func setApnsToken(_ token: Data) {
		Messaging.messaging().apnsToken = token
	}

	func getFCMToken() -> String? {
		Messaging.messaging().fcmToken
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
		Task { @Sendable in
			let status = await getAuthorizationStatus()
			authorizationStatusSubject.send(status)
		}
	}
}

extension NotificationsHandler: UNUserNotificationCenterDelegate {
	func userNotificationCenter(_ center: UNUserNotificationCenter,
								willPresent notification: UNNotification,
								withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
		completionHandler([.banner, .badge, .sound, .list])
	}

	func userNotificationCenter(_ center: UNUserNotificationCenter,
								didReceive response: UNNotificationResponse,
								withCompletionHandler completionHandler: @escaping () -> Void) {
		latestNotificationSubject.send(response)
		completionHandler()
	}
}

extension NotificationsHandler: MessagingDelegate {
	func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
		fcmTokenSubject.send(fcmToken)
	}
}
