//
//  NetworkApiRequestBuilder.swift
//  DataLayer
//
//  Created by Pantelis Giazitsis on 12/6/23.
//

import Foundation
import Alamofire

enum NetworkApiRequestBuilder: URLRequestConvertible {

    case stats
    case search(query: String, exact: Bool, exclude: String?)
	case rewardsWithdraw(wallet: String)

    // MARK: - URLRequestConvertible

    func asURLRequest() throws -> URLRequest {
        let url = try NetworkConstants.baseUrl.asURL()

        var urlRequest = URLRequest(url: url.appendingPathComponent(path))
        // Http method
        urlRequest.httpMethod = method.rawValue

        // Common Headers
        urlRequest.setValue(NetworkConstants.ContentType.json.rawValue, forHTTPHeaderField: NetworkConstants.HttpHeaderField.acceptType.rawValue)
        urlRequest.setValue(NetworkConstants.ContentType.json.rawValue, forHTTPHeaderField: NetworkConstants.HttpHeaderField.contentType.rawValue)

        // Encoding
        let encoding: ParameterEncoding = {
            switch method {
                case .get:
                    return URLEncoding(boolEncoding: .literal)
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
			case .stats, .search, .rewardsWithdraw:
                return .get
        }
    }

    // MARK: - Path

    // The path is the part following the base url
    private var path: String {
        switch self {
            case .stats:
                return "network/stats"
            case .search:
                return "network/search"
			case .rewardsWithdraw:
				return "network/rewards/withdraw"
        }
    }

    // MARK: - Parameters

    // This is the queries part, it's optional because an endpoint can be without parameters
    private var parameters: Parameters? {
        switch self {
            case .stats:
                return nil
            case .search(let query, let exact, let exclude):
                var params: Parameters = ["query": query,
                                          "exact": exact]
                if let exclude {
                    params["exclude"] = exclude
                }
                return params
			case .rewardsWithdraw(let wallet):
				let params: Parameters = ["address": wallet]
				return params
        }
    }
}

extension NetworkApiRequestBuilder: MockResponseBuilder {
    var mockFileName: String? {
        switch self {
            case .stats:
                return "get_network_stats"
            case .search:
                return "get_network_search"
			case .rewardsWithdraw:
				return "get_user_rewards"
        }
    }
}
