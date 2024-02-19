//
//  RemoteConfigManager.swift
//  Toolkit
//
//  Created by Pantelis Giazitsis on 3/11/23.
//

import Foundation
import FirebaseRemoteConfig

public class RemoteConfigManager: ObservableObject {

	static public let shared: RemoteConfigManager = .init()
	private let remoteConfigManagerImpl: RemoteConfigManagerImplementation

	// MARK: - Remote config entries
	@Published public var iosTestIntegration: String?
	@Published public var rewardsHideAnnotationThreshold: Int?
	@Published public var iosAppChangelog: String?
	@Published public var iosAppLatestVersion: String?
	@Published public var iosAppMinimumVersion: String?
	@Published public var isFeatMainnetEnabled: Bool?

	private init() {
		if disableFirebase {
			remoteConfigManagerImpl = MockRemoteConfigManager()
		} else {
			remoteConfigManagerImpl = DefaultRemoteConfigManager()
		}

		remoteConfigManagerImpl.shouldUpdateCallback = { [weak self] in
			self?.updateProperties()
		}
	}

	public func getConfigValue<T>(type: T.Type = T.self, key: RemoteConfigKey) -> T? {
		remoteConfigManagerImpl.getConfigValue(type: type, key: key)
	}
}

private extension RemoteConfigManager {
	func updateProperties() {
		DispatchQueue.main.async { [weak self] in
			guard let self else {
				return
			}

			self.iosTestIntegration = self.getConfigValue(key: .iosTestIntegration)
			self.rewardsHideAnnotationThreshold = self.getConfigValue(key: .rewardsHideAnnotationThreshold)
			self.iosAppChangelog = self.getConfigValue(key: .iosAppChangelog)
			self.iosAppLatestVersion = self.getConfigValue(key: .iosAppLatestVersion)
			self.iosAppMinimumVersion = self.getConfigValue(key: .iosAppMinimumVersion)
			self.isFeatMainnetEnabled = self.getConfigValue(key: .featMainnet)
		}
	}
}

private class DefaultRemoteConfigManager: RemoteConfigManagerImplementation {

	var shouldUpdateCallback: VoidCallback?
	private let remoteConfig = RemoteConfig.remoteConfig()

	init() {
		let settings = RemoteConfigSettings()
		settings.minimumFetchInterval = 0
		remoteConfig.configSettings = settings
		remoteConfig.setDefaults(RemoteConfigKey.defaults)
		fetch()
		observeUpdates()
	}

	func getConfigValue<T>(type: T.Type, key: RemoteConfigKey) -> T? {
		let val = remoteConfig.configValue(forKey: key.rawValue)

		switch type {
			case is String.Type:
				return val.stringValue as? T
			case is Bool.Type:
				return val.boolValue as? T
			case is Int.Type:
				return val.numberValue.intValue as? T
			default:
				return nil
		}
	}

	func fetch() {
		remoteConfig.fetch { [weak self] status, error in
			switch status {
				case .noFetchYet:
					print("waiting")
				case .success:
					print("Success")
					self?.refresh()
				case .failure:
					print("failed with \(error)")
				case .throttled:
					print("Throttled")
				@unknown default:
					print("failed with possible error \(error)")
			}
		}
	}

	func observeUpdates() {
		remoteConfig.addOnConfigUpdateListener { [weak self] configUpdate, error in
			if let error {
				print(error)
				return
			}
			print("Updated keys: \(configUpdate?.updatedKeys)")
			self?.refresh()
		}
	}

	func refresh() {
		remoteConfig.activate { [weak self] changed, error in
			if let error {
				print(error)
				return
			}

			if changed {
				print("Values changed")
			}
			self?.updateProperties()
		}
	}

	func updateProperties() {
		DispatchQueue.main.async { [weak self] in
			guard let self else {
				return
			}
			self.shouldUpdateCallback?()
		}
	}
}

class MockRemoteConfigManager: RemoteConfigManagerImplementation {
	var shouldUpdateCallback: VoidCallback?
	
	func getConfigValue<T>(type: T.Type, key: RemoteConfigKey) -> T? {
		nil
	}
}
