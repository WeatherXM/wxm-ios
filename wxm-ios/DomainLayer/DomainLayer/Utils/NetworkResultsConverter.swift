//
//  NetworkResultsConverter.swift
//  DomainLayer
//
//  Created by Pantelis Giazitsis on 2/8/23.
//

import Foundation
import Alamofire
import Combine

extension Result where Success == [NetworkDevicesResponse], Failure == NetworkErrorResponse {
    var convertedToDeviceDetails: Result<[DeviceDetails], NetworkErrorResponse> {
        switch self {
            case .success(let devices):
                return .success(devices.map { $0.toDeviceDetails })
            case .failure(let error):
                return .failure(error)
        }
    }
}

extension Result where Success == NetworkDevicesResponse, Failure == NetworkErrorResponse {
    var convertedToDeviceDetails: Result<DeviceDetails, NetworkErrorResponse> {
        switch self {
            case .success(let device):
                return .success(device.toDeviceDetails)
            case .failure(let error):
                return .failure(error)
        }
    }
}

extension AnyPublisher<DataResponse<[NetworkDevicesResponse], NetworkErrorResponse>, Never> {
    var convertedToDeviceDetailsResultPublisher: AnyPublisher<Result<[DeviceDetails], NetworkErrorResponse>, Never> {
        flatMap { response in
            return Just(response.result.convertedToDeviceDetails)
        }
        .eraseToAnyPublisher()
    }
}

extension AnyPublisher<DataResponse<NetworkDevicesResponse, NetworkErrorResponse>, Never> {
    var convertedToDeviceDetailsResultPublisher: AnyPublisher<Result<DeviceDetails, NetworkErrorResponse>, Never> {
        flatMap { response in
            return Just(response.result.convertedToDeviceDetails)
        }
        .eraseToAnyPublisher()
    }
}
