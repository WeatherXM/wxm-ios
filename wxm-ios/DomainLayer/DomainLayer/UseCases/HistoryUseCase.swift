//
//  HistoryUseCase.swift
//  DomainLayer
//
//  Created by Lampros Zouloumis on 25/8/22.
//

import DGCharts
import Combine
import Alamofire
import class UIKit.UIImage
import Toolkit

public final class HistoryUseCase: HistoryUseCaseApi {
	nonisolated(unsafe) private let meRepository: MeRepository

    public init(meRepository: MeRepository) {
        self.meRepository = meRepository
    }

    public func getWeatherHourlyHistory(deviceId: String,
										date: Date,
										force: Bool = false) throws -> AnyPublisher<DataResponse<[NetworkDeviceHistoryResponse], NetworkErrorResponse>, Never> {
        try meRepository.getUserDeviceHourlyHistoryById(deviceId: deviceId, date: date, force: force)
    }
}
