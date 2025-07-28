//
//  BackgroundScheduler.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 24/7/25.
//

import Foundation
import BackgroundTasks
import UIKit
import Toolkit

private let taskIdentifier = "com.weatherxm.app.fetch"
private let interval: TimeInterval = 60 * 60 * 2 // 2 hours

final class BackgroundScheduler: Sendable {
	private let callback: VoidSendableCallback

	init(callback: @escaping VoidSendableCallback) {
		self.callback = callback
		registerBackgroundTask()
		scheduleAppRefresh()
	}
}

private extension BackgroundScheduler {
	func registerBackgroundTask() {
		let registered = BGTaskScheduler.shared.register(forTaskWithIdentifier: taskIdentifier, using: nil) { [weak self] task in
			self?.handleAppRefresh(task)
		}

		print(registered)
	}

	func handleAppRefresh(_ task: BGTask) {
		scheduleAppRefresh()

		callback()
		
		task.setTaskCompleted(success: true)
	}

	func scheduleAppRefresh() {
		let request = BGAppRefreshTaskRequest(identifier: taskIdentifier)
		request.earliestBeginDate = Date(timeIntervalSinceNow: interval)

		do {
			try BGTaskScheduler.shared.submit(request)
		} catch {
			print("Could not schedule app refresh: \(error)")
		}

		print(request)
	}
}
