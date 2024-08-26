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
}
