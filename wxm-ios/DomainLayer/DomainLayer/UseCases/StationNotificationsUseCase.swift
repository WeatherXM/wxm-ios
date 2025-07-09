//
//  StationNotificationsUseCase.swift
//  DomainLayer
//
//  Created by Pantelis Giazitsis on 9/7/25.
//

import Foundation

private typealias StationOptions = [StationNotificationsTypes: Bool]
public struct StationNotificationsUseCase: StationNotificationsUseCaseApi {
	private let userDefaultsRepository: UserDefaultsRepository
	private let udKey = UserDefaults.GenericKey.stationNotificationOptions.rawValue

	public init(userDefaultsRepository: UserDefaultsRepository) {
		self.userDefaultsRepository = userDefaultsRepository
	}

	public func setNotificationEnabled(_ enabled: Bool, for type: StationNotificationsTypes) {
		guard var options: StationOptions = userDefaultsRepository.getValue(for: udKey) else {
			var options: StationOptions = [:]
			options[type] = enabled
			userDefaultsRepository.saveValue(key: udKey, value: options)
			return
		}

		options[type] = enabled
		userDefaultsRepository.saveValue(key: udKey, value: options)
	}

	public func isNotificationEnabled(_ type: StationNotificationsTypes) -> Bool {
		let options: StationOptions? = userDefaultsRepository.getValue(for: udKey)
		return options?[type] ?? false
	}
}
