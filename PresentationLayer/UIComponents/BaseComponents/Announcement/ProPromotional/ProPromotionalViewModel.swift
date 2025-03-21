//
//  ProPromotionalViewModel.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 21/3/25.
//

import Foundation

@MainActor
class ProPromotionalViewModel: ObservableObject {
	let bulllets: [String] = [LocalizableString.Promotional.forecastAccuracy.localized,
							  LocalizableString.Promotional.hyperlocalWeaterForecasts.localized,
							  LocalizableString.Promotional.historicalData.localized,
							  LocalizableString.Promotional.cellForecast.localized,
							  LocalizableString.Promotional.accessApi.localized,
							  LocalizableString.Promotional.andMore.localized]

	func handleLearnMoreTapped() {
		
	}
}

extension ProPromotionalViewModel: HashableViewModel {
	nonisolated func hash(into hasher: inout Hasher) {
	}
}

