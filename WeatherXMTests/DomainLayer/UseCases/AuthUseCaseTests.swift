//
//  AuthUseCaseTests.swift
//  WeatherXMTests
//
//  Created by Pantelis Giazitsis on 11/3/25.
//

import Testing
@testable import DomainLayer
import Toolkit

struct AuthUseCaseTests {
	let authRepository = MockAuthRepositoryImpl()
	let meRepository = MockMeRepositoryImpl()
	let keychainRepository = MockKeychainRepositoryImpl()
	let userDefaultsRepository = MockUserDefaultsRepositoryImpl()
	let networkRepository = MockNetworkRepositoryImpl()
	let loginService = MockLoginService()
	let useCase: AuthUseCase
	let cancellableWrapper = CancellableWrapper()

	init() {
		self.useCase = .init(authRepository: authRepository,
							 meRepository: meRepository,
							 keychainRepository: keychainRepository,
							 userDefaultsRepository: userDefaultsRepository,
							 networkRepository: networkRepository,
							 loginService: loginService)
	}

    @Test func login() async throws {
		try await confirmation { confirm in
			try useCase.login(username: "", password: "").sink { response in
				let token = response.value
				#expect(token?.token == "token")
				#expect(token?.refreshToken == "refreshToken")
				confirm()
			}.store(in: &cancellableWrapper.cancellableSet)
		}
    }

	@Test func register() async throws {
		try await confirmation { confirm in
			try useCase.register(email: "", firstName: "", lastName: "").sink { response in
				let res = response.value
				#expect(res != nil)
				confirm()
			}.store(in: &cancellableWrapper.cancellableSet)
		}
	}

	@Test func logout() async throws {
		try await confirmation { confirm in
			try useCase.logout().sink { response in
				let res = response.value
				#expect(res != nil)
				confirm()
			}.store(in: &cancellableWrapper.cancellableSet)
		}
	}

	@Test func refreh() async throws {
		try await confirmation { confirm in
			try useCase.refresh(refreshToken: "124").sink { response in
				let token = response.value
				#expect(token?.token == "token")
				#expect(token?.refreshToken == "refToken")
				confirm()
			}.store(in: &cancellableWrapper.cancellableSet)
		}
	}

	@Test func resetPassword() async throws {
		try await confirmation { confirm in
			try useCase.resetPassword(email: "").sink { response in
				let res = response.value
				#expect(res != nil)
				confirm()
			}.store(in: &cancellableWrapper.cancellableSet)
		}
	}

	@Test func passwordValidation() async throws {
		try await confirmation { confirm in
			try useCase.passwordValidation(password: "124").sink { response in
				let token = response.value
				#expect(token?.token == "token")
				#expect(token?.refreshToken == "refToken")
				confirm()
			}.store(in: &cancellableWrapper.cancellableSet)
		}
	}

	@Test func getUserEmail() {
		let email = useCase.getUsersEmail()
		#expect(email == "")
	}

	@Test func isUserLoggedIn() {
		let isLoggedIn = useCase.isUserLoggedIn()
		#expect(!isLoggedIn)
	}
}
