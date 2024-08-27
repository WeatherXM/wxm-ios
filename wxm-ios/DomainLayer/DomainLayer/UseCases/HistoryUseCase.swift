//
//  HistoryUseCase.swift
//  DomainLayer
//
//  Created by Lampros Zouloumis on 25/8/22.
//

import Charts
import Combine
import Alamofire
import class UIKit.UIImage
import Toolkit

public class HistoryUseCase {
    private let meRepository: MeRepository
    private let userDefaultsRepository: UserDefaultsRepository

    public init(meRepository: MeRepository, userDefaultsRepository: UserDefaultsRepository) {
        self.meRepository = meRepository
        self.userDefaultsRepository = userDefaultsRepository
    }

    public func getWeatherHourlyHistory(deviceId: String, 
										date: Date,
										force: Bool = false) throws -> AnyPublisher<DataResponse<[NetworkDeviceHistoryResponse], NetworkErrorResponse>, Never> {
        try meRepository.getUserDeviceHourlyHistoryById(deviceId: deviceId, date: date, force: force)
    }
}
