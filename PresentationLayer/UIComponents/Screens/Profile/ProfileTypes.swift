//
//  ProfileTypes.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 29/11/23.
//

import Foundation
import SwiftUI

enum ProfileField: CaseIterable {
	case rewards
	case wallet
	case settings

	var icon: FontIcon {
		switch self {
			case .rewards:
					.coins
			case .wallet:
					.wallet
			case .settings:
					.cog
		}
	}

	var title: String {
		switch self {
			case .rewards:
				return LocalizableString.Profile.allocatedRewards.localized
			case .wallet:
				return LocalizableString.Profile.myWallet.localized
			case .settings:
				return LocalizableString.Profile.prefsSettings.localized
		}
	}
}

enum RewardsIndication {
	case buyStation
	case claimWeb

	var showBorder: Bool {
		switch self {
			case .buyStation:
				true
			case .claimWeb:
				false
		}
	}
}
