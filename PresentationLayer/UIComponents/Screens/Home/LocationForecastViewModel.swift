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

	override func viewAppeared() {
		let itemId: ParameterValue = isLocationSaved() ? .savedLocation : .unsavedLocation
		WXMAnalytics.shared.trackScreen(.locationQualityInfo, parameters: [.itemId: itemId])
	}

	override func handleTopButtonTap() {
		defer {
			updateTopButton()
		}

		guard isLocationSaved() else {
			let isLoggedIn: Bool = MainScreenViewModel.shared.isUserLoggedIn
			let state: ParameterValue = isLoggedIn ? .authenticated : .unauthenticated
			WXMAnalytics.shared.trackEvent(.userAction, parameters: [.actionName: .savedALocation,
																	 .state: state])
			saveLocation()

			return
		}

		useCase.removeLocation(location)
	}

	override func signupButtonTapped() {
		Router.shared.navigateTo(.register(ViewModelsFactory.getRegisterViewModel()))
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

	func saveLocation() {
		let savedLocationsCount = useCase.getSavedLocations().count
		let maxSaved = useCase.maxSavedLocations

		guard savedLocationsCount < maxSaved else {
			showMaxSavedAlert()
			return
		}

		useCase.saveLocation(location)
	}

	func showMaxSavedAlert() {
		guard !MainScreenViewModel.shared.isUserLoggedIn else {
			Toast.shared.show(text: LocalizableString.Home.saveMoreLocationsMaxMessage.localized.attributedMarkdown ?? "", type: .info)
			return
		}

		let conf = WXMAlertConfiguration(title: LocalizableString.Home.saveMoreLocationsAlertTitle.localized,
										 text: LocalizableString.Home.saveMoreLocationAlertMessage.localized.attributedMarkdown ?? "",
										 primaryButtons: [.init(title: LocalizableString.login.localized,
																action: { Router.shared.navigateTo(.signIn(ViewModelsFactory.getSignInViewModel())) })])
		alertConfiguration = conf
		showLoginAlert = true
	}
}
