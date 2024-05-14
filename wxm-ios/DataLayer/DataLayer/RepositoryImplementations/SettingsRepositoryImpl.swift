//
//  SettingsRepositoryImpl.swift
//  DataLayer
//
//  Created by Pantelis Giazitsis on 19/5/23.
//

import Foundation
import DomainLayer
import Toolkit

public struct SettingsRepositoryImpl: SettingsRepository {
    private let userDefaultsService = UserDefaultsService()
    private let analyticsKey = UserDefaults.GenericKey.isAnalyticsCollectionEnabled.rawValue
    private let analyticsOptTimestampKey = UserDefaults.GenericKey.analyticsCollectionOptTimestamp.rawValue

    public var isAnalyticsEnabled: Bool {
        userDefaultsService.get(key: analyticsKey) ?? true
    }

    public var isAnalyticsOptSet: Bool {
        let timestamp: Date? = userDefaultsService.get(key: analyticsOptTimestampKey)
        return timestamp != nil
    }
    
    public init() {}

    public func initializeAnalytics() {
        // By default opt out
        isAnalyticsOptSet ? setAnalyticsEnabled(isAnalyticsEnabled) : setAnalyticsEnabled(false)
    }

    public func optInOutAnalytics(_ option: Bool) {
        setAnlyticsOptTimestamp()
        setAnalyticsEnabled(option)
    }

    public func clearUserDefaults() {
        userDefaultsService.clearUserSensitiveData()
    }
}

private extension SettingsRepositoryImpl {
    func setAnalyticsEnabled(_ enabled: Bool) {
        userDefaultsService.save(value: enabled, key: analyticsKey)
        WXMAnalytics.shared.setAnalyticsCollectionEnabled(enabled)
    }

    func setAnlyticsOptTimestamp() {
        userDefaultsService.save(value: Date.now, key: analyticsOptTimestampKey)
    }
}
