//
//  AuthRepository.swift
//  DomainLayer
//
//  Created by Hristos Condrea on 17/5/22.
//

import Alamofire
import Combine
import Foundation

public protocol AuthRepository {
    func login(username: String, password: String) throws -> AnyPublisher<DataResponse<NetworkTokenResponse, NetworkErrorResponse>, Never>
    func register(email: String, firstName: String, lastName: String) throws -> AnyPublisher<DataResponse<EmptyEntity, NetworkErrorResponse>, Never>
    func refresh(refreshToken: String) throws -> AnyPublisher<DataResponse<NetworkTokenResponse, NetworkErrorResponse>, Never>
    func resetPassword(email: String) throws -> AnyPublisher<DataResponse<EmptyEntity, NetworkErrorResponse>, Never>
	func logout(installationId: String?) throws -> AnyPublisher<DataResponse<EmptyEntity, NetworkErrorResponse>, Never>
    func passwordValidation(password: String) throws -> AnyPublisher<DataResponse<NetworkTokenResponse, NetworkErrorResponse>, Never>
}

public enum AuthError: Error {
    case missingAccessToken
}
