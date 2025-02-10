//
//  WXMLocationManager.swift
//  Toolkit
//
//  Created by Pantelis Giazitsis on 23/5/23.
//

import Foundation
import CoreLocation
import Combine

extension WXMLocationManager {
	public protocol LocationManagerProtocol {
		var status: Status { get }
		func requestAuthorization() async -> Status
		func getUserLocation() async -> Result<CLLocationCoordinate2D, LocationError>
	}
}

public class WXMLocationManager: NSObject, WXMLocationManager.LocationManagerProtocol {
    private let manager: CLLocationManager
    private var statusSubject: PassthroughSubject<Status, Never>?
    private var userLocationSubject: PassthroughSubject<CLLocationCoordinate2D, LocationError>?
    private var cancellableSet: Set<AnyCancellable> = []

    public override init() {
        self.manager = CLLocationManager()
        super.init()

        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
    }

	public var status: Status {
		manager.authorizationStatus.toStatus
	}
	
    public func requestAuthorization() async -> Status {
        let currentStatus = manager.authorizationStatus.toStatus
        guard currentStatus == .notDetermined else {
            return currentStatus
        }

        statusSubject = .init()
        manager.requestWhenInUseAuthorization()

        return await withCheckedContinuation { continuation in
            statusSubject?.sink { status in
				continuation.resume(returning: status)
            }.store(in: &cancellableSet)
        }
    }

    public func getUserLocation() async -> Result<CLLocationCoordinate2D, LocationError> {
        let status = await requestAuthorization()
        guard status == .authorized else {
            return .failure(.notAuthorized)
        }

        userLocationSubject = PassthroughSubject()
        manager.startUpdatingLocation()

        return await withCheckedContinuation { continuation in
            userLocationSubject?.sink { completion in
                switch completion {
                    case .finished:
                        break
                    case .failure(let locationError):
                        continuation.resume(returning: .failure(locationError))
                }
            } receiveValue: { coordinates in
                continuation.resume(returning: .success(coordinates))
            }.store(in: &cancellableSet)
        }
    }
}

extension WXMLocationManager: CLLocationManagerDelegate {

    public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        statusSubject?.send(manager.authorizationStatus.toStatus)
        statusSubject?.send(completion: .finished)
    }

    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let loc = locations.last else {
            userLocationSubject?.send(completion: .failure(.locationNotFound))
            return
        }

        manager.stopUpdatingLocation()
        userLocationSubject?.send(loc.coordinate)
        userLocationSubject?.send(completion: .finished)
    }
}

extension WXMLocationManager {
	public enum Status: Sendable {
        case authorized
        case denied
        case notDetermined
        case unknown

        init(from authorizationStatus: CLAuthorizationStatus) {
            switch authorizationStatus {
                case .notDetermined:
                    self = .notDetermined
                case .restricted, .denied:
                    self = .denied
                case .authorizedAlways, .authorizedWhenInUse:
                    self = .authorized
                @unknown default:
                    self = .unknown
            }
        }
    }

    public enum LocationError: Error {
        case notAuthorized
        case locationNotFound
    }
}

private extension CLAuthorizationStatus {
    var toStatus: WXMLocationManager.Status {
        switch self {
            case .notDetermined:
                return .notDetermined
            case .restricted, .denied:
                return .denied
            case .authorizedAlways, .authorizedWhenInUse:
                return .authorized
            @unknown default:
                return .unknown
        }
    }
}
