//
//  Client.swift
//  DataLayer
//
//  Created by Pantelis Giazitsis on 30/1/25.
//

import Foundation
import Combine
import Alamofire
import DomainLayer

protocol Client {
	func requestCodable<T: Codable>(_ urlConvertible: URLRequestConvertible, mockFileName: String?) -> AnyPublisher<DataResponse<T, NetworkErrorResponse>, Never>
	func requestCodableAuthorized<T: Codable>(_ urlConvertible: URLRequestConvertible, mockFileName: String?) -> AnyPublisher<DataResponse<T, NetworkErrorResponse>, Never>
	func downloadFile(_ urlConvertible: URLRequestConvertible, destinationFileUrl: URL) -> AnyPublisher<DownloadResponse<Data, NetworkErrorResponse>, Never>
}
