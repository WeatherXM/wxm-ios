//
//  ResetPasswordViewModelTests.swift
//  WeatherXMTests
//
//  Created by Pantelis Giazitsis on 3/4/25.
//

import Testing
@testable import WeatherXM

@Suite(.serialized)
@MainActor
struct ResetPasswordViewModelTests {
	let viewModel: ResetPasswordViewModel
	let authUseCase: MockAuthUseCase

	init() {
		authUseCase = .init()
		viewModel = .init(authUseCase: authUseCase)
	}

	@Test func resetPasswordWithValidEmail() async throws {
		viewModel.userEmail = "test@example.com"
		viewModel.resetPassword()
		try await Task.sleep(for: .seconds(2))
		#expect(viewModel.isSuccess)
		#expect(!viewModel.isFail)
	}

	@Test func resetPasswordWithInvalidEmail() async throws {
		viewModel.userEmail = MockAuthUseCase.invalidEmail
		viewModel.resetPassword()
		try await Task.sleep(for: .seconds(2))
		#expect(!viewModel.isSuccess)
		#expect(viewModel.isFail)
	}

	@Test func checkResetButtonAvailability() {
		viewModel.userEmail = ""
		viewModel.isResetPasswordButtonAvailable()
		#expect(!viewModel.isSendResetPasswordButtonAvailable)

		viewModel.userEmail = "test@example.com"
		viewModel.isResetPasswordButtonAvailable()
		#expect(viewModel.isSendResetPasswordButtonAvailable)
	}
}
