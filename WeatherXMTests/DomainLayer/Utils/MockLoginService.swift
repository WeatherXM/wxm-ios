//
//  MockLoginService.swift
//  WeatherXMTests
//
//  Created by Pantelis Giazitsis on 11/3/25.
//

import Foundation
@testable import DomainLayer
import Combine
import Alamofire

class MockLoginService {

}

extension MockLoginService: LoginService {
	func logout() throws -> AnyPublisher<DataResponse<EmptyEntity, NetworkErrorResponse>, Never> {
		let emptyEntity = EmptyEntity()
		let response = DataResponse<EmptyEntity, NetworkErrorResponse>(request: nil,
																	   response: nil,
																	   data: nil,
																	   metrics: nil,
																	   serializationDuration: 0,
																	   result: .success(emptyEntity))
		return Just(response).eraseToAnyPublisher()
	}
	
	func login(username: String, password: String) throws -> AnyPublisher<DataResponse<NetworkTokenResponse, NetworkErrorResponse>, Never> {
		let tokenResponse = NetworkTokenResponse(token: "token", refreshToken: "refreshToken")
		let response = DataResponse<NetworkTokenResponse, NetworkErrorResponse>(request: nil,
																				response: nil,
																				data: nil,
																				metrics: nil,
																				serializationDuration: 0,
																				result: .success(tokenResponse))
		return Just(response).eraseToAnyPublisher()
	}
}
