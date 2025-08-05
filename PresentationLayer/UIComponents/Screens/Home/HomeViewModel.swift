//
//  HomeViewModel.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 1/8/25.
//

import Foundation
import DomainLayer
import Toolkit
import CoreLocation

@MainActor
class HomeViewModel: ObservableObject {
	@Published var currentLocationState: CurrentLocationViewState = .empty

	let stationChipsViewModel: StationRewardsChipViewModel = ViewModelsFactory.getStationRewardsChipViewModel()
	let searchViewModel: HomeSearchViewModel = ViewModelsFactory.getHomeSearchViewModel()
	private let useCase: LocationForecastsUseCaseApi
	private var currentForecast: [NetworkDeviceForecastResponse]?

	init(useCase: LocationForecastsUseCaseApi) {
		self.useCase = useCase

		updateCurrentLocationState()
		searchViewModel.delegate = self
	}

	func handleCurrentLocationTap() {
		switch currentLocationState {
			case .allowLocation:
				let status = useCase.locationAuthorization
				switch status {
					case .authorized:
						break
					case .denied:
						// Move to settings
						let title = LocalizableString.ClaimDevice.confirmLocationNoAccessToServicesTitle.localized
						let message = LocalizableString.ClaimDevice.confirmLocationNoAccessToServicesText.localized
						let alertObj = AlertHelper.AlertObject.getNavigateToSettingsAlert(title: title,
																						  message: message)
						AlertHelper().showAlert(alertObj)

					case .notDetermined:
						Task { @MainActor in
							let _ = await useCase.getUserLocation()
							updateCurrentLocationState()
						}
					case .unknown:
						break
				}
			case .forecast(let locationForecast):
				guard let currentForecast, let location = locationForecast.location else {
					return
				}
				navigateToForecast(currentForecast, title: LocalizableString.Home.currentLocation.localized, location: location)
			case .empty:
				break
		}
	}

	func refresh(completion: @escaping VoidCallback) {
		updateCurrentLocationState(completion: completion)
	}

	func handleSearchBarTap() {
		searchViewModel.isSearchActive = true
	}
}

extension HomeViewModel: ExplorerSearchViewModelDelegate {
	func rowTapped(coordinates: CLLocationCoordinate2D, deviceId: String?, cellIndex: String?) {

	}
	
	func searchWillBecomeActive(_ active: Bool) {

	}
	
	func networkStatisticsTapped() {
	}
}

private extension HomeViewModel {
	func updateCurrentLocationState(completion: VoidCallback? = nil) {
		guard useCase.locationAuthorization == .authorized else {
			currentLocationState = .allowLocation
			completion?()
			return
		}

		Task { @MainActor in
			defer {
				completion?()
			}
			
			do {
				let userLocation = try await useCase.getUserLocation().get()
				let result = try await useCase.getForecast(for: userLocation).toAsync().result
				switch result {
					case .success(let forecasts):
						guard let forecast = forecasts.first,
							  var locationForecast = forecast.homeLocationForecast() else {
							currentLocationState = .empty
							return
						}
						locationForecast.location = userLocation
						currentForecast = forecasts
						currentLocationState = .forecast(locationForecast)
					case .failure(let error):
						let uiInfo = error.uiInfo
						Toast.shared.show(text: uiInfo.description?.attributedMarkdown ?? "")
						currentLocationState = .empty
				}

			} catch {
				print(error)
			}
		}
	}

	func navigateToForecast(_ forecasts: [NetworkDeviceForecastResponse], title: String?, location: CLLocationCoordinate2D) {
		guard let timezone = forecasts.first?.tz.toTimezone else {
			return
		}

		let selectedHour = Date().getHour(with: timezone)
		let conf = ForecastDetailsViewModel.Configuration(forecasts: forecasts,
														  selectedforecastIndex: 0,
														  selectedHour: selectedHour,
														  navigationTitle: title ?? forecasts.first?.address ?? "",
														  navigationSubtitle: title == nil ? nil : forecasts.first?.address)

		let viewModel = ViewModelsFactory.getLocationForecastDetailsViewModel(configuration: conf, location: location)
		Router.shared.navigateTo(.forecastDetails(viewModel))
	}
}
