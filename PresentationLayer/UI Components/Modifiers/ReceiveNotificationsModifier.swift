//
//  ReceiveNotificationsModifier.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 19/1/24.
//

import SwiftUI
import Toolkit
import Combine

private struct ReceiveNotificationsModifier: ViewModifier {
	private let notificationPublisher = FirebaseManager.shared.latestReceivedNotificationPublisher
	private let cancellables = CancellableWrapper()

	let onNotificationReceive: (UNNotificationResponse) -> Void

	init(onNotificationReceive: @escaping (UNNotificationResponse) -> Void) {
		self.onNotificationReceive = onNotificationReceive
		notificationPublisher?.sink { response in
			if let response {
				onNotificationReceive(response)
			}
		}
		.store(in: &cancellables.cancellableSet)
	}

	func body(content: Content) -> some View {
		content
	}
}

extension View {
	@ViewBuilder
	func onNotificateionReceive(_ onNotificationReceive: @escaping (UNNotificationResponse) -> Void) -> some View {
		modifier(ReceiveNotificationsModifier(onNotificationReceive: onNotificationReceive))
	}
}
