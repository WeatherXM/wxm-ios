//
//  ClaimDeviceContainerViewModel.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 29/4/24.
//

import Foundation

class ClaimDeviceContainerViewModel: ObservableObject {
	@Published var selectedIndex: Int = 0
	var steps: [ClaimDeviceStep] = []

	init(type: ClaimStationType) {
		steps = getSteps(for: type)
	}
}

private extension ClaimDeviceContainerViewModel {
	func getSteps(for type: ClaimStationType) -> [ClaimDeviceStep] {
		switch type {
			case .m5:
				getM5Steps()
			case .d1:
				getD1Steps()
			case .helium:
				getHeliumSteps()
			case .pulse:
				getPulseSteps()
		}
	}

	func getM5Steps() -> [ClaimDeviceStep] {
		let beginViewModel = ViewModelsFactory.getClaimStationM5BeginViewModel { [weak self] in
			self?.selectedIndex += 1
		}
		return [.begin(beginViewModel), .serialNumber, .location]
	}

	func getD1Steps() -> [ClaimDeviceStep] {
		let beginViewModel = ViewModelsFactory.getClaimStationBeginViewModel { [weak self] in
			self?.selectedIndex += 1
		}
		return [.begin(beginViewModel), .serialNumber, .location]
	}
	
	func getHeliumSteps() -> [ClaimDeviceStep] {
		[]
	}

	func getPulseSteps() -> [ClaimDeviceStep] {
		[]
	}
}

extension ClaimDeviceContainerViewModel: HashableViewModel {
	func hash(into hasher: inout Hasher) {
	}
}
