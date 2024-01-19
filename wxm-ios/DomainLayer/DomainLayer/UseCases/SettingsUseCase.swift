//
//  SettingsUseCase.swift
//  DomainLayer
//
//  Created by Pantelis Giazitsis on 19/5/23.
//

import Foundation
import Combine
import Alamofire
import WidgetKit

public struct SettingsUseCase {
    private let repository: SettingsRepository
    private let authRepository: AuthRepository
    private let keychainRepository: KeychainRepository
    private let networkRepository: NetworkRepository

    public init(repository: SettingsRepository,
                authRepository: AuthRepository,
                keychainRepository: KeychainRepository,
                networkRepository: NetworkRepository) {
        self.repository = repository
        self.authRepository = authRepository
        self.keychainRepository = keychainRepository
        self.networkRepository = networkRepository
    }

    public var isAnalyticsEnabled: Bool {
        repository.isAnalyticsEnabled
    }

    public var isAnalyticsOptSet: Bool {
        repository.isAnalyticsOptSet
    }

    public func initializeAnalyticsTracking() {
        repository.initializeAnalytics()
    }
    
    public func optInOutAnalytics(_ option: Bool) {
        repository.optInOutAnalytics(option)
    }

    public func clearUserDefaults() {
        repository.clearUserDefaults()
    }

	public func logout(localOnly: Bool = false) throws -> AnyPublisher<DataResponse<EmptyEntity, NetworkErrorResponse>, Never> {
		guard !localOnly else {
			logoutLocally()
			return Just(DataResponse(request: nil, 
									 response: nil,
									 data: nil,
									 metrics: nil,
									 serializationDuration: 0,
									 result: .success(EmptyEntity()))).eraseToAnyPublisher()
		}

        return try authRepository.logout().flatMap { response in
            if response.error == nil {
				self.logoutLocally()
            }

            return Just(response)
        }
        .eraseToAnyPublisher()
    }

	private func logoutLocally() {
		clearUserDefaults()
		keychainRepository.deleteEmailAndPasswordFromKeychain()
		keychainRepository.deleteNetworkTokenResponseFromKeychain()
		networkRepository.deleteAllRecent()
		WidgetCenter.shared.reloadAllTimelines()
	}
}
