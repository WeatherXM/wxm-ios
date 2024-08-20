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
	@Published var showSplits: Bool = false
	private(set) var splitItems: [RewardsSplitView.Item] = []

	let useCase: RewardsTimelineUseCase
	var device: DeviceDetails
	let followState: UserDeviceFollowState?
	let date: Date
	var rewardDetailsResponse: NetworkDeviceRewardDetailsResponse? {
		didSet {
			splitItems = rewardDetailsResponse?.rewardSplit?.map { split in
				let isUserWallet = MainScreenViewModel.shared.userInfo?.wallet?.address == split.wallet
				return split.toSplitViewItem(isUserWallet: isUserWallet)
			} ?? []
		}
	}
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
		refresh { [weak self] in
			self?.trackRewardSplitViewEvent()
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
			return rewardDetailsResponse?.mainAnnotation?.annotationActionButtonTile(with: followState)
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

	func handleSplitButtonTap() {
		showSplits = true

		let isStakeholder = rewardDetailsResponse?.isUserStakeholder == true
		WXMAnalytics.shared.trackEvent(.userAction,
									   parameters: [.actionName: .rewardSplitPressed,
													.contentType: .stakeholderContentType,
													.state: .custom(String(isStakeholder))])
	}

	func handleIssueButtonTap() {
		guard let count = rewardDetailsResponse?.annotations?.count, count > 1 else {
			rewardDetailsResponse?.mainAnnotation?.handleRewardAnnotationTap(with: device, followState: followState)
			return
		}

		let rewardAnnotationsViewModel = ViewModelsFactory.getRewardAnnotationsViewModel(device: device,
																						 annotations: rewardDetailsResponse?.annotations ?? [],
																						 followState: followState,
																						 refDate: .now)
		Router.shared.navigateTo(.rewardAnnotations(rewardAnnotationsViewModel))
	}

	func handleDailyRewardInfoTap() {
		let info = BottomSheetInfo(title: LocalizableString.RewardDetails.dailyReward.localized,
								   description: LocalizableString.RewardDetails.dailyRewardInfoDescription.localized,
								   scrollable: true,
								   analyticsScreen: .dailyRewardInfo,
								   buttonTitle: LocalizableString.RewardDetails.readMore.localized) {
			guard let url = URL(string: DisplayedLinks.rewardMechanism.linkURL) else {
				return
			}

			UIApplication.shared.open(url)
		}
		self.info = info
		showInfo = true

		WXMAnalytics.shared.trackEvent(.selectContent, parameters: [.itemId: .infoDailyRewards])
	}

	func handleDataQualityInfoTap() {
		let info = BottomSheetInfo(title: LocalizableString.RewardDetails.dataQuality.localized,
								   description: LocalizableString.RewardDetails.dataQualityInfoDescription.localized,
								   scrollable: true,
								   analyticsScreen: .dataQualityInfo,
								   buttonTitle: LocalizableString.RewardDetails.readMore.localized) {
			guard let url = URL(string: DisplayedLinks.qodAlgorithm.linkURL) else {
				return
			}

			UIApplication.shared.open(url)
		}
		self.info = info
		showInfo = true

		WXMAnalytics.shared.trackEvent(.selectContent, parameters: [.itemId: .infoQod])
	}

	func handleLocationQualityInfoTap() {
		let info = BottomSheetInfo(title: LocalizableString.RewardDetails.locationQuality.localized,
								   description: LocalizableString.RewardDetails.locationQualityInfoDescription.localized,
								   scrollable: true,
								   analyticsScreen: .locationQualityInfo,
								   buttonTitle: LocalizableString.RewardDetails.readMore.localized) {
			guard let url = URL(string: DisplayedLinks.polAlgorithm.linkURL) else {
				return
			}

			UIApplication.shared.open(url)

		}
		self.info = info
		showInfo = true

		WXMAnalytics.shared.trackEvent(.selectContent, parameters: [.itemId: .infoPol])
	}

	func handleCellPositionInfoTap() {
		let info = BottomSheetInfo(title: LocalizableString.RewardDetails.cellPosition.localized,
								   description: LocalizableString.RewardDetails.cellPositionInfoDescription.localized,
								   scrollable: true,
								   analyticsScreen: .cellRankingInfo,
								   buttonTitle: LocalizableString.RewardDetails.readMore.localized) {
			guard let url = URL(string: DisplayedLinks.cellCapacity.linkURL) else {
				return
			}

			UIApplication.shared.open(url)
		}
		self.info = info
		showInfo = true

		WXMAnalytics.shared.trackEvent(.selectContent, parameters: [.itemId: .infoCellposition])
	}

	func handleBoostTap(boost: NetworkDeviceRewardDetailsResponse.BoostReward) {
		switch boost.code {
			case .betaReward:
				let viewModel = ViewModelsFactory.getRewardsBoostViewModel(boost: boost, device: device, date: rewardDetailsResponse?.timestamp)
				Router.shared.navigateTo(.rewardBoosts(viewModel))
			default:
				Toast.shared.show(text: LocalizableString.RewardDetails.unhandledBoostMessage.localized.attributedMarkdown ?? "")
		}
	}
}

private extension RewardDetailsViewModel {
	func fetchRewardDetails(date: String) async -> Result<NetworkDeviceRewardDetailsResponse?, NetworkErrorResponse>? {
		guard let deviceId = device.id else {
			return nil
		}
		return try? await useCase.getRewardDetails(deviceId: deviceId, date: date)
	}

	func trackRewardSplitViewEvent() {
		let isStakeholder = rewardDetailsResponse?.isUserStakeholder == true
		let isRewardSplitted = rewardDetailsResponse?.isRewardSplitted == true
		let deviceState: ParameterValue = isRewardSplitted ? .rewardSplitting : .noRewardSplitting
		let userState: ParameterValue = isStakeholder ? .stakeholder : .nonStakeholder
		let params: [Parameter: ParameterValue] = [.contentName: .rewardSplittingInDailyReward,
												   .deviceState: deviceState,
												   .userState: userState]
		WXMAnalytics.shared.trackEvent(.viewContent, parameters: params)
	}
}

extension RewardDetailsViewModel: SelectStationLocationViewModelDelegate {
	func locationUpdated(with device: DeviceDetails) {
		self.device = device
	}
}

extension RewardDetailsViewModel: HashableViewModel {
	func hash(into hasher: inout Hasher) {
		hasher.combine("\(String(describing: device.id))-\(String(describing: rewardDetailsResponse?.hashValue))")
	}
}
