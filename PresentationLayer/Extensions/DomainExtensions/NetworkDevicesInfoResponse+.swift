//
//  NetworkDevicesInfoResponse+.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 28/3/23.
//

import Foundation
import DomainLayer

extension BatteryState: @retroactive CustomStringConvertible {
    public var description: String {
        switch self {
            case .low:
                return LocalizableString.low.localized
            case .ok:
                return LocalizableString.good.localized
        }
    }
}

extension NetworkDevicesInfoResponse {
	var isRewardSplitted: Bool {
		guard let rewardSplit else {
			return false
		}

		return rewardSplit.count > 1
	}

	func isUserStakeholder(followState: UserDeviceFollowState?) -> Bool {
		rewardSplit.isUserStakeholder(followState: followState)
	}
}
