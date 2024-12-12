//
//  StationTimelineEntry.swift
//  station-widgetExtension
//
//  Created by Pantelis Giazitsis on 5/10/23.
//

import Foundation
import WidgetKit
@preconcurrency import DomainLayer

struct StationTimelineEntry: @unchecked Sendable, TimelineEntry {
	let date: Date
	let displaySize: CGSize
	let timelineCase: TimelineCase

	init(date: Date, displaySize: CGSize, id: String?, devices: [DeviceDetails], followState: UserDeviceFollowState?, errorInfo: NetworkErrorResponse.UIInfo?, isLoggedIn: Bool) {
		self.date = date
		self.displaySize = displaySize

		// Check if is logged in
		if !isLoggedIn {
			timelineCase = .loggedOut
			return
		}

		// Check if there is error
		if let errorInfo {
			timelineCase = .error(info: errorInfo)
			return
		}

		// Check if is empty
		if devices.isEmpty {
			timelineCase = .empty
			return
		}

		if let device = devices.first(where: { $0.id == id }) {
			timelineCase = .station(device: device, followState: followState)
			return
		}

		timelineCase = .selectStation
	}
}

extension StationTimelineEntry {
	enum TimelineCase {
		case station(device: DeviceDetails, followState: UserDeviceFollowState?)
		case loggedOut
		case empty
		case error(info: NetworkErrorResponse.UIInfo)
		case selectStation

		var widgetUrl: URL? {
			let scheme = "\(widgetScheme)://"
			switch self {
				case .station(let device, _):
					let urlString = "\(scheme)\(WidgetUrlType.station)/\(device.id ?? "")"
					return URL(string: urlString)
				case .loggedOut:
					let urlString = "\(scheme)\(WidgetUrlType.loggedOut)"
					return URL(string: urlString)
				case .empty:
					let urlString = "\(scheme)\(WidgetUrlType.empty)"
					return URL(string: urlString)
				case .error:
					let urlString = "\(scheme)\(WidgetUrlType.error)"
					return URL(string: urlString)
				case .selectStation:
					let urlString = "\(scheme)\(WidgetUrlType.selectStation)"
					return URL(string: urlString)
			}
		}
	}
}

extension StationTimelineEntry {
	var weatherOverViewMode: WeatherOverviewView.Mode {
		let height = displaySize.height
		switch height {
			case 0 ..< 170.0:
				return .medium
			default:
				return .large
		}
	}
}
