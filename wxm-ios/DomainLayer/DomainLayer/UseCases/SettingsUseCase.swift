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

public struct SettingsUseCase: SettingsUseCaseApi {
	nonisolated(unsafe) private let repository: SettingsRepository

    public init(repository: SettingsRepository) {
        self.repository = repository
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
