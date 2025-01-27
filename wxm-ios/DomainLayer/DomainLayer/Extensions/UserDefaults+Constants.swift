//
//  UserDefaults+Constants.swift
//  DomainLayer
//
//  Created by Lampros Zouloumis on 1/9/22.
//

import Foundation

private protocol UserDefaultsEntry {
    /// All user sensitive entries
    static var userKeys: [String] { get }
}

public extension UserDefaults {
    enum WeatherUnitKey: String, CaseIterable, UserDefaultsEntry {
        case temperature = "com.weatherxm.app.UserDefaults.Key.Temperature"
        case precipitation = "com.weatherxm.app.UserDefaults.Key.Precipitation"
        case windSpeed = "com.weatherxm.app.UserDefaults.Key.WindSpeed"
        case windDirection = "com.weatherxm.app.UserDefaults.Key.WindDirection"
        case pressure = "com.weatherxm.app.UserDefaults.Key.Pressure"

        // MARK: - UserDefaultEntry

        static var userKeys: [String] {
            Self.allCases.map { $0.rawValue }
        }
    }

    enum GenericKey: String, CaseIterable, UserDefaultsEntry {
        case hideWalletTimestamp = "com.weatherxm.app.UserDefaults.Key.HideWalletTimestamp"
        case firmwareUpdateVersions = "com.weatherxm.app.UserDefaults.Key.FirmwareUpdateVersions"
        case displayTheme = "com.weatherxm.app.UserDefaults.Key.DisplayTheme"
        case isAnalyticsCollectionEnabled = "com.weatherxm.app.UserDefaults.Key.isAnalyticsCollectionEnabled"
        case analyticsCollectionOptTimestamp = "com.weatherxm.app.UserDefaults.Key.AnalyticsCollectionOptTimestamp"
        case sortByDevicesOption = "com.weatherxm.app.UserDefaults.Key.SortByDevicesOption"
        case filterDevicesOption = "com.weatherxm.app.UserDefaults.Key.FilterDevicesOption"
        case groupByDevicesOption = "com.weatherxm.app.UserDefaults.Key.GroupByDevicesOption"
		case userDevicesFollowStates = "com.weatherxm.app.UserDefaults.Key.UserDevicesFollowStates"
		case userDevices = "com.weatherxm.app.UserDefaults.Key.UserDevices"
		case lastAppVersionPrompt = "com.weatherxm.app.UserDefaults.Key.LastAppVersionPrompt"
		case lastSurveyId = "com.weatherxm.app.UserDefaults.Key.LastSurveyId"
		case lastInfoBannerId = "com.weatherxm.app.UserDefaults.Key.LastInfoBannerId"
		case termsOfUseAcceptedTimestamp = "com.weatherxm.app.UserDefaults.Key.TermsOfUseAcceptedTimestamp"

        // MARK: - UserDefaultEntry

        static var userKeys: [String] {
			let keys: [GenericKey] = [.hideWalletTimestamp, .sortByDevicesOption, .filterDevicesOption, .groupByDevicesOption, .userDevicesFollowStates, .userDevices, .lastSurveyId, .lastInfoBannerId]
            return keys.map { $0.rawValue }
        }
    }

    static var userGeneratedKeys: [String] {
        [WeatherUnitKey.userKeys, GenericKey.userKeys].flatMap { $0 }
    }
}
