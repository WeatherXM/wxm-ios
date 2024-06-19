//
//  DeviceDetails+Common.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 13/10/23.
//

import Foundation
import DomainLayer

extension DeviceDetails {

	var displayName: String {
		guard let friendlyName = friendlyName, !friendlyName.isEmpty else {
			return name
		}
		return friendlyName
	}

	/// The icon to show according to profile
	var icon: AssetEnum {
		guard let connectivity = bundle?.connectivity else {
			return .wifi
		}
		return connectivity.icon
	}

}

extension Connectivity {
	var icon: AssetEnum {
		switch self {
			case .wifi:
				return .wifi
			case .helium:
				return .helium
			case .cellular:
				return .signal
		}
	}
}

