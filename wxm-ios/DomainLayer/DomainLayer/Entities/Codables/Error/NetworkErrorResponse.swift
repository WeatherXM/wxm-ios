//
//  NetworkErrorResponse.swift
//  DomainLayer
//
//  Created by Hristos Condrea on 17/5/22.
//

import Alamofire
import Foundation
import Toolkit

public struct NetworkErrorResponse: Error {
    public let initialError: AFError
    public let backendError: BackendError?

    public init(initialError: AFError, backendError: BackendError?) {
        self.initialError = initialError
        self.backendError = backendError
    }

    public var toErrorUserInfo: [String: Any]? {
        backendError?.toErrorUserInfo
    }
}

extension NetworkErrorResponse: NetworkError {
    public var code: Int {
        initialError.responseCode ?? -1
    }

    public var userInfo: [String: Any]? {
        backendError?.toErrorUserInfo
    }
}

public struct BackendError: Codable, Error {
    public var code: String = ""
    public var message: String = ""
    public var id: String = ""
    public var path: String = ""

    private enum UserInfoKeys: String {
        case code
        case message
        case id
        case path
    }

    var toErrorUserInfo: [String: Any] {
        [UserInfoKeys.code.rawValue: code,
         UserInfoKeys.message.rawValue: message,
         UserInfoKeys.id.rawValue: id,
         UserInfoKeys.path.rawValue: path]
    }
}
