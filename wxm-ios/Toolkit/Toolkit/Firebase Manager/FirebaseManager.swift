//
//  FirebaseManager.swift
//  Toolkit
//
//  Created by Pantelis Giazitsis on 1/3/23.
//

import Firebase
import FirebaseCore
import Foundation
import FirebaseAnalytics

public class FirebaseManager {
    public static let shared: FirebaseManager = .init()
	private let firebaseManagerImpl: FirbaseManagerImplementation

    private init() {
		if disableFirebase {
			self.firebaseManagerImpl = MockFirebaseManager()
		} else {
			self.firebaseManagerImpl = RemoteFirebaseManager()
		}
	}

    public func launch() {
		firebaseManagerImpl.launch()
    }

    public func getInstallationId() async -> String {
		await firebaseManagerImpl.getInstallationId()
    }

    public func setAnalyticsCollectionEnabled(_ enabled: Bool) {
		firebaseManagerImpl.setAnalyticsCollectionEnabled(enabled)
    }
}

private class RemoteFirebaseManager: FirbaseManagerImplementation {
	private var installationId: String? {
		didSet {
			Crashlytics.crashlytics().setCustomValue(installationId, forKey: installationIdKey)
		}
	}

	func launch() {
		FirebaseApp.configure()
	}

	func getInstallationId() async -> String {
		guard let installationId else {
			await assignInstallationId()
			return installationId ?? "N/A"
		}

		return installationId
	}

	func setAnalyticsCollectionEnabled(_ enabled: Bool) {
		Analytics.setAnalyticsCollectionEnabled(enabled)
	}

	private func assignInstallationId() async {
		return await withCheckedContinuation { continuation in
			Installations.installations().installationID { [weak self] installationId, error in
				defer {
					continuation.resume()
				}

				if let error {
					print("Failed to retrieve installationId with \(error)")
					self?.installationId = "N/A"
					return
				}

				self?.installationId = installationId
			}
		}
	}
}

private class MockFirebaseManager: FirbaseManagerImplementation {
	func launch() {}
	func getInstallationId() async -> String { return "" }
	func setAnalyticsCollectionEnabled(_ enabled: Bool) {}
}
