//
//  MockCacheManager.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 28/1/25.
//

import Toolkit

final class MockCacheManager: PersistCacheManager {
	nonisolated(unsafe) private var cache: [String: Any] = [:]

	func save<T>(value: T, key: String) {
		cache[key] = value
	}
	
	func get<T>(key: String) -> T? {
		cache[key] as? T
	}
	
	func remove(key: String) {
		cache.removeValue(forKey: key)
	}
}
