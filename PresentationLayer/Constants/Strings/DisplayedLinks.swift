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
	case readMoreAboutWalletsLink
	case arbitrumAddressWebsiteFormat
	case documentationLink
	case m5Troubleshooting
	case heliumTroubleshooting
	case heliumRegionFrequencies
	case shopLink
	case tokenomics
	case shareDevice
	case rewardMechanism
	case polAlgorithm
	case qodAlgorithm
	case troubleshooting
	case cellCapacity
	case claimToken
	case appstore

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
			case .readMoreAboutWalletsLink:
				return "https://docs.weatherxm.com/wallet/add-edit-wallet-address#how-to-create-wallet-on-metamask"
			case .arbitrumAddressWebsiteFormat:
				return "https://sepolia.arbiscan.io/address/%@#tokentxns"
			case .documentationLink:
				return "https://docs.weatherxm.com/"
			case .m5Troubleshooting:
				return "https://docs.weatherxm.com/wifi-m5-bundle/m5-troubleshooting"
			case .heliumTroubleshooting:
				return "https://docs.weatherxm.com/helium-bundle/helium-troubleshooting"
			case .heliumRegionFrequencies:
				return "https://docs.helium.com/iot/lorawan-region-plans"
			case .shopLink:
				return "https://shop.weatherxm.com"
			case .tokenomics:
				return "https://docs.weatherxm.com/tokenomics"
			case .shareDevice:
				return "https://explorer.weatherxm.com/stations/"
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
}
