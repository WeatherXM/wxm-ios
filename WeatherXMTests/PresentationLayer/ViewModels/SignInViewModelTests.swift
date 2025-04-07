//
//  SignInViewModelTests.swift
//  WeatherXMTests
//
//  Created by Pantelis Giazitsis on 3/4/25.
//

import Testing
@testable import WeatherXM

@Suite(.serialized)
@MainActor
struct SignInViewModelTests {
	let viewModel: SignInViewModel
	let authUseCase: MockAuthUseCase

	init() {
		authUseCase = .init()
		viewModel = .init(authUseCase: authUseCase)
	}

	@Test func loginWithValidCredentials() async throws {
		viewModel.email = "test@example.com"
		viewModel.password = "correctPassword"
		viewModel.login { error in
			#expect(error == nil)
		}
		try await Task.sleep(for: .seconds(2))
		#expect(viewModel.isSignInButtonAvailable)
	}

	@Test func loginWithInvalidCredentials() async throws {
		viewModel.email = "test@example.com"
		viewModel.password = MockAuthUseCase.wrongPassword
		viewModel.login { error in
			#expect(error != nil)
		}
		try await Task.sleep(for: .seconds(2))
		#expect(viewModel.isSignInButtonAvailable)
	}

	@Test func checkSignInButtonAvailability() {
		viewModel.email = ""
		viewModel.password = ""
		viewModel.checkSignInButtonAvailability()
		#expect(!viewModel.isSignInButtonAvailable)

		viewModel.email = "test@example.com"
		viewModel.password = ""
		viewModel.checkSignInButtonAvailability()
		#expect(!viewModel.isSignInButtonAvailable)

		viewModel.email = ""
		viewModel.password = "correctPassword"
		viewModel.checkSignInButtonAvailability()
		#expect(!viewModel.isSignInButtonAvailable)

		viewModel.email = "test@example.com"
		viewModel.password = "correctPassword"
		viewModel.checkSignInButtonAvailability()
		#expect(viewModel.isSignInButtonAvailable)
	}
}
