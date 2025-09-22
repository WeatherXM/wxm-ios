//
//  Bundle+.swift
//  PresentationLayer
//
//  Created by Danae Kikue Dimou on 3/11/22.
//

import Foundation

public enum ConfigurationKey: String {
	case mapBoxAccessToken = "MBXAccessToken"
	case mapBoxStyle = "MBXStyle"
	case teamId = "TeamId"
	case appGroup = "AppGroup"
	case apiUrl = "ApiUrl"
	case claimTokenUrl = "ClaimTokenUrl"
	case appStoreUrl = "AppStoreUrl"
	case supportUrl = "SupportUrl"
	case branchName = "BranchName"
	case mixpanelToken = "MixpanelToken"
	case deviceSupportUrl = "DeviceSupportUrl"
}

public extension Bundle {
    var bundleID: String {
        return Bundle.main.infoDictionary?["CFBundleIdentifier"] as? String ?? ""
    }

    var releaseVersionNumber: String? {
        return infoDictionary?["CFBundleShortVersionString"] as? String
    }

    var buildVersionNumber: String? {
        return infoDictionary?["CFBundleVersion"] as? String
    }

    var applicationReleaseNumber: Int {
        return infoDictionary?["ApplicationReleaseNumber"] as? Int ?? 0
    }

    var releaseVersionNumberPretty: String {
        return "\(releaseVersionNumber ?? "1.0.0")"
    }

    var buildVersionNumberPretty: String {
        return "\(buildVersionNumber ?? "1")"
    }

    var buildIDPretty: String {
        return "\(bundleID)"
    }

	var urlScheme: String? {
		let urlTypes = infoDictionary?["CFBundleURLTypes"] as? [[String: Any]]
		let type = urlTypes?.first
		let schemes = type?["CFBundleURLSchemes"] as? [String]
		let scheme = schemes?.first
		return scheme
	}

	func getConfiguration<T>(for key: ConfigurationKey) -> T? {
		Self.main.infoDictionary?[key.rawValue] as? T
	}
}
