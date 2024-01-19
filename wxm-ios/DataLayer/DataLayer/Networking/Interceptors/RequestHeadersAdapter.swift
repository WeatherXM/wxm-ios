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

class RequestHeadersAdapter: RequestAdapter {

    func adapt(_ urlRequest: URLRequest, for session: Alamofire.Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        var urlRequest = urlRequest
        generateClientId { clientId in
            urlRequest.setValue(clientId, forHTTPHeaderField: NetworkConstants.HttpHeaderField.clientIdentifier.rawValue)
            completion(.success(urlRequest))
        }
    }
}

private extension RequestHeadersAdapter {
    func generateClientId(callback: @escaping GenericCallback<String>) {
        Task {
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

            callback("\(appInfo); \(iOSInfo); \(deviceInfo)")
        }
    }
}

