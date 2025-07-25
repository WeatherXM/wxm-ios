//
//  Logger.swift
//  Toolkit
//
//  Created by Pantelis Giazitsis on 13/5/24.
//

import Foundation
import FirebaseCrashlytics

public protocol LoggerApi {
	func logNetworkError(_ networkError: any NetworkError)
	func logError(_ nsError: NSError)
}

public class Logger: @unchecked Sendable, LoggerApi {
	public static let shared = Logger()

	private init() {}
}

// MARK: - Errors
public extension Logger {
	func logNetworkError(_ networkError: any NetworkError) {
		let nsError = NSError(domain: networkDomain,
							  code: networkError.code,
							  userInfo: networkError.userInfo)
		logError(nsError)
	}

	func logError(_ nsError: NSError) {
		guard !disableAnalytics else {
			return
		}

		Crashlytics.crashlytics().record(error: nsError)
	}
}
