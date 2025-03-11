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

    @Test func loginLogout() async throws {
		#expect(!keychainRepository.isUserLoggedIn())
		#expect(keychainRepository.getUsersEmail() == "")
		#expect(keychainRepository.tokenResponse == nil)
		#expect(!userDefaultsRepository.userSensitiveDataCleared)
		#expect(!networkRepository.allRecentDeleted)
		try await confirmation { confirm in
			try loginService.login(username: "email", password: "pass").flatMap { response in
				print(response)
				#expect(keychainRepository.isUserLoggedIn())
				#expect(keychainRepository.getUsersEmail() == "email")
				#expect(keychainRepository.tokenResponse != nil)
				#expect(keychainRepository.tokenResponse?.token == "token")
				#expect(keychainRepository.tokenResponse?.refreshToken == "refToken")
				#expect(!userDefaultsRepository.userSensitiveDataCleared)
				#expect(!networkRepository.allRecentDeleted)
				return try! loginService.logout()
			}.flatMap { response in
				#expect(userDefaultsRepository.userSensitiveDataCleared)
				#expect(networkRepository.allRecentDeleted)
				#expect(keychainRepository.tokenResponse == nil)
				#expect(keychainRepository.getUsersEmail() == "")
				return Just(EmptyEntity())
			}.sink { _ in
				confirm()
			} .store(in: &cancellableWrapper.cancellableSet)
		}
    }

}
