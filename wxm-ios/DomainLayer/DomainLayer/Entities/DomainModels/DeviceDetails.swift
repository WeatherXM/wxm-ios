//
//  DeviceDetails.swift
//  DomainLayer
//
//  Created by Pantelis Giazitsis on 31/7/23.
//

import Foundation

public struct DeviceDetails {
    public var id: String?
    public var name: String
    public var friendlyName: String?
    public var label: String?
    public var address: String?
	public var location: LocationCoordinates?
	public var batteryState: BatteryState?
    public var cellIndex: String?
    public var cellCenter: LocationCoordinates?
	public var cellPolygon: [LocationCoordinates]?
    public var isActive: Bool
    public var weather: CurrentWeather?
	public var timezone: String?
    public var lastActiveAt: String?
    public var claimedAt: String?
    public var profile: Profile?
    public var rewards: Rewards?
    public var firmware: Firmware?
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
              profile: nil,
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
                      profile: profile,
                      rewards: rewards,
                      firmware: attributes.firmware)
    }
}


extension PublicDevice {
    public var toDeviceDetails:  DeviceDetails {
        DeviceDetails(id: id,
                      name: name,
                      friendlyName: nil,
                      label: nil,
                      address: nil,
                      cellIndex: cellIndex,
                      cellCenter: nil,
                      isActive: isActive ?? false,
                      weather: currentWeather,
					  timezone: timezone,
                      lastActiveAt: lastWeatherStationActivity,
                      profile: profile,
                      rewards: nil,
                      firmware: nil)
    }
}
