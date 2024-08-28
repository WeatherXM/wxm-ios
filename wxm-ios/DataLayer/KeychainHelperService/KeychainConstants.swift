//
//  KeychainConstants.swift
//  DataLayer
//
//  Created by Hristos Condrea on 8/8/22.
//

import Foundation
public enum KeychainConstants {
	public static let userAccessTokenService = "UserAccessTokenService"
	public static let refreshAccessTokenService = "UserRefreshTokenService"
	public static let account = "Account"
	public static let username = "Username"
	public static let password = "Password"

	case saveNetworkTokenResponse
	case saveAccountInfo

	public var service: String {
		switch self {
			case .saveNetworkTokenResponse:
				return "SaveNetworkTokenService"
			case .saveAccountInfo:
				return "SaveAccountInfo"
		}
	}

	public var account: String {
		switch self {
			case .saveNetworkTokenResponse, .saveAccountInfo:
				return "WeatherXM"
		}
	}
}
