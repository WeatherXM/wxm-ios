//
//  RewardDetailsViewModel.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 31/10/23.
//

import Foundation
import DomainLayer
import SwiftUI
import Toolkit

class RewardDetailsViewModel: ObservableObject {

	@Published var showInfo: Bool = false
	private(set) var info: BottomSheetInfo?
	@Published var state: ViewState = .loading
	private(set) var failObj: FailSuccessStateObject?


	let useCase: RewardsTimelineUseCase
	var device: DeviceDetails
	let followState: UserDeviceFollowState?
	let date: Date
	var rewardDetailsResponse: NetworkDeviceRewardDetailsResponse?
	var isDeviceOwned: Bool {
		followState?.relation == .owned
	}
	var dateString: String {
		LocalizableString.RewardDetails.earningsFor(rewardDetailsResponse?.timestamp?.getFormattedDate(format: .monthLiteralDayYear, timezone: .UTCTimezone, showTimeZoneIndication: true).capitalizedSentence ?? "").localized
	}
	var dataQualityScoreObject: RewardFieldView.Score? {
		rewardDetailsResponse?.dataQualityScoreObject(followState: followState)
	}
	var locationQualityScoreObject: RewardFieldView.Score? {
		rewardDetailsResponse?.locationQualityScoreObject
	}
	var cellPositionScoreObject: RewardFieldView.Score? {
		rewardDetailsResponse?.cellPositionScoreObject
	}

	init(device: DeviceDetails, followState: UserDeviceFollowState?, date: Date, tokenUseCase: RewardsTimelineUseCase) {
		self.device = device
		self.followState = followState
		self.date = date
		self.useCase = tokenUseCase
		refresh {
			
		}
	}

	func refresh(completion: @escaping VoidCallback) {
		Task { @MainActor [weak self] in
			guard let self else {
				return
			}

			let result = await self.fetchRewardDetails(date: self.date.getFormattedDate(format: .onlyDate, timezone: .UTCTimezone))
			switch result {
				case .success(let response):
					self.rewardDetailsResponse = response
					self.state = .content
					completion()
				case .failure(let error):
					self.state = .fail
					self.failObj = error.uiInfo.defaultFailObject(type: .rewardDetails) {
						self.state = .loading
						self.refresh {}
					}
					completion()
				case nil:
					completion()
			}
		}
	}

	func issuesSubtitle() -> String? {
		guard let warningType = rewardDetailsResponse?.mainAnnotation?.warningType,
			  let count = rewardDetailsResponse?.annotations?.count else {
			return nil
		}

		switch warningType {
			case .error:
				return LocalizableString.StationDetails.stationRewardErrorMessage(count).localized
			case .warning:
				return LocalizableString.StationDetails.stationRewardWarningMessage(count).localized
			case .info:
				return LocalizableString.StationDetails.stationRewardInfoMessage(count).localized
		}
	}

	func issuesButtonTitle() -> String? {
		guard let summary = rewardDetailsResponse?.annotations,
			  summary.count > 1 else {
			return annotationActionButtonTile(for: rewardDetailsResponse?.mainAnnotation)
		}

		return LocalizableString.RewardDetails.viewAllIssues.localized
	}

	func baseRewardSubtitle() -> String? {
		guard let actualReward = rewardDetailsResponse?.base?.actualReward,
			  let maxReward = rewardDetailsResponse?.base?.maxReward else {
			return nil
		}
		return LocalizableString.RewardDetails.earnedRewardDescription(actualReward.toWXMTokenPrecisionString,
																	   maxReward.toWXMTokenPrecisionString).localized
	}

	func boostsSubtitle() -> String? {
		guard let reward = rewardDetailsResponse?.boost?.totalReward else {
			return nil
		}
		return LocalizableString.RewardDetails.earnedBoosts(reward.toWXMTokenPrecisionString).localized
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

	func handleIssueButtonTap() {
		guard let count = rewardDetailsResponse?.annotations?.count, count > 1 else {
			handleRewardAnnotation(annotation: rewardDetailsResponse?.mainAnnotation)
			return
		}

		let rewardAnnotationsViewModel = ViewModelsFactory.getRewardAnnotationsViewModel(device: device,
																						 annotations: rewardDetailsResponse?.annotations ?? [],
																						 followState: followState,
																						 refDate: .now)
		Router.shared.navigateTo(.rewardAnnotations(rewardAnnotationsViewModel))
	}

	func handleReadMoreTap() {
		guard let url = URL(string: DisplayedLinks.rewardMechanism.linkURL) else {
			return
		}

		UIApplication.shared.open(url)
	}

	func handleDailyRewardInfoTap() {
		let info = BottomSheetInfo(title: LocalizableString.RewardDetails.dailyReward.localized,
								   description: LocalizableString.RewardDetails.dailyRewardInfoDescription.localized,
								   scrollable: true,
								   buttonTitle: LocalizableString.RewardDetails.readMore.localized) {
			guard let url = URL(string: DisplayedLinks.rewardMechanism.linkURL) else {
				return
			}

			UIApplication.shared.open(url)
		}
		self.info = info
		showInfo = true
	}

	func handleDataQualityInfoTap() {
		let info = BottomSheetInfo(title: LocalizableString.RewardDetails.dataQuality.localized,
								   description: LocalizableString.RewardDetails.dataQualityInfoDescription.localized,
								   scrollable: true,
								   buttonTitle: LocalizableString.RewardDetails.readMore.localized) {
			guard let url = URL(string: DisplayedLinks.qodAlgorithm.linkURL) else {
				return
			}

			UIApplication.shared.open(url)
		}
		self.info = info
		showInfo = true
	}

	func handleLocationQualityInfoTap() {
		let info = BottomSheetInfo(title: LocalizableString.RewardDetails.locationQuality.localized,
								   description: LocalizableString.RewardDetails.locationQualityInfoDescription.localized,
								   scrollable: true,
								   buttonTitle: LocalizableString.RewardDetails.readMore.localized) {
			guard let url = URL(string: DisplayedLinks.polAlgorithm.linkURL) else {
				return
			}

			UIApplication.shared.open(url)

		}
		self.info = info
		showInfo = true
	}

	func handleCellPositionInfoTap() {
		let info = BottomSheetInfo(title: LocalizableString.RewardDetails.cellPosition.localized,
								   description: LocalizableString.RewardDetails.cellPositionInfoDescription.localized,
								   scrollable: true,
								   buttonTitle: LocalizableString.RewardDetails.readMore.localized) {
			guard let url = URL(string: DisplayedLinks.cellCapacity.linkURL) else {
				return
			}

			UIApplication.shared.open(url)
		}
		self.info = info
		showInfo = true
	}
}

private extension RewardDetailsViewModel {
	func handleRewardAnnotation(annotation: RewardAnnotation?) {
		guard let annotation,
			  let group = annotation.group else {
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
																				 delegate: self)
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

	func fetchRewardDetails(date: String) async -> Result<NetworkDeviceRewardDetailsResponse?, NetworkErrorResponse>? {
		guard let deviceId = device.id else {
			return nil
		}
		return try? await useCase.getRewardDetails(deviceId: deviceId, date: date)
	}
}

extension RewardDetailsViewModel: SelectStationLocationViewModelDelegate {
	func locationUpdated(with device: DeviceDetails) {
		self.device = device
	}
}

extension RewardDetailsViewModel: HashableViewModel {
	func hash(into hasher: inout Hasher) {
		hasher.combine("\(device.id)-\(rewardDetailsResponse?.hashValue)")
	}
}
