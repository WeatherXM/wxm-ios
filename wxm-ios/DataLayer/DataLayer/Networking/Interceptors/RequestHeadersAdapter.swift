//
//  RequestHeadersAdapter.swift
//  DataLayer
//
//  Created by Pantelis Giazitsis on 28/4/23.
//

import Foundation
import Alamofire
import Toolkit
import UIKit

class RequestHeadersAdapter: @unchecked Sendable, RequestAdapter {

	func adapt(_ urlRequest: URLRequest, for session: Alamofire.Session, completion: @escaping @Sendable (Result<URLRequest, Error>) -> Void) {
		var urlRequest = urlRequest
		Task { @MainActor in
			let clientId = await generateClientId()
			urlRequest.setValue(clientId, forHTTPHeaderField: NetworkConstants.HttpHeaderField.clientIdentifier.rawValue)
			completion(.success(urlRequest))
		}
    }
}

private extension RequestHeadersAdapter {
	func generateClientId() async -> String {
		// App Info
		let bundleId: String = Bundle.main.bundleID
		let appVersion: String = Bundle.main.releaseVersionNumberPretty
		let buildNumber: String = Bundle.main.buildVersionNumber ?? ""

		let installationId: String = await FirebaseManager.shared.getInstallationId()

		let appInfo = "wxm-ios (\(bundleId)); \(appVersion)(\(buildNumber)); \(installationId)"

		// iOS Info
		let systemVersion = await UIDevice.current.systemVersion
		let iOSInfo = "iOS: \(systemVersion)"

		// Device Info
		let deviceInfo = "Device: \(await UIDevice.modelName)"

		return "\(appInfo); \(iOSInfo); \(deviceInfo)"
	}
}
