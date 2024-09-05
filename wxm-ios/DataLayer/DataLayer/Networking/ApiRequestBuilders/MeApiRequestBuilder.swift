//
//  MeApiRequestBuilder.swift
//  DataLayer
//
//  Created by Danae Kikue Dimou on 18/5/22.
//

import Alamofire
import DomainLayer
import Foundation

enum MeApiRequestBuilder: URLRequestConvertible {
	// MARK: - URLRequestConvertible

	func asURLRequest() throws -> URLRequest {
		let url = try NetworkConstants.baseUrl.asURL()

		var urlRequest = URLRequest(url: url.appendingPathComponent(path))
		// Http method
		urlRequest.httpMethod = method.rawValue
		// Common Headers
		urlRequest.setValue(acceptField.rawValue, forHTTPHeaderField: NetworkConstants.HttpHeaderField.acceptType.rawValue)
		urlRequest.setValue(NetworkConstants.ContentType.json.rawValue, forHTTPHeaderField: NetworkConstants.HttpHeaderField.contentType.rawValue)

		// Encoding
		let encoding: ParameterEncoding = {
			switch method {
				case .get:
					return URLEncoding.default
				default:
					return JSONEncoding.default
			}
		}()

		return try encoding.encode(urlRequest, with: parameters)
	}

	case getUser
	case getUserWallet
	case saveUserWallet(address: String)
	case getDevices
	case claimDevice(claimDeviceBody: ClaimDeviceBody)
	case disclaimDevice(serialNumber: String)
	case getFirmwares(testSearch: String)
	case getUserDeviceById(deviceId: String)
	case getUserDeviceInfoById(deviceId: String)
	case getUserDeviceHistoryById(deviceId: String, fromDate: String, toDate: String, exclude: String)
	case getUserDeviceForecastById(deviceId: String, fromDate: String, toDate: String, exclude: String)
	case getUserDeviceRewards(deviceId: String, mode: String)
	case getUserDevicesRewards(mode: String)
	case getDeviceFirmwareById(deviceId: String)
	case setFriendlyName(deviceId: String, name: String)
	case deleteFriendlyName(deviceId: String)
	case deleteAccount
	case follow(deviceId: String)
	case unfollow(deviceId: String)
	case setDeviceLocation(deviceId: String, lat: Double, lon: Double)
	case setFCMToken(installationId: String, token: String)

	// MARK: - HttpMethod

	// This returns the HttpMethod type. It's used to determine the type if several endpoints are peresent
	private var method: HTTPMethod {
		switch self {
			case .getUser, .getUserWallet, .getDevices, .getFirmwares, .getUserDeviceById,
					.getUserDeviceHistoryById, .getUserDeviceForecastById, .getUserDeviceRewards, 
					.getUserDevicesRewards, .getDeviceFirmwareById, .getUserDeviceInfoById:
				return .get
			case .saveUserWallet, .claimDevice, .setFriendlyName, .disclaimDevice, .follow, .setDeviceLocation, .setFCMToken:
				return .post
			case .deleteAccount, .deleteFriendlyName, .unfollow:
				return .delete
		}
	}

	// MARK: - Headers

	private var acceptField: NetworkConstants.ContentType {
		switch self {
			case .getDeviceFirmwareById:
				return .octetStream
			default:
				return .json
		}
	}

	// MARK: - Path

	// The path is the part following the base url
	private var path: String {
		switch self {
			case .getUser, .deleteAccount:
				return "me"
			case .getUserWallet:
				return "me/wallet"
			case .saveUserWallet:
				return "me/wallet"
			case .getDevices:
				return "me/devices"
			case .claimDevice:
				return "me/devices/claim"
			case .disclaimDevice:
				return "me/devices/disclaim"
			case .getFirmwares:
				return "me/devices/firmware"
			case let .getUserDeviceById(deviceId):
				return "me/devices/\(deviceId)"
			case let .getUserDeviceInfoById(deviceId):
				return "me/devices/\(deviceId)/info"
			case let .getUserDeviceHistoryById(deviceId, _, _, _):
				return "me/devices/\(deviceId)/history"
			case let .getUserDeviceForecastById(deviceId, _, _, _):
				return "me/devices/\(deviceId)/forecast"
			case let .getUserDeviceRewards(deviceId, _):
				return "me/devices/\(deviceId)/rewards"
			case .getUserDevicesRewards:
				return "me/devices/rewards"
			case let .getDeviceFirmwareById(deviceId: deviceId):
				return "me/devices/\(deviceId)/firmware"
			case let .setFriendlyName(deviceId, _):
				return "me/devices/\(deviceId)/friendlyName"
			case let .deleteFriendlyName(deviceId):
				return "me/devices/\(deviceId)/friendlyName"
			case let .follow(deviceId):
				return "me/devices/\(deviceId)/follow"
			case let .unfollow(deviceId):
				return "me/devices/\(deviceId)/follow"
			case let .setDeviceLocation(deviceId, _, _):
				return "me/devices/\(deviceId)/location"
			case let .setFCMToken(installationId, token):
				return "me/notifications/fcm/installations/\(installationId)/tokens/\(token)"
		}
	}

	// MARK: - Parameters

	// This is the queries part, it's optional because an endpoint can be without parameters
	private var parameters: Parameters? {
		switch self {
			case let .saveUserWallet(address):
				return [ParameterConstants.Me.address: address]
			case let .claimDevice(claimDeviceBody):
				return claimDeviceBody.dictionaryRepresentation
			case let .disclaimDevice(serialNumber):
				return [ParameterConstants.Me.serialNumber: serialNumber]
			case let .getFirmwares(testSearch):
				return [ParameterConstants.Me.testSearch: testSearch]
			case let .getUserDeviceHistoryById(_, fromDate, toDate, exclude):
				return [
					ParameterConstants.Me.fromDate: fromDate,
					ParameterConstants.Me.toDate: toDate,
					ParameterConstants.Me.exclude: exclude
				]
			case let .getUserDeviceForecastById(_, fromDate, toDate, exclude):
				if exclude.isEmpty {
					return [
						ParameterConstants.Me.fromDate: fromDate,
						ParameterConstants.Me.toDate: toDate
					]
				} else {
					return [
						ParameterConstants.Me.fromDate: fromDate,
						ParameterConstants.Me.toDate: toDate,
						ParameterConstants.Me.exclude: exclude
					]
				}
			case let .getUserDeviceRewards(_, mode), let .getUserDevicesRewards(mode):
				return [ParameterConstants.Me.mode: mode]
			case let .setFriendlyName(_, name):
				return [ParameterConstants.Me.friendlyName: name]
			case let .setDeviceLocation(_, lat, lon):
				return [ParameterConstants.Me.lat: lat,
						ParameterConstants.Me.lon: lon]
			default:
				return nil
		}
	}
}

extension MeApiRequestBuilder: MockResponseBuilder {
	var mockFileName: String? {
		switch self {
			case .getDevices:
				return "get_user_devices"
			case .getUserDeviceById:
				return "get_user_device"
			case .getUserDeviceHistoryById:
				return "get_device_history"
			case .getUserDeviceInfoById:
				return "get_device_info_helium"
			case .getUserWallet:
				return "get_user_wallet"
			case .getUserDeviceForecastById:
				return "get_user_device_forecast"
			case .getUserDeviceRewards:
				return "get_device_rewards_analytics"
			case .getUserDevicesRewards:
				return "get_devices_rewards_analytics"
			case .getUser:
				return "get_user"
			default:
				return nil
		}
	}
}
