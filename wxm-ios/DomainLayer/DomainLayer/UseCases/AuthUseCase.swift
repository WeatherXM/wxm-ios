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

public struct AuthUseCase {
    private let authRepository: AuthRepository
	private let meRepository: MeRepository
	private let keychainRepository: KeychainRepository
	private let userDefaultsRepository: UserDefaultsRepository
	private let networkRepository: NetworkRepository

	public init(authRepository: AuthRepository,
				meRepository: MeRepository,
				keychainRepository: KeychainRepository,
				userDefaultsRepository: UserDefaultsRepository,
				networkRepository: NetworkRepository) {
        self.authRepository = authRepository
		self.meRepository = meRepository
		self.keychainRepository = keychainRepository
		self.userDefaultsRepository = userDefaultsRepository
		self.networkRepository = networkRepository
    }

    public func login(username: String, password: String) throws -> AnyPublisher<DataResponse<NetworkTokenResponse, NetworkErrorResponse>, Never> {
        let login = try authRepository.login(username: username, password: password)
		return login.flatMap { response in
			if let value = response.value {
				keychainRepository.saveEmailAndPasswordToKeychain(email: username, password: password)
				keychainRepository.saveNetworkTokenResponseToKeychain(item: value)
				setFCMToken()
			}
			return Just(response)
		}.eraseToAnyPublisher()
    }

    public func register(email: String, firstName: String, lastName: String) throws -> AnyPublisher<DataResponse<EmptyEntity, NetworkErrorResponse>, Never> {
        let register = try authRepository.register(email: email, firstName: firstName, lastName: lastName)
        return register
    }

    public func logout() throws -> AnyPublisher<DataResponse<EmptyEntity, NetworkErrorResponse>, Never> {
        let logout = try authRepository.logout()
		return logout.flatMap { response in
			if response.error == nil {
				userDefaultsRepository.clearUserSensitiveData()
				WidgetCenter.shared.reloadAllTimelines()
				networkRepository.deleteAllRecent()
				deleteFCMToken()
				keychainRepository.deleteEmailAndPasswordFromKeychain()
				keychainRepository.deleteNetworkTokenResponseFromKeychain()
			}

			return Just(response)
		}.eraseToAnyPublisher()
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
}

private extension AuthUseCase {
	func setFCMToken() {
		Task {
			let installationId = await FirebaseManager.shared.getInstallationId()
			guard let fcmToken = await FirebaseManager.shared.getFCMToken() else {
				return
			}
			let _ = try? meRepository.setNotificationsFcmToken(installationId: installationId, token: fcmToken)
		}
	}

	func deleteFCMToken() {
		Task {
			let installationId = await FirebaseManager.shared.getInstallationId()
			let _ = try? meRepository.deleteNotificationsFcmToken(installationId: installationId)
		}

	}
}
