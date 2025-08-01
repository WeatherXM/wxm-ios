//
//  ExplorerRepositoryImpl.swift
//  DataLayer
//
//  Created by Lampros Zouloumis on 17/8/22.
//

import struct Alamofire.DataResponse
import Combine
import CoreLocation
@preconcurrency import DomainLayer
import Toolkit

public struct ExplorerRepositoryImpl: ExplorerRepository {
    private let locationManager = WXMLocationManager()

    public init() {}

    public func getUserLocation() async -> Result<CLLocationCoordinate2D, ExplorerLocationError> {
        let res = await locationManager.getUserLocation()

        switch res {
            case .success(let coordinates):
                return .success(coordinates)
            case .failure(let error):
                return .failure(ExplorerLocationError(locationError: error))
        }
    }

	public var locationAuthorization: WXMLocationManager.Status {
		locationManager.status
	}
	
    public func getPublicHexes() throws -> AnyPublisher<DataResponse<[PublicHex], NetworkErrorResponse>, Never> {
		let builder = CellRequestBuilder.getCells
		let urlRequest = try builder.asURLRequest()
		return ApiClient.shared.requestCodable(urlRequest, mockFileName: builder.mockFileName)
    }

    public func getPublicDevicesOfHex(index: String) throws -> AnyPublisher<DataResponse<[PublicDevice], NetworkErrorResponse>, Never> {
		let builder = CellRequestBuilder.getCellsDevices(index: index)
        let urlRequest = try builder.asURLRequest()
		return ApiClient.shared.requestCodable(urlRequest, mockFileName: builder.mockFileName)
    }

    public func getPublicDevice(index: String, deviceId: String) throws -> AnyPublisher<DataResponse<PublicDevice, NetworkErrorResponse>, Never> {
        let urlRequest = try CellRequestBuilder.getCellsDevicesDetails(index: index, deviceId: deviceId).asURLRequest()
        return ApiClient.shared.requestCodable(urlRequest)
    }

	public func getCellForecast(for coordinates: CLLocationCoordinate2D) throws -> AnyPublisher<DataResponse<[NetworkDeviceForecastResponse], NetworkErrorResponse>, Never> {
		let builder = CellRequestBuilder.getCellForecast(lat: coordinates.latitude, lon: coordinates.longitude)
		let urlRequest = try builder.asURLRequest()
		return ApiClient.shared.requestCodable(urlRequest, mockFileName: builder.mockFileName)
	}
}
