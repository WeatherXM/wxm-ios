//
//  AuthUseCase.swift
//  DomainLayer
//
//  Created by Hristos Condrea on 17/5/22.
//

import Alamofire
import Combine
import Foundation
import Toolkit
import WidgetKit

public struct AuthUseCase: AuthUseCaseApi {
    private let authRepository: AuthRepository
	private let meRepository: MeRepository
	private let keychainRepository: KeychainRepository
	private let userDefaultsRepository: UserDefaultsRepository
	private let networkRepository: NetworkRepository
	private let loginService: LoginService

	public init(authRepository: AuthRepository,
				meRepository: MeRepository,
				keychainRepository: KeychainRepository,
				userDefaultsRepository: UserDefaultsRepository,
				networkRepository: NetworkRepository,
				loginService: LoginService) {
        self.authRepository = authRepository
		self.meRepository = meRepository
		self.keychainRepository = keychainRepository
		self.userDefaultsRepository = userDefaultsRepository
		self.networkRepository = networkRepository
		self.loginService = loginService
    }

    public func login(username: String, password: String) throws -> AnyPublisher<DataResponse<NetworkTokenResponse, NetworkErrorResponse>, Never> {
		try loginService.login(username: username, password: password)
    }

    public func register(email: String, firstName: String, lastName: String) throws -> AnyPublisher<DataResponse<EmptyEntity, NetworkErrorResponse>, Never> {
        let register = try authRepository.register(email: email, firstName: firstName, lastName: lastName)
        return register
    }

    public func logout() throws -> AnyPublisher<DataResponse<EmptyEntity, NetworkErrorResponse>, Never> {
		try loginService.logout()
    }

    public func refresh(refreshToken: String) throws -> AnyPublisher<DataResponse<NetworkTokenResponse, NetworkErrorResponse>, Never> {
        let refresh = try authRepository.refresh(refreshToken: refreshToken)
        return refresh
    }

    public func resetPassword(email: String) throws -> AnyPublisher<DataResponse<EmptyEntity, NetworkErrorResponse>, Never> {
        let resetPassword = try authRepository.resetPassword(email: email)
        return resetPassword
    }

    public func passwordValidation(password: String)throws -> AnyPublisher<DataResponse<NetworkTokenResponse, NetworkErrorResponse>, Never> {
        return try authRepository.passwordValidation(password: password)
    }

	public func getUsersEmail() -> String {
		keychainRepository.getUsersEmail()
	}

	public func isUserLoggedIn() -> Bool {
		keychainRepository.isUserLoggedIn()
	}
}
