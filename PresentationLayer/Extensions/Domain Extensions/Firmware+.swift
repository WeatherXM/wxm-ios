//
//  Firmware+.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 29/9/23.
//

import Foundation
import DomainLayer

extension DeviceDetails {
	private static let firmwareUpdateInterval: TimeInterval = .hour
	
	func needsUpdate(persistedVersion: FirmwareVersion?) -> Bool {
		guard let version = persistedVersion?.version,
			  let timestamp = persistedVersion?.installDate
		else {
			return checkFirmwareIfNeedsUpdate()
		}

		if version == firmware?.current, Date.now.timeIntervalSince(timestamp) < Self.firmwareUpdateInterval {
			return false
		}

		return checkFirmwareIfNeedsUpdate()
	}

	func checkFirmwareIfNeedsUpdate() -> Bool {
		guard profile == .helium,
			  let current = firmware?.current,
			  let assigned = firmware?.assigned else {
			return false
		}

		return assigned != current
	}

	/// True if the stations current version is different from the assigned
	func needsUpdate(mainVM: MainScreenViewModel, followState: UserDeviceFollowState?) -> Bool {
		guard profile == .helium, followState?.state == .owned else {
			return false
		}
		return needsUpdate(persistedVersion: mainVM.getInstalledFirmwareVersion(for: id ?? ""))
	}

	func alertsCount(mainVM: MainScreenViewModel, followState: UserDeviceFollowState?) -> Int {
		[!isActive, needsUpdate(mainVM: mainVM, followState: followState)].reduce(0) { $0 + ($1 ? 1 : 0) }
	}
}

extension Firmware {
	var versionUpdateString: String? {
		guard let current, let assigned else {
			return nil
		}
		return "\(current) → \(assigned)"
	}
}
