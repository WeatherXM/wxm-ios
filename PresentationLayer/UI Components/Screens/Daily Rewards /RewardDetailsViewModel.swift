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
	private(set) var info: RewardsOverviewButtonActions.Info?
	let useCase: TokenUseCase
	var device: DeviceDetails
	let followState: UserDeviceFollowState?
	let rewardsCardOverview: StationRewardsCardOverview
	lazy var buttonActions: RewardsOverviewButtonActions = {
		getButtonActions()
	}()
	var problemsDescription: String {
		if rewardsCardOverview.lostAmount > 0.0 {
			return LocalizableString.RewardDetails.problemsDescription(rewardsCardOverview.lostAmount.toWXMTokenPrecisionString).localized
		}

		return LocalizableString.RewardDetails.zeroLostProblemsDescription.localized
	}

	init(device: DeviceDetails, followState: UserDeviceFollowState?, tokenUseCase: TokenUseCase, rewardsCardOverview: StationRewardsCardOverview) {
		self.device = device
		self.followState = followState
		self.useCase = tokenUseCase
		self.rewardsCardOverview = rewardsCardOverview
	}

	func annotationActionButtonTile(for annotation: RewardAnnotation?) -> String? {
		guard let group = annotation?.group, followState?.relation == .owned else {
			return nil
		}

		switch group {
			case .noWallet:
				if MainScreenViewModel.shared.isWalletMissing {
					return LocalizableString.RewardDetails.noWalletProblemButtonTitle.localized
				} else if annotation?.docUrl != nil {
					return LocalizableString.RewardDetails.readMore.localized
				}
				return nil
			case .locationNotVerified:
				return LocalizableString.RewardDetails.editLocation.localized
			case .unknown:
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

	func handleReadMoreTap() {
		guard let url = URL(string: DisplayedLinks.rewardMechanism.linkURL) else {
			return
		}

		UIApplication.shared.open(url)
	}

	func handleContactSupportTap() {
		openContactSupport()
	}
}

private extension RewardDetailsViewModel {
	func getButtonActions() -> RewardsOverviewButtonActions {
		.init(rewardsScoreInfoAction: {[weak self] in
			self?.info = RewardsOverviewButtonActions.rewardsScoreInfo
			self?.showInfo = true
			Logger.shared.trackEvent(.selectContent, parameters: [.contentType: .learnMore,
																  .itemId: .rewardsScore])

		}, dailyMaxInfoAction: { [weak self] in
			self?.info = RewardsOverviewButtonActions.dailyMaxInfo
			self?.showInfo = true
			Logger.shared.trackEvent(.selectContent, parameters: [.contentType: .learnMore,
																  .itemId: .maxRewards])
		}, timelineInfoAction: { [weak self] in
			var offsetString: String?
			if let identifier = self?.device.timezone,
			   let timezone = TimeZone(identifier: identifier),
			   !timezone.isUTC {
				offsetString = timezone.hoursOffsetString
			}
			self?.info = RewardsOverviewButtonActions.timelineInfo(timezoneOffset: offsetString)
			self?.showInfo = true
			Logger.shared.trackEvent(.selectContent, parameters: [.contentType: .learnMore,
																  .itemId: .timeline])
		}, errorButtonAction: {})
	}

	func handleRewardAnnotation(annotation: RewardAnnotation) {
		guard let group = annotation.group else {
			return
		}

		switch group {
			case .noWallet:
				if MainScreenViewModel.shared.isWalletMissing {
					Router.shared.navigateTo(.wallet(ViewModelsFactory.getMyWalletViewModel()))					
				} else if let docUrl = annotation.docUrl,
				   let url = URL(string: docUrl) {
					UIApplication.shared.open(url)
				}
			case .locationNotVerified:
				let viewModel = ViewModelsFactory.getSelectLocationViewModel(device: device,
																			 followState: followState,
																			 delegate: self)
				Router.shared.navigateTo(.selectStationLocation(viewModel))
			case .unknown:
				if let docUrl = annotation.docUrl,
				   let url = URL(string: docUrl) {
					UIApplication.shared.open(url)
				}
		}
	}

	/// Temporary commented functionality
	/*
	func handleAnnotationType(annotation: DeviceAnnotation) {
		guard let type = annotation.annotation else {
			return
		}

		switch type {
			case .obc:
				if device.needsUpdate(mainVM: MainScreenViewModel.shared, followState: followState) {
					// show OTA
					MainScreenViewModel.shared.showFirmwareUpdate(device: device)
					
					return
				}
				openContactSupport(annotation: annotation)
			case .spikes, .unidentifiedSpike, .anomIncrease, .unidentifiedAnomalousChange:
				if let url = URL(string: DisplayedLinks.documentationLink.linkURL) {
					UIApplication.shared.open(url)
				}
			case .noMedian, .noData, .shortConst, .longConst, .noLocationData:
				if let url = URL(string: DisplayedLinks.troubleshooting.linkURL) {
					UIApplication.shared.open(url)
				}
			case .cellCapacityReached:
				if let url = URL(string: DisplayedLinks.cellCapacity.linkURL) {
					UIApplication.shared.open(url)
				}
			case .polThresholdNotReached:
				if let url = URL(string: DisplayedLinks.polAlgorithm.linkURL) {
					UIApplication.shared.open(url)
				}
			case .qodThresholdNotReached:
				if let url = URL(string: DisplayedLinks.qodAlgorithm.linkURL) {
					UIApplication.shared.open(url)
				}
			case .frozenSensor, .relocated:
				break
			case .locationNotVerified:
				let viewModel = ViewModelsFactory.getSelectLocationViewModel(device: device,
																			 followState: followState, 
																			 delegate: self)
				Router.shared.navigateTo(.selectStationLocation(viewModel))
			case  .unknown:
				openContactSupport(annotation: annotation)
			case .noWallet:
				Router.shared.navigateTo(.wallet(ViewModelsFactory.getMyWalletViewModel()))
		}
	}
	*/

	func openContactSupport(annotation: DeviceAnnotation? = nil) {
		HelperFunctions().openContactSupport(successFailureEnum: .stationRewardsIssue,
											 email: nil,
											 serialNumber: device.label,
											 errorString: annotation?.title,
		addtionalInfo: getEmailAdditionalInfo())
	}

	func getEmailAdditionalInfo() -> String {
		let stationInfoTitle = "Station Information"
		let stationName = "Station Name: \(device.name)"
		let stationId = "Station id: \(device.id ?? "-")"
		let explorerUrl = "Explorer URL: \(device.explorerUrl)"

		let rewardInfoTitle = "Reward Information"
		let timestamp = "Reward timestamp: \(rewardsCardOverview.date?.toTimestamp() ?? "-")"
		let rewardScore = "Reward Score: \(rewardsCardOverview.rewardScore ?? 0)"
		let rewardsEarned = "Rewards Earned: \(rewardsCardOverview.actualReward)"
		let rewardsLost = "Rewards Lost: \(rewardsCardOverview.lostAmount)"
		let periodMaxReward = "Period Max Reward: \(rewardsCardOverview.maxRewards ?? 0.0)"
		let annotations = "Annotations: \(rewardsCardOverview.annnotationsList.compactMap { $0.group?.rawValue })"

		return [stationInfoTitle,
				stationName,
				stationId,
				explorerUrl,
				"",
				rewardInfoTitle,
				timestamp,
				rewardScore,
				rewardsEarned,
				rewardsLost,
				periodMaxReward,
				annotations].joined(separator: "\n")
	}
}

extension RewardDetailsViewModel: SelectStationLocationViewModelDelegate {
	func locationUpdated(with device: DeviceDetails) {
		self.device = device
	}
}

extension RewardDetailsViewModel: HashableViewModel {
	func hash(into hasher: inout Hasher) {
		hasher.combine("\(device.id)-\(rewardsCardOverview.hashValue)")
	}
}
