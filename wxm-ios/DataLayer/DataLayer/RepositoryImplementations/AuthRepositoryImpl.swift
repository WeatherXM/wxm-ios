//
//  AuthRepositoryImpl.swift
//  DataLayer
//
//  Created by Hristos Condrea on 17/5/22.
//

import Alamofire
import Combine
@preconcurrency import DomainLayer
import Foundation
import WidgetKit

public struct AuthRepositoryImpl: AuthRepository {
    public func passwordValidation(password: String) throws -> AnyPublisher<DataResponse<NetworkTokenResponse, NetworkErrorResponse>, Never> {

        let keychainHelperService = KeychainHelperService()
        let accountInfo = keychainHelperService.getUsersAccountInfo()
        return try login(username: accountInfo?.email ?? "", password: password)
    }

    public func login(username: String, password: String) throws -> AnyPublisher<DataResponse<NetworkTokenResponse, NetworkErrorResponse>, Never> {
        let urlRequest = try AuthApiRequestBuilder.login(username: username, password: password).asURLRequest()
		let publisher: AnyPublisher<DataResponse<NetworkTokenResponse, NetworkErrorResponse>, Never> = ApiClient.shared.requestCodable(urlRequest)

		return publisher.flatMap { response in
			if response.error == nil {
				WidgetCenter.shared.reloadAllTimelines()
			}
			return Just(response)
		}.eraseToAnyPublisher()
    }

    public func register(email: String, firstName: String, lastName: String) throws -> AnyPublisher<DataResponse<EmptyEntity, NetworkErrorResponse>, Never> {
        let urlRequest = try AuthApiRequestBuilder.register(email: email, firstName: firstName, lastName: lastName).asURLRequest()
        return ApiClient.shared.requestCodable(urlRequest)
    }

	public func logout(installationId: String?) throws -> AnyPublisher<DataResponse<EmptyEntity, NetworkErrorResponse>, Never> {
        guard let token = KeychainHelperService().getNetworkTokenResponse()?.token else {
            throw AuthError.missingAccessToken
        }
        
        let urlRequest = try AuthApiRequestBuilder.logout(accessToken: token, installationId: installationId).asURLRequest()
        return ApiClient.shared.requestCodable(urlRequest)
    }

    public func refresh(refreshToken: String) throws -> AnyPublisher<DataResponse<NetworkTokenResponse, NetworkErrorResponse>, Never> {
        let urlRequest = try AuthApiRequestBuilder.refresh(refreshToken: refreshToken).asURLRequest()
        return ApiClient.shared.requestCodable(urlRequest)
    }

    public func resetPassword(email: String) throws -> AnyPublisher<DataResponse<EmptyEntity, NetworkErrorResponse>, Never> {
        let urlRequest = try AuthApiRequestBuilder.resetPassword(email: email).asURLRequest()
        return ApiClient.shared.requestCodable(urlRequest)
    }

    public init() {}
}
