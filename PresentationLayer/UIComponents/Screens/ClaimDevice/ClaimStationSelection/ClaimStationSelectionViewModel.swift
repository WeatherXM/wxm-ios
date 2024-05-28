//
//  ClaimStationSelectionViewModel.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 29/4/24.
//

import Foundation

class ClaimStationSelectionViewModel: ObservableObject {

	func handleTypeTap(_ type: ClaimStationType) {
		switch type {
			case .m5, .d1, .helium:
				let viewModel = ViewModelsFactory.getClaimStationContainerViewModel(type: type)
				Router.shared.navigateTo(.claimStationContainer(viewModel))
			case .pulse:
				break
		}
	}
}

extension ClaimStationSelectionViewModel: HashableViewModel {
	func hash(into hasher: inout Hasher) {
	}
}
