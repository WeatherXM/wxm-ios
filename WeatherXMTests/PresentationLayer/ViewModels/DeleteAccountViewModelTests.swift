//
//  DeleteAccountViewModelTests.swift
//  WeatherXMTests
//
//  Created by Pantelis Giazitsis on 3/4/25.
//

import Testing
@testable import WeatherXM

@MainActor
struct DeleteAccountViewModelTests {
	let viewModel: DeleteAccountViewModel
	let authUseCase: MockAuthUseCase
	let meUseCase: MockMeUseCase

	init() {
		authUseCase = .init()
		meUseCase = .init()
		viewModel = .init(userId: "testUser", authUseCase: authUseCase, meUseCase: meUseCase)
	}

	@Test func tryLoginAndDeleteAccount() async throws {
		viewModel.password = "correctPassword"
		viewModel.tryLoginAndDeleteAccount()
		try await Task.sleep(for: .seconds(2))
		#expect(!viewModel.passwordHasError)
		#expect(viewModel.currentScreen == .info)
	}

	@Test func tryLoginAndDeleteAccountWithInvalidPassword() async throws {
		viewModel.password = MockAuthUseCase.wrongPassword
		viewModel.tryLoginAndDeleteAccount()
		try await Task.sleep(for: .seconds(2))
		#expect(viewModel.passwordHasError)
		#expect(viewModel.currentScreen == .info)
	}

	@Test func tryDeleteAccount() async throws {
		viewModel.tryDeleteAccount()
		try await Task.sleep(for: .seconds(2))
		#expect(viewModel.currentScreen == .info)
	}
}
