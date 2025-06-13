//
//  KeychainHelperServiceTests.swift
//  WeatherXMTests
//
//  Created by Pantelis Giazitsis on 5/2/25.
//

import Testing
@testable import DataLayer
import DomainLayer
import Toolkit

@Suite(.serialized)
struct KeychainHelperServiceTests {
	let logger: MockLogger
	let service: KeychainHelperService
	let cancellableWrapper: CancellableWrapper

	init() async throws {
		logger = .init()
		service = .init(logger: logger)
		cancellableWrapper  = .init()
		service.deleteNetworkTokenResponseFromKeychain()
		service.deleteEmailAndPassword()
	}

    @Test func logIn() async throws {
		validateLoggedIn(isLoggedIn: false)

		try await confirmation { confirm in
			NotificationCenter.default.publisher(for: .keychainHelperServiceUserIsLoggedChanged).receive(on: DispatchQueue.main).sink { [confirm] notification in
					guard let isLoggedIn = notification.object as? Bool else {
						Issue.record("Notification should contain Bool object")
						return
					}

					#expect(isLoggedIn == true)

					confirm()
				}.store(in: &cancellableWrapper.cancellableSet)

			// Log in
			let response = NetworkTokenResponse(token: "token", refreshToken: "refreshToken")
			service.saveNetworkTokenResponseToKeychain(item: response)
			try await Task.sleep(for: .seconds(1))
		}
	}

	@Test func logOut() async throws {
		validateLoggedIn(isLoggedIn: false)

		// Log in
		let response = NetworkTokenResponse(token: "token", refreshToken: "refreshToken")
		service.saveNetworkTokenResponseToKeychain(item: response)
		try await Task.sleep(for: .seconds(1))

		try await confirmation { confirm in
			NotificationCenter.default.publisher(for: .keychainHelperServiceUserIsLoggedChanged).receive(on: DispatchQueue.main).sink { notification in
				guard let isLoggedIn = notification.object as? Bool else {
					Issue.record("Notification should contain Bool object")
					return
				}

				#expect(isLoggedIn == false)

				confirm()
			}.store(in: &cancellableWrapper.cancellableSet)

			// Log out
			service.deleteNetworkTokenResponseFromKeychain()
			try await Task.sleep(for: .seconds(1))
		}
	}

	@Test func storeEmail() throws {
		#expect(logger.nsError == nil)
		#expect(service.getUsersAccountInfo() == nil)
		let nsError = try #require(logger.nsError)
		#expect(nsError.domain == "keychain")
		#expect(nsError.code == errSecItemNotFound)
		#expect(nsError.userInfo["service"] as? String == KeychainConstants.saveAccountInfo.service)
		service.saveEmailAndPasswordToKeychain(email: "email", password: "password")
		let accountInfo = service.getUsersAccountInfo()
		#expect(accountInfo?.email == "email")
		#expect(accountInfo?.password == "password")
	}
}

private extension KeychainHelperServiceTests {
	func validateLoggedIn(isLoggedIn: Bool) {
		let loggedInState = service.isUserLoggedIn()
		#expect(loggedInState == isLoggedIn)
	}
}
