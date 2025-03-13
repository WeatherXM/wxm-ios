//
//  MockAuthRepositoryImpl.swift
//  WeatherXMTests
//
//  Created by Pantelis Giazitsis on 7/3/25.
//

import Foundation
@testable import DomainLayer
import Alamofire
import Combine

class MockAuthRepositoryImpl {
	
}

extension MockAuthRepositoryImpl: AuthRepository {
	func login(username: String, password: String) throws -> AnyPublisher<DataResponse<NetworkTokenResponse, NetworkErrorResponse>, Never> {
		let tokenResponse = NetworkTokenResponse(token: "token", refreshToken: "refToken")
		let response = DataResponse<NetworkTokenResponse, NetworkErrorResponse>(request: nil,
																				response: nil,
																				data: nil,
																				metrics: nil,
																				serializationDuration: 0,
																				result: .success(tokenResponse))
		return Just(response).eraseToAnyPublisher()
	}
	
	func register(email: String, firstName: String, lastName: String) throws -> AnyPublisher<DataResponse<EmptyEntity, NetworkErrorResponse>, Never> {
		let emptyResponse = EmptyEntity()
		let response = DataResponse<EmptyEntity, NetworkErrorResponse>(request: nil,
																	   response: nil,
																	   data: nil,
																	   metrics: nil,
																	   serializationDuration: 0,
																	   result: .success(emptyResponse))
		return Just(response).eraseToAnyPublisher()
	}
	
	func refresh(refreshToken: String) throws -> AnyPublisher<DataResponse<NetworkTokenResponse, NetworkErrorResponse>, Never> {
		let tokenResponse = NetworkTokenResponse(token: "token", refreshToken: "refToken")
		let response = DataResponse<NetworkTokenResponse, NetworkErrorResponse>(request: nil,
																				response: nil,
																				data: nil,
																				metrics: nil,
																				serializationDuration: 0,
																				result: .success(tokenResponse))
		return Just(response).eraseToAnyPublisher()
	}
	
	func resetPassword(email: String) throws -> AnyPublisher<DataResponse<EmptyEntity, NetworkErrorResponse>, Never> {
		let emptyResponse = EmptyEntity()
		let response = DataResponse<EmptyEntity, NetworkErrorResponse>(request: nil,
																	   response: nil,
																	   data: nil,
																	   metrics: nil,
																	   serializationDuration: 0,
																	   result: .success(emptyResponse))
		return Just(response).eraseToAnyPublisher()
	}
	
	func logout(installationId: String?) throws -> AnyPublisher<DataResponse<EmptyEntity, NetworkErrorResponse>, Never> {
		let emptyResponse = EmptyEntity()
		let response = DataResponse<EmptyEntity, NetworkErrorResponse>(request: nil,
																	   response: nil,
																	   data: nil,
																	   metrics: nil,
																	   serializationDuration: 0,
																	   result: .success(emptyResponse))
		return Just(response).eraseToAnyPublisher()
	}
	
	func passwordValidation(password: String) throws -> AnyPublisher<DataResponse<NetworkTokenResponse, NetworkErrorResponse>, Never> {
		let tokenResponse = NetworkTokenResponse(token: "token", refreshToken: "refToken")
		let response = DataResponse<NetworkTokenResponse, NetworkErrorResponse>(request: nil,
																				response: nil,
																				data: nil,
																				metrics: nil,
																				serializationDuration: 0,
																				result: .success(tokenResponse))
		return Just(response).eraseToAnyPublisher()
		
	}
	
	
}
