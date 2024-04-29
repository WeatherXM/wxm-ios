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
			case .m5:
				Router.shared.navigateTo(.claimDevice(false))
			case .d1:
				break
			case .helium:
				Router.shared.navigateTo(.claimDevice(true))
			case .pulse:
				break
		}
	}
}

extension ClaimStationSelectionViewModel: HashableViewModel {
	func hash(into hasher: inout Hasher) {
	}
}
