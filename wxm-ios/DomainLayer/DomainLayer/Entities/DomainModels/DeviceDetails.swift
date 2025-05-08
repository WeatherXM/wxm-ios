//
//  DeviceDetails.swift
//  DomainLayer
//
//  Created by Pantelis Giazitsis on 31/7/23.
//

import Foundation

public struct DeviceDetails: Sendable {
    public var id: String?
    public var name: String
    public var friendlyName: String?
    public var label: String?
    public var address: String?
	public var location: LocationCoordinates?
	public var batteryState: BatteryState?
    public var cellIndex: String?
	public var cellAvgDataQuality: Int?
    public var cellCenter: LocationCoordinates?
	public var cellPolygon: [LocationCoordinates]?
    public var isActive: Bool
    public var weather: CurrentWeather?
	public var timezone: String?
    public var lastActiveAt: String?
    public var claimedAt: String?
    public var rewards: Rewards?
    public var firmware: Firmware?
	public var bundle: StationBundle?
	public var qod: Int?
	public var pol: PolStatus?
	public var latestQodTs: Date?

	public init(id: String? = nil,
				name: String,
				friendlyName: String? = nil,
				label: String? = nil,
				address: String? = nil,
				location: LocationCoordinates? = nil,
				batteryState: BatteryState? = nil,
				cellIndex: String? = nil,
				cellAvgDataQuality: Int? = nil,
				cellCenter: LocationCoordinates? = nil,
				cellPolygon: [LocationCoordinates]? = nil,
				isActive: Bool,
				weather: CurrentWeather? = nil,
				timezone: String? = nil,
				lastActiveAt: String? = nil,
				claimedAt: String? = nil,
				rewards: Rewards? = nil,
				firmware: Firmware? = nil,
				bundle: StationBundle? = nil,
				qod: Int? = nil,
				pol: PolStatus? = nil,
				latestQodTs: Date? = nil) {
		self.id = id
		self.name = name
		self.friendlyName = friendlyName
		self.label = label
		self.address = address
		self.location = location
		self.batteryState = batteryState
		self.cellAvgDataQuality = cellAvgDataQuality
		self.cellIndex = cellIndex
		self.cellCenter = cellCenter
		self.cellPolygon = cellPolygon
		self.isActive = isActive
		self.weather = weather
		self.timezone = timezone
		self.lastActiveAt = lastActiveAt
		self.claimedAt = claimedAt
		self.rewards = rewards
		self.firmware = firmware
		self.bundle = bundle
		self.qod = qod
		self.pol = pol
		self.latestQodTs = latestQodTs
	}
}

public extension DeviceDetails {
    static var emptyDeviceDetails: DeviceDetails {
        .init(id: nil,
              name: "",
              friendlyName: nil,
              label: nil,
              cellIndex: nil,
              isActive: false,
              weather: nil,
			  timezone: nil,
              lastActiveAt: nil,
              rewards: nil,
              firmware: nil)
    }
}

extension NetworkDevicesResponse {
    public var toDeviceDetails: DeviceDetails {
        DeviceDetails(id: id,
                      name: name,
                      friendlyName: attributes.friendlyName,
                      label: label,
                      address: address,
					  location: location,
					  batteryState: batteryState,
                      cellIndex: attributes.hex7?.index,
                      cellCenter: attributes.hex7?.center,
					  cellPolygon: attributes.hex7?.polygon,
                      isActive: attributes.isActive,
                      weather: currentWeather,
					  timezone: timezone,
                      lastActiveAt: attributes.lastActiveAt,
                      claimedAt: attributes.claimedAt,
                      rewards: rewards,
                      firmware: attributes.firmware,
					  bundle: bundle,
					  qod: metrics?.qodScore,
					  pol: metrics?.polReason,
					  latestQodTs: metrics?.ts)
    }
}

extension PublicDevice {
    public var toDeviceDetails: DeviceDetails {
        DeviceDetails(id: id,
                      name: name,
                      friendlyName: nil,
                      label: nil,
                      address: address,
                      cellIndex: cellIndex,
					  cellAvgDataQuality: cellAvgDataQuality,
                      cellCenter: cellCenter,
                      isActive: isActive ?? false,
                      weather: currentWeather,
					  timezone: timezone,
                      lastActiveAt: lastWeatherStationActivity,
                      rewards: nil,
                      firmware: nil,
					  bundle: bundle,
					  qod: metrics?.qodScore,
					  pol: metrics?.polReason,
					  latestQodTs: metrics?.ts)
    }
}
