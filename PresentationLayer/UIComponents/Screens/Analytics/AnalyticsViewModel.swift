//
//  AnalyticsViewModel.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 19/5/23.
//

import Foundation
import DomainLayer
import Toolkit

class AnalyticsViewModel: ObservableObject {

    private let useCase: SettingsUseCase

    init(useCase: SettingsUseCase) {
        self.useCase = useCase
    }

	func viewAppeared() {
		WXMAnalytics.shared.trackScreen(.analytics)
	}

    func denyButtonTapped() {
        useCase.optInOutAnalytics(false)
    }

    func soundsGoodButtonTapped() {
        useCase.optInOutAnalytics(true)
    }
}
