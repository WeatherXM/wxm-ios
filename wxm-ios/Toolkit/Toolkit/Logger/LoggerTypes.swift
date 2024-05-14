//
//  LoggerTypes.swift
//  Toolkit
//
//  Created by Pantelis Giazitsis on 1/3/23.
//

import Foundation

public protocol NetworkError: Error {
    var code: Int { get }
    var userInfo: [String: Any]? { get }
}
