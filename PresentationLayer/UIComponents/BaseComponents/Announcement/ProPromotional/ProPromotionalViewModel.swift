//
//  ProPromotionalViewModel.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 21/3/25.
//

import Foundation
import Toolkit

@MainActor
class ProPromotionalViewModel: ObservableObject {
	let bulllets: [String] = [LocalizableString.Promotional.forecastAccuracy.localized,
							  LocalizableString.Promotional.hyperlocalWeaterForecasts.localized,
							  LocalizableString.Promotional.historicalData.localized,
							  LocalizableString.Promotional.cellForecast.localized,
							  LocalizableString.Promotional.accessApi.localized,
							  LocalizableString.Promotional.andMore.localized]
	private let linkNavigation: LinkNavigation

	init(linkNavigation: LinkNavigation = LinkNavigationHelper()) {
		self.linkNavigation = linkNavigation
	}

	func handleLearnMoreTapped() {
		LinkNavigationHelper().openUrl(DisplayedLinks.weatherXMPro.linkURL)

		WXMAnalytics.shared.trackEvent(.selectContent, parameters: [.contentType: .learnMore,
																	.itemId: .proPromotion])
	}
}

extension ProPromotionalViewModel: HashableViewModel {
	nonisolated func hash(into hasher: inout Hasher) {
	}
}

