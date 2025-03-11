//
//  MockKeychainRepositoryImpl.swift
//  WeatherXMTests
//
//  Created by Pantelis Giazitsis on 6/3/25.
//

import Foundation
@testable import DomainLayer

class MockKeychainRepositoryImpl {
	private(set) var tokenResponse: NetworkTokenResponse?
	private var email: String?
	private var password: String?
}

extension MockKeychainRepositoryImpl: KeychainRepository {
	var userLoggedInStateNotificationPublisher: NotificationCenter.Publisher {
		NotificationCenter.default.publisher(for: Notification.Name("MockKeychainRepositoryImpl.userIsLoggedInChanged"))
	}

	func saveNetworkTokenResponseToKeychain(item: NetworkTokenResponse) {
		tokenResponse = item
	}
	
	func isUserLoggedIn() -> Bool {
		tokenResponse != nil
	}
	
	func deleteNetworkTokenResponseFromKeychain() {
		tokenResponse = nil
	}
	
	func saveEmailAndPasswordToKeychain(email: String, password: String) {
		self.email = email
		self.password = password
	}
	
	func deleteEmailAndPasswordFromKeychain() {
		self.email = nil
		self.password = nil
	}
	
	func getUsersEmail() -> String {
		email ?? ""
	}
	

}
