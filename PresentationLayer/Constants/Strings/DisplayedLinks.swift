//
//  DisplayedLinks.swift
//  PresentationLayer
//
//  Created by Danae Kikue Dimou on 2/6/22.
//

import Alamofire
import Foundation
import Toolkit

enum DisplayedLinks {
	case emptyValue
	case termsLink
	case contactLink
	case weatherXMWebsiteLink
	case createWalletsLink
	case arbitrumAddressWebsiteFormat
	case documentationLink
	case feedbackForm
	case appSurveyForm
	case m5Troubleshooting
	case heliumTroubleshooting
	case d1Troubleshooting
	case heliumRegionFrequencies
	case shopLink
	case shareDevice
	case shareCells
	case rewardMechanism
	case polAlgorithm
	case qodAlgorithm
	case troubleshooting
	case cellCapacity
	case claimToken
	case appstore
	case announcements
	case m5Batteries
	case heliumBatteries
	case d1Batteries
	case m5VideoLink
	case d1VideoLink

	var linkURL: String {
		switch self {
			case .emptyValue:
				return ""
			case .termsLink:
				return "https://weatherxm.com/mobile/terms/"
			case .contactLink:
				return "https://weatherxm.com/contact/"
			case .weatherXMWebsiteLink:
				return "https://weatherxm.com/"
			case .createWalletsLink:
				return "https://docs.weatherxm.com/mobile-app/wallet/add-edit-wallet-address#how-to-create-wallet-on-metamask"
			case .arbitrumAddressWebsiteFormat:
				return "https://arbiscan.io/address/%@#tokentxns"
			case .documentationLink:
				return "https://docs.weatherxm.com/"
			case .feedbackForm:
				return "https://docs.google.com/forms/d/e/1FAIpQLSc35pJdxM0tosVh-az0goKEjE1xzBs_OVo5V23coC8z1ayD6g/viewform"
			case .appSurveyForm:
				return "https://docs.google.com/forms/d/e/1FAIpQLSc1T-odUwpXa01nODavwEtLgO00AfPxqfrdhbn_G5Lss0dD2w/viewform?usp=pp_url"
			case .m5Troubleshooting:
				return "https://docs.weatherxm.com/wifi-m5-bundle/m5-troubleshooting"
			case .heliumTroubleshooting:
				return "https://docs.weatherxm.com/helium-bundle/helium-troubleshooting"
			case .d1Troubleshooting:
				return "https://docs.weatherxm.com/wxm-devices/D1-bundle/D1-troubleshooting"
			case .heliumRegionFrequencies:
				return "https://docs.helium.com/iot/lorawan-region-plans"
			case .shopLink:
				return "https://shop.weatherxm.com"
			case .shareDevice:
				return "https://explorer.weatherxm.com/stations/"
			case .shareCells:
				return "https://explorer.weatherxm.com/cells/"
			case .rewardMechanism:
				return "https://docs.weatherxm.com/reward-mechanism"
			case .polAlgorithm:
				return "https://docs.weatherxm.com/project/proof-of-location"
			case .qodAlgorithm:
				return "https://docs.weatherxm.com/project/quality-of-data"
			case .troubleshooting:
				return "https://docs.weatherxm.com/faqs#troubleshooting"
			case .cellCapacity:
				return "https://docs.weatherxm.com/project/cell-capacity"
			case .claimToken:
				return Bundle.main.getConfiguration(for: .claimTokenUrl) ?? ""
			case .appstore:
				return Bundle.main.getConfiguration(for: .appStoreUrl) ?? ""
			case .announcements:
				return "https://announcements.weatherxm.com"
			case .m5Batteries:
				return "https://docs.weatherxm.com/wxm-devices/wifi-m5-bundle/assemble-m5#installing-batteries"
			case .heliumBatteries:
				return "https://docs.weatherxm.com/wxm-devices/helium-bundle/helium-assemble#battery-installation-diagram-external-box"
			case .d1Batteries:
				return "https://docs.weatherxm.com/wxm-devices/D1-bundle/D1-assemble#installing-batteries"
			case .m5VideoLink:
				return "https://www.youtube.com/watch?v=sUJEwuFq1CE"
			case .d1VideoLink:
				return "https://www.youtube.com/watch?v=D3rz1Y01Qhg"
		}
	}
}

extension DisplayedLinks {
	static var networkAddressWebsiteFormat: Self {
		.arbitrumAddressWebsiteFormat
	}
}

enum DisplayLinkParams: String {
	case theme
	case amount
	case wallet
	case network
	case redirectUrl = "redirect_url"
	case claimedAmount = "claimed_amount"
	case embed
}
