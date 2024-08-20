//
//  NetworkDevicesInfoResponse+.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 28/3/23.
//

import Foundation
import DomainLayer

extension BatteryState: CustomStringConvertible {
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
	var isUserStakeholder: Bool {
		guard let userWallet = MainScreenViewModel.shared.userInfo?.wallet?.address else {
			return false
		}

		return rewardSplit?.contains { $0.wallet == userWallet } == true
	}

	var isRewardSplitted: Bool {
		guard let rewardSplit else {
			return false
		}

		return rewardSplit.count > 1
	}
}
