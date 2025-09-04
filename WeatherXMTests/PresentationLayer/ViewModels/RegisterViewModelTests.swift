//
//  RegisterViewModelTests.swift
//  WeatherXMTests
//
//  Created by Pantelis Giazitsis on 3/4/25.
//

import Testing
@testable import WeatherXM

@Suite(.serialized)
@MainActor
struct RegisterViewModelTests {
	let viewModel: RegisterViewModel
	let authUseCase: MockAuthUseCase
	let mainUseCase: MockMainUseCase

	init() {
		authUseCase = .init()
		mainUseCase = .init()
		viewModel = .init(authUseCase: authUseCase, mainUseCase: mainUseCase, signUpCompletion: nil)
	}

	@Test func registerWithValidData() async throws {
		viewModel.userEmail = "test@example.com"
		viewModel.userName = "Test"
		viewModel.userSurname = "User"
		viewModel.termsAccepted = true
		viewModel.register()
		try await Task.sleep(for: .seconds(2))
		#expect(viewModel.isSuccess)
		#expect(!viewModel.isFail)
	}

	@Test func registerWithInvalidData() async throws {
		viewModel.userEmail = MockAuthUseCase.invalidEmail
		viewModel.userName = "Test"
		viewModel.userSurname = "User"
		viewModel.termsAccepted = true
		viewModel.register()
		try await Task.sleep(for: .seconds(2))
		#expect(!viewModel.isSuccess)
		#expect(viewModel.isFail)
	}

	@Test func checkSignUpButtonAvailability() {
		viewModel.userEmail = ""
		viewModel.userName = ""
		viewModel.userSurname = ""
		viewModel.termsAccepted = false
		#expect(!viewModel.isSignUpButtonAvailable)

		viewModel.userEmail = "test@example.com"
		viewModel.termsAccepted = true
		#expect(viewModel.isSignUpButtonAvailable)
	}
}
