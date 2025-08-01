//
//  HomeViewModel.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 1/8/25.
//

import Foundation
import DomainLayer

class HomeViewModel: ObservableObject {
	private let useCase: LocationForecastsUseCaseApi

	init(useCase: LocationForecastsUseCaseApi) {
		self.useCase = useCase
	}
}
