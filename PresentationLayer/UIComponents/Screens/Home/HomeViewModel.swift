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
	@Published var savedLocationsState: SavedLocationsViewState = .empty
	@Published var isLoading: Bool = false
	@Published var isFailed = false
	private(set) var failObj: FailSuccessStateObject?

	let stationChipsViewModel: StationRewardsChipViewModel = ViewModelsFactory.getStationRewardsChipViewModel()
	let searchViewModel: HomeSearchViewModel = ViewModelsFactory.getHomeSearchViewModel()
	private let useCase: LocationForecastsUseCaseApi

	init(useCase: LocationForecastsUseCaseApi) {
		self.useCase = useCase

		refresh(completion: nil)
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
							refresh(completion: nil)
						}
					case .unknown:
						break
				}
			case .forecast(let locationForecast):
				handleTapOn(locationForecast: locationForecast, title: LocalizableString.Home.currentLocation.localized)
			case .empty:
				break
		}
	}

	func refresh(completion: VoidCallback?) {
		isLoading = (completion == nil)

		Task { @MainActor in
			do {
				let forecasts = try await fetchForecasts()
				self.savedLocationsState = forecasts.isEmpty ? .empty : .forecasts(forecasts)
				self.currentLocationState = try await getCurrentLocationState()
			} catch let error as NetworkErrorResponse {
				let info = error.uiInfo
				let title = info.title
				let description = info.description
				let obj = info.defaultFailObject(type: .home) {  [weak self] in
					self?.isFailed = false
					self?.failObj = nil
					self?.refresh(completion: nil)
				}

				self.failObj = obj
				self.isFailed = true

			} catch {
				print(error)
			}

			self.isLoading = false
			completion?()
		}
	}

	func handleSearchBarTap() {
		searchViewModel.isSearchActive = true
	}

	func handleTapOn(locationForecast: LocationForecast, title: String? = nil) {
		guard let currentForecast = locationForecast.forecasts, let location = locationForecast.location else {
			return
		}
		navigateToForecast(currentForecast, title: title, location: location)
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
	func getCurrentLocationState() async throws -> CurrentLocationViewState {
		guard useCase.locationAuthorization == .authorized else {
			return .allowLocation
		}

		let userLocation = try await useCase.getUserLocation().get()
		let result = try await useCase.getForecast(for: userLocation).toAsync().result
		switch result {
			case .success(let forecasts):
				guard let forecast = forecasts.first,
					  var locationForecast = forecast.homeLocationForecast() else {
					return .empty
				}
				locationForecast.location = userLocation
				locationForecast.forecasts = forecasts
				return .forecast(locationForecast)
			case .failure(let error):
				throw error
		}
	}

	func fetchForecasts() async throws -> [LocationForecast] {
		let savedLocations = useCase.getSavedLocations()
		return try await withThrowingTaskGroup(of: LocationForecast.self, returning: [LocationForecast].self) { group in
			for location in savedLocations {
				group.addTask { [weak self] in
					guard let self else {
						fatalError("Self is nil")
					}

					let res = try await self.useCase.getForecast(for: location).toAsync().result
					switch res {
						case .success(let forecasts):
							guard var locationForecast = forecasts.first?.homeLocationForecast() else {
								throw NSError(domain: "", code: 0, userInfo: nil)
							}

							locationForecast.forecasts = forecasts
							locationForecast.location = location

							return locationForecast
						case .failure(let error):
							throw error

					}
				}
			}

			var locationForecasts: [LocationForecast] = []
			while let locationForecast = try await group.next() {
				locationForecasts.append(locationForecast)
			}

			return locationForecasts
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
