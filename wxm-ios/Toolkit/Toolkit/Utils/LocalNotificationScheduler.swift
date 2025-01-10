//
//  LocalNotificationScheduler.swift
//  Toolkit
//
//  Created by Pantelis Giazitsis on 10/1/25.
//

import Foundation
import UserNotifications

public struct LocalNotificationScheduler {
	public init() {}

	public func postNotification(id: String, title: String, body: String?) {
		let content = UNMutableNotificationContent()
		content.title = title
		if let body {
			content.body = body
		}
		let notification = UNNotificationRequest(identifier: id, content: content, trigger: nil)
		UNUserNotificationCenter.current().add(notification)
	}
}
