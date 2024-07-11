//
//  TimeValidationCache.swift
//  Toolkit
//
//  Created by Pantelis Giazitsis on 6/8/23.
//

import Foundation

/// An object that conforms to this protocol will be responsible to save and load the cache data
public protocol PersistCacheManager {
	func save<T>(value: T, key: String)
	func get<T>(key: String) -> T?
	func remove(key: String)
}

public class TimeValidationCache<T: Codable> {
	private var cache: [String: Object<T>] {
		get {
			guard let data: Data = persistCacheManager.get(key: persistKey) else {
				return [:]
			}

			let decoder = JSONDecoder()
			let cached = try? decoder.decode([String: Object<T>].self, from: data)
			return cached ?? [:]
		}

		set {
			let encoder = JSONEncoder()
			guard let data = try? encoder.encode(newValue) else {
				return
			}

			persistCacheManager.save(value: data, key: persistKey)
		}
	}
	private let dispatchQueue = DispatchQueue(label: "com.weatherxm.app.time_validation_cache")
	private let persistKey: String
	private let persistCacheManager: PersistCacheManager
	
	/// New cache instance
	/// - Parameters:
	///   - persistCacheManager: An objet that coforms to `PersistCacheManager` protocol
	///   - persistKey: The key used to invoke the `PersistCacheManager` methods
	public init(persistCacheManager: PersistCacheManager, persistKey: String) {
		self.persistCacheManager = persistCacheManager
		self.persistKey = persistKey
	}

    public func insertValue(_ value: T, expire: TimeInterval, for key: String) {
		dispatchQueue.sync {
			self.cache[key] = Object(value: value,
									 timestamp: .now,
									 expireInterval: expire)
		}
    }
	
	/// Returns the "validated" value respecting the `expireInterval`
	/// - Parameter key: The key used to pesist the data
	/// - Returns: The local persisted an valid value
    public func getValue(for key: String) -> T? {
		dispatchQueue.sync {
			guard let obj = cache[key],
				  Date.now.timeIntervalSince(obj.timestamp) < obj.expireInterval else {
				return nil
			}

			return obj.value
		}
    }
	
	/// Returns the persisted data ignoring the `expireInterval`
	/// - Parameter key: The key used to pesist the data
	/// - Returns: The local persisted data
	public func getCachedValue(for key: String) -> T? {
		dispatchQueue.sync {
			return cache[key]?.value
		}
	}

    public func invalidate() {
		persistCacheManager.remove(key: persistKey)
    }
}

private extension TimeValidationCache {
    struct Object<Value: Codable>: Codable {
        let value: Value
        let timestamp: Date
        let expireInterval: TimeInterval
    }
}
