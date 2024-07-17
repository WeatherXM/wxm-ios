//
//  LoginService.swift
//  DomainLayer
//
//  Created by Pantelis Giazitsis on 17/7/24.
//

import Foundation
import Combine
import Alamofire
import Toolkit
import WidgetKit

extension Notification.Name {
	public static let AuthRefreshTokenExpired = Notification.Name("LoginService.refreshTokenExpired")
}

public protocol LoginService {
	func logout() throws -> AnyPublisher<DataResponse<EmptyEntity, NetworkErrorResponse>, Never>
	func login(username: String, password: String) throws -> AnyPublisher<DataResponse<NetworkTokenResponse, NetworkErrorResponse>, Never>
}

public class LoginServiceImpl: LoginService {
	private let authRepository: AuthRepository
	private let meRepository: MeRepository
	private let keychainRepository: KeychainRepository
	private let userDefaultsRepository: UserDefaultsRepository
	private let networkRepository: NetworkRepository
	private var cancellableSet: Set<AnyCancellable> = .init()

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

		observeRefreshTokenExpiration()
	}

	public func login(username: String, password: String) throws -> AnyPublisher<DataResponse<NetworkTokenResponse, NetworkErrorResponse>, Never> {
		let login = try authRepository.login(username: username, password: password)
		return login.flatMap { [weak self] response in
			if let value = response.value {
				self?.keychainRepository.saveEmailAndPasswordToKeychain(email: username, password: password)
				self?.keychainRepository.saveNetworkTokenResponseToKeychain(item: value)
				self?.setFCMToken()
			}
			return Just(response)
		}.eraseToAnyPublisher()
	}

	public func logout() throws -> AnyPublisher<DataResponse<EmptyEntity, NetworkErrorResponse>, Never> {
		let logout = try authRepository.logout()
		return logout.flatMap { [weak self] response in
			if response.error == nil {
				self?.userDefaultsRepository.clearUserSensitiveData()
				WidgetCenter.shared.reloadAllTimelines()
				self?.networkRepository.deleteAllRecent()
				self?.deleteFCMToken()
				self?.keychainRepository.deleteEmailAndPasswordFromKeychain()
				self?.keychainRepository.deleteNetworkTokenResponseFromKeychain()
			}

			return Just(response)
		}.eraseToAnyPublisher()
	}
}

private extension LoginServiceImpl {
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

	func observeRefreshTokenExpiration() {
		NotificationCenter.default.publisher(for: .AuthRefreshTokenExpired).sink { [weak self] notification in
			_ = try? self?.logout()
		}.store(in: &cancellableSet)
	}
}
