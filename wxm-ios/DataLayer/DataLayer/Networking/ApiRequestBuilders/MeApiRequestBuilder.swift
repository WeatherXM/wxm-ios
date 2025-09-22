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
		var url = try NetworkConstants.baseUrl.asURL()

		if case .deviceSupport(_) = self {
			url = try NetworkConstants.deviceSupportUrl.asURL()
		}

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
	case setDeviceFrequency(serialNumber: String, frequency: String)
	case getFirmwares(testSearch: String)
	case getUserDeviceById(deviceId: String)
	case getUserDeviceInfoById(deviceId: String)
	case getUserDeviceHistoryById(deviceId: String, fromDate: String, toDate: String, exclude: String)
	case getUserDeviceForecastById(deviceId: String, fromDate: String, toDate: String, exclude: String)
	case getUserDeviceRewards(deviceId: String, mode: String)
	case getUserDevicesRewards(mode: String)
	case getUserDevicePhotos(deviceId: String)
	case deleteUserDevicePhoto(deviceId: String, photoId: String)
	case getDeviceFirmwareById(deviceId: String)
	case setFriendlyName(deviceId: String, name: String)
	case deleteFriendlyName(deviceId: String)
	case deleteAccount
	case follow(deviceId: String)
	case unfollow(deviceId: String)
	case setDeviceLocation(deviceId: String, lat: Double, lon: Double)
	case setFCMToken(installationId: String, token: String)
	case postPhotoNames(deviceId: String, photos: [String])
	case deviceSupport(deviceName: String)

	// MARK: - HttpMethod

	// This returns the HttpMethod type. It's used to determine the type if several endpoints are peresent
	private var method: HTTPMethod {
		switch self {
			case .getUser, .getUserWallet, .getDevices, .getFirmwares, .getUserDeviceById,
					.getUserDeviceHistoryById, .getUserDeviceForecastById, .getUserDeviceRewards, 
					.getUserDevicesRewards, .getUserDevicePhotos, .getDeviceFirmwareById, .getUserDeviceInfoById, .deviceSupport:
				return .get
			case .saveUserWallet, .claimDevice, .setDeviceFrequency, .setFriendlyName, .disclaimDevice,
					.follow, .setDeviceLocation, .setFCMToken, .postPhotoNames:
				return .post
			case .deleteUserDevicePhoto, .deleteAccount, .deleteFriendlyName, .unfollow:
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
			case .setDeviceFrequency:
				return "me/devices/frequency"
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
			case let .getUserDevicePhotos(deviceId):
				return "me/devices/\(deviceId)/photos"
			case let .deleteUserDevicePhoto(deviceId, photoId):
				return "me/devices/\(deviceId)/photos/\(photoId)"
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
			case let .postPhotoNames(deviceId, photos):
				return "me/devices/\(deviceId)/photos"
			case .deviceSupport:
				return "station-summary"
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
			case let .setDeviceFrequency(serialNumber, frequency):
				return [ParameterConstants.Me.serialNumber: serialNumber,
						ParameterConstants.Me.freq: frequency]
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
			case let .postPhotoNames(_, photos):
				return [ParameterConstants.Me.names: photos]
			case let .deviceSupport(deviceName):
				return [ParameterConstants.Me.stationName: deviceName]
			default:
				return nil
		}
	}
}

extension MeApiRequestBuilder: MockResponseBuilder {
	var mockFileName: String? {
		switch self {
			case .claimDevice(let body):
				if body.secret != nil {
					return "claim_device_helium"
				}
				return "claim_device"
			case .getDevices:
				return "get_user_devices"
			case .getUserDeviceById,
					.setDeviceLocation:
				return "get_user_device"
			case .getUserDeviceHistoryById:
				return "get_device_history"
			case .getUserDeviceInfoById:
				return "get_device_info_pulse"
			case .getUserWallet:
				return "get_user_wallet"
			case .getUserDeviceForecastById:
				return "get_user_device_forecast"
			case .getUserDeviceRewards(_, let mode):
				switch mode {
					case DeviceRewardsMode.week.rawValue:
						return "get_device_rewards_analytics_7d"
					case DeviceRewardsMode.year.rawValue:
						return "get_device_rewards_analytics_year"
					default:
						return "get_device_rewards_analytics"
				}
			case .getUserDevicePhotos:
				return "get_user_device_photos"
			case .getUserDevicesRewards(let mode):
				switch mode {
					case DeviceRewardsMode.week.rawValue:
						return "get_devices_rewards_analytics_7d"
					case DeviceRewardsMode.year.rawValue:
						return "get_devices_rewards_analytics_year"
					default:
						return "get_devices_rewards_analytics"
				}
			case .getUser:
				return "get_user"
			case .deleteUserDevicePhoto:
				return "empty_response"
			case .postPhotoNames:
				return "post_device_photos"
			case .saveUserWallet:
				return "empty_response"
			case .disclaimDevice:
				return "empty_response"
			case .follow:
				return "empty_response"
			case .unfollow, .setFriendlyName, .deleteFriendlyName:
				return "empty_response"
			case .deviceSupport:
				return "get_station_support"
			default:
				return nil
		}
	}
}
