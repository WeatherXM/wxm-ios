//
//  RemoteConfigManager.swift
//  Toolkit
//
//  Created by Pantelis Giazitsis on 3/11/23.
//

import Foundation
import FirebaseRemoteConfig

public class RemoteConfigManager: ObservableObject, @unchecked Sendable {

	public static let shared: RemoteConfigManager = .init()
	private let remoteConfigManagerImpl: RemoteConfigManagerImplementation

	// MARK: - Remote config entries
	@Published public var iosTestIntegration: String?
	@Published public var iosAppChangelog: String?
	@Published public var iosAppLatestVersion: String?
	@Published public var iosAppMinimumVersion: String?
	// Survey
	@Published public var surveyId: String?
	@Published public var surveyTitle: String?
	@Published public var surveyMessage: String?
	@Published public var surveyActionLabel: String?
	@Published public var surveyUrl: String?
	@Published public var surveyShow: Bool?
	// Info banner
	@Published public var infoBannerId: String?
	@Published public var infoBannerTitle: String?
	@Published public var infoBannerMessage: String?
	@Published public var infoBannerActionShow: Bool?
	@Published public var infoBannerActionLabel: String?
	@Published public var infoBannerActionUrl: String?
	@Published public var infoBannerShow: Bool?
	@Published public var infoBannerDismissable: Bool?

	private init() {
		if disableAnalytics {
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
			self.iosAppChangelog = self.getConfigValue(key: .iosAppChangelog)
			self.iosAppLatestVersion = self.getConfigValue(key: .iosAppLatestVersion)
			self.iosAppMinimumVersion = self.getConfigValue(key: .iosAppMinimumVersion)
			self.surveyId = self.getConfigValue(key: .surveyId)
			self.surveyTitle = self.getConfigValue(key: .surveyTitle)
			self.surveyMessage = self.getConfigValue(key: .surveyMessage)
			self.surveyActionLabel = self.getConfigValue(key: .surveyActionLabel)
			self.surveyUrl = self.getConfigValue(key: .surveyUrl)
			self.surveyShow = self.getConfigValue(key: .surveyShow)
			self.infoBannerId = self.getConfigValue(key: .infoBannerId)
			self.infoBannerTitle = self.getConfigValue(key: .infoBannerTitle)
			self.infoBannerMessage = self.getConfigValue(key: .infoBannerMessage)
			self.infoBannerActionShow = self.getConfigValue(key: .infoBannerActionShow)
			self.infoBannerActionLabel = self.getConfigValue(key: .infoBannerActionLabel)
			self.infoBannerActionUrl = self.getConfigValue(key: .infoBannerActionUrl)
			self.infoBannerShow = self.getConfigValue(key: .infoBannerShow)
			self.infoBannerDismissable = self.getConfigValue(key: .infoBannerDismissable)
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
					print("failed with \(String(describing: error))")
				case .throttled:
					print("Throttled")
				@unknown default:
					print("failed with possible error \(String(describing: error))")
			}
		}
	}

	func observeUpdates() {
		remoteConfig.addOnConfigUpdateListener { [weak self] configUpdate, error in
			if let error {
				print(error)
				return
			}
			print("Updated keys: \(String(describing: configUpdate?.updatedKeys))")
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
		shouldUpdateCallback?()
	}
}

class MockRemoteConfigManager: RemoteConfigManagerImplementation {
	var shouldUpdateCallback: VoidCallback?
	
	func getConfigValue<T>(type: T.Type, key: RemoteConfigKey) -> T? {
		switch type {
			case is String.Type:
				return "Dummy Text" as? T
			case is Bool.Type:
				return true as? T
			case is Int.Type:
				return 10 as? T
			default:
				return nil
		}
	}
}
