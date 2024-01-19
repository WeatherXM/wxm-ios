//
//  ExplorerRepository.swift
//  DomainLayer
//
//  Created by Lampros Zouloumis on 17/8/22.
//

import struct Alamofire.DataResponse
import Combine
import CoreLocation
import Foundation
import Toolkit

public protocol ExplorerRepository {
	var locationAuthorization: WXMLocationManager.Status { get }
    func getUserLocation() async -> Result<CLLocationCoordinate2D, ExplorerLocationError>
    func getPublicHexes() throws -> AnyPublisher<DataResponse<[PublicHex], NetworkErrorResponse>, Never>
    func getPublicDevicesOfHex(index: String) throws -> AnyPublisher<DataResponse<[PublicDevice], NetworkErrorResponse>, Never>
    func getPublicDevice(index: String, deviceId: String) throws -> AnyPublisher<DataResponse<PublicDevice, NetworkErrorResponse>, Never>
}

public enum ExplorerLocationError: Error {
    case locationNotFound
    case permissionDenied

    public init(locationError: WXMLocationManager.LocationError) {
        switch locationError {
            case .notAuthorized:
                self = .permissionDenied
            case .locationNotFound:
                self = .locationNotFound
        }
    }
}
