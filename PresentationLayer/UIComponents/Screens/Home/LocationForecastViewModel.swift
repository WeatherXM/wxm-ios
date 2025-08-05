//
//  LocationForecastViewModel.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 5/8/25.
//

import Foundation
import DomainLayer
import CoreLocation
import Toolkit

class LocationForecastViewModel: ForecastDetailsViewModel {
	private let location: CLLocationCoordinate2D
	private let useCase: LocationForecastsUseCaseApi
	override var isTopButtonEnabled: Bool {
		return true
	}

	init(configuration: ForecastDetailsViewModel.Configuration,
		 location: CLLocationCoordinate2D,
		 useCase: LocationForecastsUseCaseApi) {
		self.location = location
		self.useCase = useCase
		super.init(configuration: configuration)

		updateTopButton()
	}

	override func handleTopButtonTap() {
		defer {
			updateTopButton()
		}

		guard isLocationSaved() else {
			useCase.saveLocation(location)

			return
		}

		useCase.removeLocation(location)
	}
}

private extension LocationForecastViewModel {
	func isLocationSaved() -> Bool {
		let savedLocations = useCase.getSavedLocations()
		return savedLocations.contains(where: { $0 ~== location })
	}

	func updateTopButton() {
		let font: FontAwesome = isLocationSaved() ? .FAProSolid : .FAPro
		fontIconState = (FontIcon.star, ColorEnum.warning, font)
	}
}
