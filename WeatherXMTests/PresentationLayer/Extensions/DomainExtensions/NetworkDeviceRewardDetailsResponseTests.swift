//
//  NetworkDeviceRewardDetailsResponseTests.swift
//  WeatherXMTests
//
//  Created by Pantelis Giazitsis on 29/4/25.
//

import Testing
@testable import WeatherXM
import DomainLayer

@MainActor
struct NetworkDeviceRewardDetailsResponseTests {

	@Test
	func shouldShowAnnotation() {
		var response = NetworkDeviceRewardDetailsResponse(base: nil, rewardSplit: nil)
		#expect(!response.shouldShowAnnotation)

		var base = NetworkDeviceRewardDetailsResponse.Base(actualReward: nil, rewardScore: 50, maxReward: nil, qodScore: nil, cellCapacity: nil, cellPosition: nil)
		response = NetworkDeviceRewardDetailsResponse(base: base, rewardSplit: nil)
		#expect(response.shouldShowAnnotation)

		base = NetworkDeviceRewardDetailsResponse.Base(actualReward: nil, rewardScore: 99, maxReward: nil, qodScore: nil, cellCapacity: nil, cellPosition: nil)
		response = NetworkDeviceRewardDetailsResponse(base: base, rewardSplit: nil)
		#expect(!response.shouldShowAnnotation)
	}

	@Test
	func mainAnnotationPriorityOrder() {
		let error = RewardAnnotation(severity: .error,
									 group: nil,
									 title: nil,
									 message: "error",
									 docUrl: nil)
		let warning = RewardAnnotation(severity: .warning,
									   group: nil,
									   title: nil,
									   message: "warning",
									   docUrl: nil)
		let info = RewardAnnotation(severity: .info,
									group: nil,
									title: nil,
									message: "info",
									docUrl: nil)
		let base = NetworkDeviceRewardDetailsResponse.Base(actualReward: nil, rewardScore: 50, maxReward: nil, qodScore: nil, cellCapacity: nil, cellPosition: nil)
		let response = NetworkDeviceRewardDetailsResponse(annotations: [info, warning, error], base: base, rewardSplit: nil)
		#expect(response.mainAnnotation?.severity == .error)
	}

	@Test
	func mainAnnotationShouldNotShow() {
		let info = RewardAnnotation(severity: .info,
									group: nil,
									title: nil,
									message: "info",
									docUrl: nil)
		let base = NetworkDeviceRewardDetailsResponse.Base(actualReward: nil, rewardScore: 100, maxReward: nil, qodScore: nil, cellCapacity: nil, cellPosition: nil)
		let response = NetworkDeviceRewardDetailsResponse(annotations: [info], base: base, rewardSplit: nil)
		#expect(response.mainAnnotation == nil)
	}

	@Test
	func isRewardSplittedNot() {
		let responseNil = NetworkDeviceRewardDetailsResponse(rewardSplit: nil)
		let responseOne = NetworkDeviceRewardDetailsResponse(rewardSplit: [RewardSplit(stake: 1, wallet: "a", reward: 1)])
		#expect(!responseNil.isRewardSplitted)
		#expect(!responseOne.isRewardSplitted)
	}

	@Test
	func isRewardSplitted() {
		let response = NetworkDeviceRewardDetailsResponse(rewardSplit: [
			RewardSplit(stake: 1, wallet: "a", reward: 1),
			RewardSplit(stake: 2, wallet: "b", reward: 2)
		])
		#expect(response.isRewardSplitted)
	}

	@Test
	func isUserStakeholderOwned() {
		let followState = UserDeviceFollowState(deviceId: "", relation: .owned)
		let response = NetworkDeviceRewardDetailsResponse(rewardSplit: [])
		#expect(!response.isUserStakeholder(followState: followState))
	}

	@Test
	func isUserStakeholderWalletMatch() {
		let followState = UserDeviceFollowState(deviceId: "", relation: .followed)
		let split = RewardSplit(stake: 1, wallet: "wallet1", reward: 1)
		let response = NetworkDeviceRewardDetailsResponse(rewardSplit: [split])
		#expect(response.isUserStakeholder(followState: followState, userWallet: "wallet1"))
	}

