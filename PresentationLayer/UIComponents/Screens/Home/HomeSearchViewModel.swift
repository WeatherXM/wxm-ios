//
//  HomeSearchViewModel.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 4/8/25.
//

import Foundation
import DomainLayer
import CoreLocation

class HomeSearchViewModel: ExplorerSearchViewModel {

	override var resultsTitle: String? {
		LocalizableString.Home.locations.localized
	}

	override var searhExclude: SearchExclude? {
		.stations
	}

	override init(useCase: (any NetworkUseCaseApi)? = nil) {
		super.init(useCase: useCase)
		isShowingRecent = false
	}

	override func handleTapOnResult(_ result: SearchView.Row) {
		guard let lat = result.networkModel?.lat, let lon = result.networkModel?.lon else {
			return
		}

		isSearchActive = false
		delegate?.rowTapped(coordinates: CLLocationCoordinate2D(latitude: lat, longitude: lon),
							deviceId: nil,
							cellIndex: nil)

		searchTerm.removeAll()
	}

	override func updateUIState() {
		guard searchTerm.count >= searchTermLimit else {
			if searchTerm.isEmpty {
				updateSearchResults(response: nil)
			}
			return
		}
	}
}
