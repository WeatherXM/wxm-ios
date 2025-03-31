//
//  AuthUseCaseApi.swift
//  DomainLayer
//
//  Created by Pantelis Giazitsis on 31/3/25.
//

import Alamofire
import Combine

public protocol AuthUseCaseApi {
	func login(username: String, password: String) throws -> AnyPublisher<DataResponse<NetworkTokenResponse, NetworkErrorResponse>, Never>
	func register(email: String, firstName: String, lastName: String) throws -> AnyPublisher<DataResponse<EmptyEntity, NetworkErrorResponse>, Never>
	func logout() throws -> AnyPublisher<DataResponse<EmptyEntity, NetworkErrorResponse>, Never>
	func refresh(refreshToken: String) throws -> AnyPublisher<DataResponse<NetworkTokenResponse, NetworkErrorResponse>, Never>
	func resetPassword(email: String) throws -> AnyPublisher<DataResponse<EmptyEntity, NetworkErrorResponse>, Never>
	func passwordValidation(password: String)throws -> AnyPublisher<DataResponse<NetworkTokenResponse, NetworkErrorResponse>, Never>
	func getUsersEmail() -> String
	func isUserLoggedIn() -> Bool
}
