//
//  SettingsRepository.swift
//  DomainLayer
//
//  Created by Pantelis Giazitsis on 19/5/23.
//

import Foundation

public protocol SettingsRepository {
    /// True if the analytics tracking is enabled
    var isAnalyticsEnabled: Bool { get }

    /// True if the user choose to opt in/out analytics at least once
    var isAnalyticsOptSet: Bool { get }

    /// Call to initialize the analytics tracking. By default will be initialized to false
    func initializeAnalytics()

    /// Call to update the analytics tracking option by the user
    /// - Parameter option: The user's option
    func optInOutAnalytics(_ option: Bool)
}
