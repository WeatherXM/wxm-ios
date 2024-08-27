//
//  DevicesApiRequestBuilder.swift
//  DataLayer
//
//  Created by Danae Kikue Dimou on 18/5/22.
//
import Alamofire
import Foundation
import SwiftUI

enum DevicesApiRequestBuilder: URLRequestConvertible {
    // MARK: - URLRequestConvertible

    func asURLRequest() throws -> URLRequest {
        let url = try NetworkConstants.baseUrl.asURL()

        var urlRequest = URLRequest(url: url.appendingPathComponent(path))
        // Http method
        urlRequest.httpMethod = method.rawValue

        // Common Headers
        urlRequest.setValue(NetworkConstants.ContentType.json.rawValue, forHTTPHeaderField: NetworkConstants.HttpHeaderField.acceptType.rawValue)
        urlRequest.setValue(NetworkConstants.ContentType.json.rawValue, forHTTPHeaderField: NetworkConstants.HttpHeaderField.contentType.rawValue)
        urlRequest.cachePolicy = .reloadRevalidatingCacheData

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

    case devices
    case deviceById(deviceId: String)
	case deviceRewardsById(deviceId: String)
	case deviceRewardsTimeline(deviceId: String, page: Int, pageSize: Int?, fromDate: String, toDate: String?, timezone: String?)
	case deviceRewardsDetailsById(deviceId: String, date: String)
	case deviceRewardsBoosts(deviceId: String, code: String)

    // MARK: - HttpMethod

    // This returns the HttpMethod type. It's used to determine the type if several endpoints are peresent
	private var method: HTTPMethod {
		switch self {
			case .devices, .deviceById, .deviceRewardsById, .deviceRewardsTimeline, .deviceRewardsDetailsById, .deviceRewardsBoosts:
				return .get
		}
	}

    // MARK: - Path

    // The path is the part following the base url
	private var path: String {
		switch self {
			case .devices:
				return "devices"
			case let .deviceById(deviceId):
				return "devices/\(deviceId)"
			case let .deviceRewardsById(deviceId):
				return "devices/\(deviceId)/rewards"
			case let .deviceRewardsTimeline(deviceId, _, _, _, _, _):
				return "devices/\(deviceId)/rewards/timeline"
			case let .deviceRewardsDetailsById(deviceId, _):
				return "devices/\(deviceId)/rewards/details"
			case let .deviceRewardsBoosts(deviceId, code):
				return "devices/\(deviceId)/rewards/boosts/\(code)"
		}
    }

    // MARK: - Parameters

    // This is the queries part, it's optional because an endpoint can be without parameters
    private var parameters: Parameters? {
        switch self {
            case let .deviceRewardsTimeline(_, page, pageSize, fromDate, toDate, timezone):
                var params: Parameters = [
                    ParameterConstants.Devices.page: page,
                    ParameterConstants.Devices.fromDate: fromDate
                ]

                if let pageSize {
                    params[ParameterConstants.Devices.pageSize] = pageSize
                }

                if let toDate {
                    params[ParameterConstants.Devices.toDate] = toDate
                }

				if let timezone {
					params[ParameterConstants.Devices.timezone] = timezone
				}

                return params
			case let .deviceRewardsDetailsById(_, date):
				return [ParameterConstants.Devices.date: date]
            default: return nil
        }
    }
}

extension DevicesApiRequestBuilder: MockResponseBuilder {
	var mockFileName: String? {
		switch self {
			case .deviceRewardsById:
				return "get_device_rewards_summary"
			case .deviceRewardsTimeline:
				return "get_device_rewards_timeline"
			case .deviceRewardsDetailsById:
				return "get_reward_details"
			case .deviceRewardsBoosts:
				return "get_reward_boosts"
			default:
				return nil
		}
	}
}
