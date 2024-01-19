//
//  AuthApiRequestBuilder.swift
//  DataLayer
//
//  Created by Hristos Condrea on 17/5/22.
//

import Alamofire
import Foundation

enum AuthApiRequestBuilder: URLRequestConvertible {
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

    case login(username: String, password: String)
    case register(email: String, firstName: String, lastName: String)
    case logout(accessToken: String)
    case refresh(refreshToken: String)
    case resetPassword(email: String)

    // MARK: - HttpMethod

    // This returns the HttpMethod type. It's used to determine the type if several endpoints are present
    private var method: HTTPMethod {
        switch self {
        case .login, .logout, .refresh, .register, .resetPassword:
            return .post
        }
    }

    // MARK: - Path

    // The path is the part following the base url
    private var path: String {
        switch self {
        case .login:
            return "auth/login"
        case .register:
            return "auth/register"
        case .logout:
            return "auth/logout"
        case .refresh:
            return "auth/refresh"
        case .resetPassword:
            return "auth/resetPassword"
        }
    }

    // MARK: - Parameters

    // This is the queries part, it's optional because an endpoint can be without parameters
    private var parameters: Parameters? {
        switch self {
        case let .login(username, password):
            return [ParameterConstants.Auth.username: username, ParameterConstants.Auth.password: password]
        case let .register(email, firstName, lastName):
            var finalDictionary: [String: String] = [ParameterConstants.Auth.email: email]
            if !firstName.trimmingCharacters(in: .whitespaces).isEmpty {
                finalDictionary[ParameterConstants.Auth.firstName] = firstName
            }
            if !lastName.trimmingCharacters(in: .whitespaces).isEmpty {
                finalDictionary[ParameterConstants.Auth.lastName] = lastName
            }
            return finalDictionary
        case let .refresh(refreshToken):
            return [ParameterConstants.Auth.refreshToken: refreshToken]
        case let .resetPassword(email):
            return [ParameterConstants.Auth.email: email]
        case let .logout(accessToken):
            return [ParameterConstants.Auth.accessToken: accessToken]
        }
    }
}
