//
//  ClaimStationSelectionTypes.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 29/4/24.
//

import Foundation

enum ClaimStationType: CaseIterable, CustomStringConvertible {
	case m5
	case d1
	case helium
	case pulse

	var navigationTitle: String {
		switch self {
			case .m5:
				LocalizableString.ClaimDevice.claimM5Title.localized
			case .d1:
				LocalizableString.ClaimDevice.claimD1Title.localized
			case .helium:
				LocalizableString.ClaimDevice.heliumTitle.localized
			case .pulse:
				LocalizableString.ClaimDevice.pulseTitle.localized
		}
	}

	var description: String {
		switch self {
			case .m5:
				LocalizableString.ClaimDevice.m5Title.localized
			case .d1:
				LocalizableString.ClaimDevice.d1Title.localized
			case .helium:
				LocalizableString.ClaimDevice.heliumTitle.localized
			case .pulse:
				LocalizableString.ClaimDevice.pulseTitle.localized
		}
	}

	var image: AssetEnum {
		switch self {
			case .m5:
				AssetEnum.imageM5
			case .d1:
				AssetEnum.imageD1
			case .helium:
				AssetEnum.imageHelium
			case .pulse:
				AssetEnum.imagePulse
		}
	}
}
