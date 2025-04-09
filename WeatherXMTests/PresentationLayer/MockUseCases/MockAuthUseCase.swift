//
//  MockAuthUseCase.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 2/4/25.
//

import DomainLayer
import Alamofire
import Combine

struct MockAuthUseCase: AuthUseCaseApi {
	static let wrongPassword = "wrongPassword"
	static let invalidEmail = "invalidEmail"

	func login(username: String, password: String) throws -> AnyPublisher<DataResponse<NetworkTokenResponse, NetworkErrorResponse>, Never> {
		let tokenResponse = NetworkTokenResponse(token: "token", refreshToken: "refToken")
		let result: Result<NetworkTokenResponse, NetworkErrorResponse>
		if password == MockAuthUseCase.wrongPassword {
			result = .failure(NetworkErrorResponse(initialError: .explicitlyCancelled,
												   backendError: nil))
		} else {
			result = .success(tokenResponse)
		}

		let response = DataResponse<NetworkTokenResponse, NetworkErrorResponse>(request: nil,
																				response: nil,
																				data: nil,
																				metrics: nil,
																				serializationDuration: 0,
																				result: result)
		return Just(response).eraseToAnyPublisher()
	}
	
	func register(email: String, firstName: String, lastName: String) throws -> AnyPublisher<DataResponse<EmptyEntity, NetworkErrorResponse>, Never> {
		let emptyResponse = EmptyEntity.emptyValue()
		let result: Result<EmptyEntity, NetworkErrorResponse>
		if email == MockAuthUseCase.invalidEmail {
			result = .failure(NetworkErrorResponse(initialError: .explicitlyCancelled,
												   backendError: nil))
		} else {
			result = .success(emptyResponse)
		}

		let response = DataResponse<EmptyEntity, NetworkErrorResponse>(request: nil,
																	   response: nil,
																	   data: nil,
																	   metrics: nil,
																	   serializationDuration: 0,
																	   result: result)
		return Just(response).eraseToAnyPublisher()
	}
	
	func logout() throws -> AnyPublisher<DataResponse<EmptyEntity, NetworkErrorResponse>, Never> {
		let emptyResponse = EmptyEntity.emptyValue()
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
		let emptyResponse = EmptyEntity.emptyValue()
		let result: Result<EmptyEntity, NetworkErrorResponse>
		if email == MockAuthUseCase.invalidEmail {
			result = .failure(NetworkErrorResponse(initialError: .explicitlyCancelled,
												   backendError: nil))
		} else {
			result = .success(emptyResponse)
		}

		let response = DataResponse<EmptyEntity, NetworkErrorResponse>(request: nil,
																	   response: nil,
																	   data: nil,
																	   metrics: nil,
																	   serializationDuration: 0,
																	   result: result)
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
	
	func getUsersEmail() -> String {
		""
	}
	
	func isUserLoggedIn() -> Bool {
		false
	}
	
}