	@Test
	func isUserStakeholderNoMatch() {
		let followState = UserDeviceFollowState(deviceId: "", relation: .followed)
		let split = RewardSplit(stake: 1, wallet: "wallet2", reward: 1)
		let response = NetworkDeviceRewardDetailsResponse(rewardSplit: [split])
		#expect(!response.isUserStakeholder(followState: followState))
	}

	@Test
	func dataQualityScoreObject() {
		let owned = UserDeviceFollowState(deviceId: "", relation: .owned)
		let followed = UserDeviceFollowState(deviceId: "", relation: .followed)
		let base = NetworkDeviceRewardDetailsResponse.Base(actualReward: nil, rewardScore: nil, maxReward: nil, qodScore: 10, cellCapacity: nil, cellPosition: nil)
		let response = NetworkDeviceRewardDetailsResponse(base: base, rewardSplit: nil)
		let score = response.dataQualityScoreObject(followState: owned)
		#expect(score.message.contains("very low"))
		let score2 = response.dataQualityScoreObject(followState: followed)
		#expect(score2.message.contains("very low"))
	}

	@Test
	func locationQualityScoreObjectDefault() {
		let response = NetworkDeviceRewardDetailsResponse(annotations: nil, rewardSplit: nil)
		let score = response.locationQualityScoreObject
		#expect(score.color == .success)
		#expect(score.fontIcon == .hexagonCheck)
	}

	@Test
	func locationQualityScoreObjectLocationNotVerified() {
		let annotation = RewardAnnotation(severity: .warning,
										  group: .locationNotVerified,
										  title: nil,
										  message: nil,
										  docUrl: nil)
		let response = NetworkDeviceRewardDetailsResponse(annotations: [annotation], rewardSplit: nil)
		let score = response.locationQualityScoreObject
		#expect(score.color == .warning)
		#expect(score.fontIcon == .hexagonExclamation)
		#expect(score.message == LocalizableString.RewardDetails.locationNotVerified.localized)
	}

	@Test
	func cellPositionScoreObjectDefault() {
		let response = NetworkDeviceRewardDetailsResponse(annotations: nil, rewardSplit: nil)
		let score = response.cellPositionScoreObject
		#expect(score.color == .success)
		#expect(score.fontIcon == .hexagonCheck)
	}

	@Test
	func cellPositionScoreObjectCellCapacityReached() {
		let annotation = RewardAnnotation(severity: .error,
										  group: .cellCapacityReached,
										  title: nil,
										  message: "Capacity reached",
										  docUrl: nil)
		let response = NetworkDeviceRewardDetailsResponse(annotations: [annotation], rewardSplit: nil)
		let score = response.cellPositionScoreObject
		#expect(score.color == .error)
		#expect(score.fontIcon == .hexagonXmark)
		#expect(score.message == "Capacity reached")
	}

	@Test
	func toBoostViewObjectLostRewardString() {
		let boost = NetworkDeviceRewardDetailsResponse.BoostReward(code: .betaReward, title: "Beta", description: nil, imageUrl: nil, docUrl: nil, actualReward: 0.5, rewardScore: 80, maxReward: 1.0)
		let boostCard = boost.toBoostViewObject(with: Date())
		#expect(boostCard.title == "Beta")
		#expect(boostCard.lostRewardString != nil)
	}

	@Test
	func toSplitViewItem() {
		let split = RewardSplit(stake: 1.5, wallet: "wallet", reward: 2.0)
		let item = split.toSplitViewItem(showReward: true, isUserWallet: true)
		#expect(item.address == "wallet")
		#expect(item.reward == 2.0)
		#expect(item.stake == 1.5)
		#expect(item.isUserWallet)
	}
}

// MARK: - Mocks & Stubs

extension NetworkDeviceRewardDetailsResponse {
	init(annotations: [RewardAnnotation]? = nil, base: Base? = nil, rewardSplit: [RewardSplit]? = nil) {
		self.init(timestamp: nil, totalDailyReward: nil, annotations: annotations, base: base, boost: nil, rewardSplit: rewardSplit)
	}
}
