//
//  RewardAnnotationsViewModel.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 28/2/24.
//

import Foundation
import Combine
import DomainLayer
import SwiftUI
import Toolkit

class RewardAnnotationsViewModel: ObservableObject {
	let device: DeviceDetails
	let annotations: [RewardAnnotation]
	let followState: UserDeviceFollowState?
	let refDate: Date

	init(device: DeviceDetails, annotations: [RewardAnnotation], followState: UserDeviceFollowState?, refDate: Date) {
		self.device = device
		self.annotations = annotations.sorted { ($0.severity ?? .info) < ($1.severity ?? .info) }
		self.followState = followState
		self.refDate = refDate
	}

	func annotationActionButtonTile(for annotation: RewardAnnotation?) -> String? {
		guard let group = annotation?.group else {
			return nil
		}

		let isOwned = followState?.relation == .owned
		switch group {
			case .noWallet:
				if MainScreenViewModel.shared.isWalletMissing, isOwned {
					return LocalizableString.RewardDetails.noWalletProblemButtonTitle.localized
				} else if annotation?.docUrl != nil {
					return LocalizableString.RewardDetails.readMore.localized
				}
				return nil
			case .locationNotVerified:
				if isOwned {
					return LocalizableString.RewardDetails.editLocation.localized
				} else if annotation?.docUrl != nil {
					return LocalizableString.RewardDetails.readMore.localized
				}
				return nil
			default:
				if annotation?.docUrl != nil {
					return LocalizableString.RewardDetails.readMore.localized
				}
				return nil
		}
	}

	func handleButtonTap(for error: RewardAnnotation) {
		Logger.shared.trackEvent(.userAction, parameters: [.actionName: .rewardDetailsError,
														   .itemId: .custom(error.group?.rawValue ?? "")])
		handleRewardAnnotation(annotation: error)
	}

	func handleRewardAnnotation(annotation: RewardAnnotation) {
		guard let group = annotation.group else {
			return
		}

		let isOwned = followState?.relation == .owned

		switch group {
			case .noWallet:
				if MainScreenViewModel.shared.isWalletMissing, isOwned {
					Router.shared.navigateTo(.wallet(ViewModelsFactory.getMyWalletViewModel()))
				} else if let docUrl = annotation.docUrl,
				   let url = URL(string: docUrl) {
					UIApplication.shared.open(url)
				}
			case .locationNotVerified:
				if isOwned {
					let viewModel = ViewModelsFactory.getSelectLocationViewModel(device: device,
																				 followState: followState,
																				 delegate: nil)
					Router.shared.navigateTo(.selectStationLocation(viewModel))
				} else if let docUrl = annotation.docUrl,
						  let url = URL(string: docUrl) {
					 UIApplication.shared.open(url)
				 }
			default:
				if let docUrl = annotation.docUrl,
				   let url = URL(string: docUrl) {
					UIApplication.shared.open(url)
				}
		}
	}
}

extension RewardAnnotationsViewModel: HashableViewModel {
	func hash(into hasher: inout Hasher) {
		hasher.combine("\(device.id)-\(refDate.timeIntervalSince1970)")
	}
}
