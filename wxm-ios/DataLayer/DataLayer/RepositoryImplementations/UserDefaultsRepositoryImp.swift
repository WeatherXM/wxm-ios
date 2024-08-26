//
//  UserDefaultsRepositoryImp.swift
//  DataLayer
//
//  Created by Lampros Zouloumis on 1/9/22.
//

import protocol DomainLayer.UnitsProtocol
import protocol DomainLayer.UserDefaultsRepository
import Foundation

public struct UserDefaultsRepositoryImp: UserDefaultsRepository {
    private let userDefaultsService: UserDefaultsService

    public init() {
        self.userDefaultsService = UserDefaultsService()
    }

    public func readWeatherUnit(key: String) -> UnitsProtocol? {
        userDefaultsService.getUnitsProtocol(key: key)
    }

    public func saveWeatherUnit(unitProtocol: UnitsProtocol) {
        userDefaultsService.save(value: unitProtocol.value, key: unitProtocol.key)
    }

    public func saveDefaultUnitForKey(key: String) -> UnitsProtocol? {
        userDefaultsService.saveDefaultUnitProtocolFor(key: key)
    }

    public func saveValue<T>(key: String, value: T) {
        userDefaultsService.save(value: value, key: key)
    }

    public func getValue<T>(for key: String) -> T? {
        userDefaultsService.get(key: key)
    }

	public func clearUserSensitiveData() {
		userDefaultsService.clearUserSensitiveData()
	}
}
