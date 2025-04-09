//
//  MockHistoryUseCase.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 2/4/25.
//

import DomainLayer
import Alamofire
import Combine

struct MockHistoryUseCase: HistoryUseCaseApi {
	func getWeatherHourlyHistory(deviceId: String, date: Date, force: Bool) throws -> AnyPublisher<DataResponse<[NetworkDeviceHistoryResponse], NetworkErrorResponse>, Never> {
		let history = NetworkDeviceHistoryResponse(tz: "",
												   date: Date().toTimestamp(),
												   hourly: [CurrentWeather()],
												   daily: nil)
		let response = DataResponse<[NetworkDeviceHistoryResponse], NetworkErrorResponse>(request: nil,
																						  response: nil,
																						  data: nil,
																						  metrics: nil,
																						  serializationDuration: 0,
																						  result: .success([history]))
		return Just(response).eraseToAnyPublisher()
	}
}
