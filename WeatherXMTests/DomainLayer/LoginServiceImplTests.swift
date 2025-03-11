//
//  LoginServiceImplTests.swift
//  WeatherXMTests
//
//  Created by Pantelis Giazitsis on 11/3/25.
//

import Testing
@testable import DomainLayer
import Combine
import Toolkit

struct LoginServiceImplTests {
	let authRepository = MockAuthRepositoryImpl()
	let meRepository = MockMeRepositoryImpl()
	let keychainRepository = MockKeychainRepositoryImpl()
	let userDefaultsRepository = MockUserDefaultsRepositoryImpl()
	let networkRepository = MockNetworkRepositoryImpl()
	let loginService: LoginServiceImpl
	let cancellableWrapper: CancellableWrapper = .init()

	init() {
		self.loginService = LoginServiceImpl(authRepository: authRepository,
											 meRepository: meRepository,
											 keychainRepository: keychainRepository,
											 userDefaultsRepository: userDefaultsRepository,
											 networkRepository: networkRepository)
	}

	@MainActor
    @Test func loginLogout() async throws {
		#expect(!keychainRepository.isUserLoggedIn())
		#expect(keychainRepository.getUsersEmail() == "")
		#expect(keychainRepository.tokenResponse == nil)
		#expect(!userDefaultsRepository.userSensitiveDataCleared)
		#expect(!networkRepository.allRecentDeleted)

		let _ = try await loginService.login(username: "email", password: "pass").toAsync()
		#expect(keychainRepository.isUserLoggedIn())
		#expect(keychainRepository.getUsersEmail() == "email")
		#expect(keychainRepository.tokenResponse != nil)
		#expect(keychainRepository.tokenResponse?.token == "token")
		#expect(keychainRepository.tokenResponse?.refreshToken == "refToken")
		#expect(!userDefaultsRepository.userSensitiveDataCleared)
		#expect(!networkRepository.allRecentDeleted)

		let _ = try await loginService.logout().toAsync()
		#expect(userDefaultsRepository.userSensitiveDataCleared)
		#expect(networkRepository.allRecentDeleted)
		#expect(keychainRepository.tokenResponse == nil)
		#expect(keychainRepository.getUsersEmail() == "")
    }

}
