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
		guard let profile else {
			return .wifi
		}
		return profile.icon
	}

}

extension Profile {
	/// The icon to show according to profile
	var icon: AssetEnum {
		switch self {
			case .m5, .d1:
				return .wifi
			case .helium:
				return .helium
		}
	}
}
