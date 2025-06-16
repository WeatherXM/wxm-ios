//
//  MockLogger.swift
//  WeatherXMTests
//
//  Created by Pantelis Giazitsis on 13/6/25.
//

import Foundation
import Toolkit

class MockLogger: LoggerApi {
	private(set) var networkError: (any NetworkError)? = nil
	private(set) var nsError: NSError? = nil


	func logNetworkError(_ networkError: any NetworkError) {
		self.networkError = networkError
	}

	func logError(_ nsError: NSError) {
		self.nsError = nsError
	}
}
