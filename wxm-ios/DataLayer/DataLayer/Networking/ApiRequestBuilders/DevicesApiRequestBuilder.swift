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
	case deviceRewardsTimeline(deviceId: String, page: Int, pageSize: Int?, timezone: String, fromDate: String, toDate: String?)

    // MARK: - HttpMethod

    // This returns the HttpMethod type. It's used to determine the type if several endpoints are peresent
	private var method: HTTPMethod {
		switch self {
			case .devices, .deviceById, .deviceRewardsById, .deviceRewardsTimeline:
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
				return "devices/\(deviceId)/tokens"
			case let .deviceRewardsTimeline(deviceId, _, _, _, _, _):
				return "devices/\(deviceId)/tokens/timeline"
		}
    }

    // MARK: - Parameters

    // This is the queries part, it's optional because an endpoint can be without parameters
    private var parameters: Parameters? {
        switch self {
            case let .deviceRewardsTimeline(_, page, pageSize, timezone, fromDate, toDate):
                var params: Parameters = [
                    ParameterConstants.Me.page: page,
                    ParameterConstants.Me.fromDate: fromDate,
                    ParameterConstants.Me.timezone: timezone,
                ]

                if let pageSize {
                    params[ParameterConstants.Me.pageSize] = pageSize
                }

                if let toDate {
                    params[ParameterConstants.Me.toDate] = toDate
                }

                return params
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
			default:
				return nil
		}
	}
}

