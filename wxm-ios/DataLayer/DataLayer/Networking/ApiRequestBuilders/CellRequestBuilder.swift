//
//  CellRequestBuilder.swift
//  DataLayer
//
//  Created by Lampros Zouloumis on 17/8/22.
//

import Alamofire
import Foundation

enum CellRequestBuilder: URLRequestConvertible {
	case getCells
	case getCellsDevices(index: String)
	case getCellsDevicesDetails(index: String, deviceId: String)
	case getCellForecast(lat: Double, lon: Double)

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
	
	// MARK: - HttpMethod
	
	// This returns the HttpMethod type. It's used to determine the type if several endpoints are peresent
	private var method: HTTPMethod {
		switch self {
			case .getCells, .getCellsDevices, .getCellsDevicesDetails, .getCellForecast:
				return .get
		}
	}
	
	// MARK: - Path
	
	// The path is the part following the base url
	private var path: String {
		switch self {
			case .getCells:
				return "cells"
			case let .getCellsDevices(index):
				return "cells/\(index)/devices"
			case let .getCellsDevicesDetails(index, deviceId):
				return "cells/\(index)/devices/\(deviceId)"
			case .getCellForecast:
				return "cells/forecast"
		}
	}
	
	// MARK: - Parameters
	
	// This is the queries part, it's optional because an endpoint can be without parameters
	private var parameters: Parameters? {
		switch self {
			case let .getCellForecast(lat, lon):
				return [ParameterConstants.Cells.lat: lat,
						ParameterConstants.Cells.lon: lon]
			default: return nil
		}
	}
}

extension CellRequestBuilder: MockResponseBuilder {
	var mockFileName: String? {
		switch self {
			case .getCellsDevices:
				return "get_cell_devices"
			case .getCells:
				return "get_cells"
			default:
				return nil
		}
	}
}
