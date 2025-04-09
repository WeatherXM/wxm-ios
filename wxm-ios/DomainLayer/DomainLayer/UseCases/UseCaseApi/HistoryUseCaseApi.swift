//
//  HistoryUseCaseApi.swift
//  DomainLayer
//
//  Created by Pantelis Giazitsis on 1/4/25.
//

import Combine
import Alamofire
import Foundation

public protocol HistoryUseCaseApi: Sendable {
	func getWeatherHourlyHistory(deviceId: String, date: Date, force: Bool) throws -> AnyPublisher<DataResponse<[NetworkDeviceHistoryResponse], NetworkErrorResponse>, Never>
}
