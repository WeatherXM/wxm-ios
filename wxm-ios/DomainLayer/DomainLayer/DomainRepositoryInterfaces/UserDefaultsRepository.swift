//
//  UserDefaultsRepository.swift
//  DomainLayer
//
//  Created by Lampros Zouloumis on 1/9/22.
//

public protocol UserDefaultsRepository {
    func readWeatherUnit(key: String) -> UnitsProtocol?
    func saveDefaultUnitForKey(key: String) -> UnitsProtocol?
    func saveWeatherUnit(unitProtocol: UnitsProtocol)
    func saveValue<T>(key: String, value: T)
    func getValue<T>(for key: String) -> T?
	func clearUserSensitiveData()
}
