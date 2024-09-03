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
		getInstallationId().flatMap { [weak self] installationId in
			guard let self else {
				let error = NetworkErrorResponse(initialError: AFError.explicitlyCancelled, backendError: nil)
				let dummyResponse: DataResponse<EmptyEntity, NetworkErrorResponse> = DataResponse(request: nil,
																						response: nil,
																						data: nil,
																						metrics: nil,
																						serializationDuration: 0,
																						result: .failure(error))
				return Just(dummyResponse).eraseToAnyPublisher()
			}

			do {
				let logout = try self.authRepository.logout(installationId: installationId)
				return logout
			} catch {
				let error = NetworkErrorResponse(initialError: AFError.explicitlyCancelled, backendError: nil)
				let dummyResponse: DataResponse<EmptyEntity, NetworkErrorResponse> = DataResponse(request: nil,
																						response: nil,
																						data: nil,
																						metrics: nil,
																						serializationDuration: 0,
																						result: .failure(error))
				return Just(dummyResponse).eraseToAnyPublisher()
			}
		}.flatMap { [weak self] response in
			if response.error == nil {
				self?.userDefaultsRepository.clearUserSensitiveData()
				WidgetCenter.shared.reloadAllTimelines()
				self?.networkRepository.deleteAllRecent()
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
			guard let fcmToken = FirebaseManager.shared.getFCMToken() else {
				return
			}
			try? meRepository.setNotificationsFcmToken(installationId: installationId, token: fcmToken).sink { _ in

			}.store(in: &cancellableSet)
		}
	}

	func getInstallationId() -> AnyPublisher<String, Never> {
		let publisher = PassthroughSubject<String, Never>()
		Task { @MainActor in
			let installationId = await FirebaseManager.shared.getInstallationId()
			publisher.send(installationId)
			publisher.send(completion: .finished)
		}

		return publisher.eraseToAnyPublisher()
	}

	func observeRefreshTokenExpiration() {
		NotificationCenter.default.publisher(for: .AuthRefreshTokenExpired).sink { [weak self] _ in
			_ = try? self?.logout()
		}.store(in: &cancellableSet)
	}
}
