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

	private let useCase: SettingsUseCaseApi

	init(useCase: SettingsUseCaseApi) {
        self.useCase = useCase
    }

    func denyButtonTapped() {
        useCase.optInOutAnalytics(false)
    }

    func soundsGoodButtonTapped() {
        useCase.optInOutAnalytics(true)
    }
}
