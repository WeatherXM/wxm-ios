//
//  ExplorerUseCase.swift
//  DomainLayer
//
//  Created by Lampros Zouloumis on 17/8/22.
//

import Combine
import CoreLocation
import Foundation
import MapboxMaps
import Toolkit

public class ExplorerUseCase {
    private static let DEVICE_COUNT_KEY = "device_count"
	private static let JSON_COUNTRIES_INFO_FILE_KEY = "countries_information"
    private static let fillOpacity = 0.5
    private static let fillColor = StyleColor(red: 51.0, green: 136.0, blue: 255.0, alpha: 1.0)
    private static let fillOutlineColor = StyleColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)

    private let explorerRepository: ExplorerRepository
    private let devicesRepository: DevicesRepository
    private let meRepository: MeRepository
	private let deviceLocationRepository: DeviceLocationRepository
    private var cancellableSet: Set<AnyCancellable> = []

    public init(explorerRepository: ExplorerRepository, devicesRepository: DevicesRepository, meRepository: MeRepository, deviceLocationRepository: DeviceLocationRepository) {
        self.explorerRepository = explorerRepository
        self.devicesRepository = devicesRepository
        self.meRepository = meRepository
		self.deviceLocationRepository = deviceLocationRepository
    }

    public var userDevicesListChangedPublisher: NotificationCenter.Publisher {
        meRepository.userDevicesChangedNotificationPublisher
    }

	public var userLocationAuthorizationStatus: WXMLocationManager.Status {
		explorerRepository.locationAuthorization
	}

    public func getUserLocation() async -> Result<CLLocationCoordinate2D, ExplorerLocationError> {
        await explorerRepository.getUserLocation()
    }

	public func getSuggestedDeviceLocation() -> CLLocationCoordinate2D? {
		guard let countryInfos = deviceLocationRepository.getCountryInfos() else {
			return nil
		}
		let code = Locale.current.regionCode
		let info = countryInfos.first(where: { $0.code == code } )

		return info?.mapCenter
	}

    public func getPublicHexes(completion: @escaping (Result<ExplorerData, PublicHexError>) -> Void) {
        do {
            try explorerRepository.getPublicHexes().sink(receiveValue: { response in

                guard let hexValues = response.value, response.error == nil else {
                    completion(.failure(PublicHexError.networkRelated(response.error)))
                    return
                }

                var geoJsonSource = GeoJSONSource(id: "heatmap")
                let featuresCollection = hexValues.map { publicHex -> MapboxMaps.Feature in
                    let coordinates = LocationCoordinate2D(latitude: publicHex.center.lat, longitude: publicHex.center.lon)
                    let point = Point(coordinates)
                    let geometry = Geometry.point(point)
                    var feature = Feature(geometry: geometry)
                    var jsonObjectProperty = JSONObject()
                    jsonObjectProperty[ExplorerUseCase.DEVICE_COUNT_KEY] = JSONValue(publicHex.deviceCount ?? 0)
                    feature.properties = jsonObjectProperty
                    return feature
                }
                geoJsonSource.data = .featureCollection(FeatureCollection(features: featuresCollection))

                var totalDevices = 0
                let polygonPoints = hexValues.map { publicHex -> PolygonAnnotation in
                    totalDevices += publicHex.deviceCount ?? 0
                    var ringCords = publicHex.polygon.map { point in
                        LocationCoordinate2D(latitude: point.lat, longitude: point.lon)
                    }
                    /// Added an extra coordinate same as its first to fix the flickering issue while zooming
                    /// https://github.com/mapbox/mapbox-maps-ios/issues/1503#issuecomment-1320348728
                    if let firstPolygonPoint = publicHex.polygon.first {
                        let coordinate = LocationCoordinate2D(latitude: firstPolygonPoint.lat, longitude: firstPolygonPoint.lon)
                        ringCords.append(coordinate)
                    }
                    let ring = Ring(coordinates: ringCords)
                    let polygon = Polygon(outerRing: ring)
                    var polygonAnnotation = PolygonAnnotation(polygon: polygon)
                    polygonAnnotation.fillColor = ExplorerUseCase.fillColor
                    polygonAnnotation.fillOpacity = ExplorerUseCase.fillOpacity
                    polygonAnnotation.fillOutlineColor = ExplorerUseCase.fillOutlineColor
                    polygonAnnotation.userInfo = [publicHex.index: CLLocationCoordinate2D(latitude: publicHex.center.lat, longitude: publicHex.center.lon)]
                    return polygonAnnotation
                }
                let explorerData = ExplorerData(totalDevices: totalDevices, geoJsonSource: geoJsonSource, polygonPoints: polygonPoints)
                completion(.success(explorerData))
            }).store(in: &cancellableSet)

        } catch {
            completion(.failure(PublicHexError.infrastructure))
        }
    }

    public func getPublicDevicesOfHexIndex(hexIndex: String, hexCoordinates: CLLocationCoordinate2D?, completion: @escaping ((Result<[DeviceDetails], PublicHexError>) -> Void)) {
        do {
            try explorerRepository.getPublicDevicesOfHex(index: hexIndex)
                .sink(receiveValue: { [weak self] response in
                    guard let devices = response.value, response.error == nil else {                        
                        completion(.failure(PublicHexError.networkRelated(response.error)))
                        return
                    }

                    Task { [weak self] in
                        let address = await self?.resolveAddressLocation(hexCoordinates) ?? ""
                        var explorerDevices = [DeviceDetails]()
                        await devices.asyncForEach { publicDevice in
                            let state = try? await self?.meRepository.getDeviceFollowState(deviceId: publicDevice.id).get()
                            var device = publicDevice.toDeviceDetails
                            device.address = address
							if let hexCoordinates {
								device.cellCenter = LocationCoordinates(lat: hexCoordinates.latitude, long: hexCoordinates.longitude)
							}
                            explorerDevices.append(device)
                        }
                        explorerDevices = explorerDevices.sorted(by: { dev1, dev2 -> Bool in
                            dev1.isActive == !dev2.isActive
                        }).sorted(by: { dev1, dev2 -> Bool in
                            if dev1.isActive == dev2.isActive {
                                return dev1.name < dev2.name
                            }
                            return true
                        })
                        completion(.success(explorerDevices))

                    }
                }).store(in: &cancellableSet)

        } catch {
            completion(.failure(PublicHexError.infrastructure))
        }
    }

    public func getPublicDevice(hexIndex: String, deviceId: String, completion: @escaping (Result<DeviceDetails, PublicHexError>) -> Void) {
        do {
            try self.explorerRepository.getPublicDevice(index: hexIndex, deviceId: deviceId)
                .sink { devicesResponse in
                    guard let device = devicesResponse.value else {
                        completion(.failure(PublicHexError.networkRelated(devicesResponse.error)))
                        return
                    }
                    completion(.success(device.toDeviceDetails))
                }.store(in: &self.cancellableSet)
        } catch {
            completion(.failure(PublicHexError.infrastructure))
        }
    }

    public func followStation(deviceId: String) async throws ->  Result<EmptyEntity, NetworkErrorResponse> {
        let followStation = try meRepository.followStation(deviceId: deviceId)
        return await withCheckedContinuation { continuation in
            followStation.sink { response in
                continuation.resume(returning: response.result)
            }.store(in: &cancellableSet)
        }
    }

    public func unfollowStation(deviceId: String) async throws ->  Result<EmptyEntity, NetworkErrorResponse> {
        let unfollowStation = try meRepository.unfollowStation(deviceId: deviceId)
        return await withCheckedContinuation { continuation in
            unfollowStation.sink { response in
                continuation.resume(returning: response.result)
            }.store(in: &cancellableSet)
        }
    }

    public func getDeviceFollowState(deviceId: String) async throws -> Result<UserDeviceFollowState?, NetworkErrorResponse> {
        try await meRepository.getDeviceFollowState(deviceId: deviceId)
    }

    private func resolveAddressLocation(_ location: CLLocationCoordinate2D?) async -> String? {
		guard let location else {
			return nil
		}
		
        let geocoder = Geocoder()
        return try? await geocoder.resolveAddressLocation(location)
    }
}
