//
//  HomeViewModel.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 1/8/25.
//

import Foundation
import DomainLayer
import Toolkit

@MainActor
class HomeViewModel: ObservableObject {
	@Published var currentLocationState: CurrentLocationViewState = .allowLocation

	private let useCase: LocationForecastsUseCaseApi

	init(useCase: LocationForecastsUseCaseApi) {
		self.useCase = useCase

		updateCurrentLocationState()
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
				// navigate to forecast details
				break
			case .empty:
				break
		}
	}

	func refresh(completion: @escaping VoidCallback) {
		updateCurrentLocationState(completion: completion)
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
							  let locationForecast = forecast.homeLocationForecast() else {
							currentLocationState = .empty
							return
						}
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
}
