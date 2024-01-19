//
//  DeviceDetails+.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 31/7/23.
//

import Foundation
import DomainLayer

struct FirmwareVersion: Codable {
    let installDate: Date
    let version: String
}

extension DeviceDetails: Identifiable { }

extension DeviceDetails {

    var stationLastActiveConf: StationLastActiveView.Configuration {
        StationLastActiveView.Configuration(lastActiveAt: lastActiveAt,
                                            icon: profile?.icon ?? .wifi,
                                            stateColor: activeStateColor(isActive: isActive),
                                            tintColor: activeStateTintColor(isActive: isActive))
    }

    /// Label without occurences of ":"
    var convertedLabel: String? {
        label?.convertedDeviceIdentifier
    }

    /// The icon color for each state
    var isActiveStateColor: ColorEnum {
        activeStateColor(isActive: isActive)
    }

    /// The tint color for for each state
    var isActiveStateTintColor: ColorEnum {
        activeStateTintColor(isActive: isActive)
    }

    /// The url rouble shooting according to profile type
    var troubleShootingUrl: String? {
        guard let profile else {
            return nil
        }

        switch profile {
            case .m5:
                return DisplayedLinks.m5Troubleshooting.linkURL
            case .helium:
                return DisplayedLinks.heliumTroubleshooting.linkURL
        }
    }

	var explorerUrl: String {
		let name = name.replacingOccurrences(of: " ", with: "-")
		return DisplayedLinks.shareDevice.linkURL + name.lowercased()
	}
}

// MARK: - Mock

extension DeviceDetails {
    static var mockDevice: DeviceDetails {
        var device = DeviceDetails.emptyDeviceDetails
        device.name = "Test name"
        device.id = "0"
        device.label = "AE:66:F7:21:1F:21:75:11:EC"
        device.address = "This is an address"
        device.profile = .m5
        device.isActive = false
        device.firmware = Firmware(assigned: "1.0.0", current: "1.0.1")
		device.cellCenter = .init(lat: 0.0, long: 0.0)

        let currentWeather = CurrentWeather.mockInstance
        device.weather = currentWeather

        return device
    }
}
