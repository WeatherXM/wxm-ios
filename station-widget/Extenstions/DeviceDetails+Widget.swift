//
//  DeviceDetails+Widget.swift
//  station-widgetExtension
//
//  Created by Pantelis Giazitsis on 18/10/23.
//

import DomainLayer

// MARK: - Mock

extension DeviceDetails {
	static var widgetPreviewDevice: DeviceDetails {
		var device = DeviceDetails.emptyDeviceDetails
		device.name = LocalizableString.Widget.previewStationName.localized
		device.id = "0"
		device.label = "AE:66:F7:21:1F:21:75:11:EC"
		device.address = LocalizableString.Widget.previewStationAddress.localized
		device.isActive = true
		device.lastActiveAt = Date.now.toTimestamp()
		device.firmware = Firmware(assigned: "1.0.0", current: "1.0.1")
		device.bundle = .init(name: .m5,
							  title: "M5",
							  connectivity: .wifi,
							  wsModel: "WS1000",
							  gwModel: "WG1000",
							  hwClass: "A")

		let currentWeather = CurrentWeather.mockInstance
		device.weather = currentWeather

		return device
	}
}
