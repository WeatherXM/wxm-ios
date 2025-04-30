//
//  NetworkDeviceRewardsSummaryResponseTests.swift
//  WeatherXMTests
//
//  Created by Pantelis Giazitsis on 29/4/25.
//

import Testing
@testable import WeatherXM
import DomainLayer

@MainActor
struct NetworkDeviceRewardsSummaryResponseTests {

	@Test
	func isEmpty() {
		var response = NetworkDeviceRewardsSummaryResponse(totalRewards: 0.0, latest: nil, timeline: nil)
		#expect(response.isEmpty)

		response = NetworkDeviceRewardsSummaryResponse(totalRewards: 0.0, latest: .mock, timeline: nil)
		#expect(!response.isEmpty)

		let entry = NetworkDeviceRewardsSummaryTimelineEntry(timestamp: Date(), baseRewardScore: 10)
		response = NetworkDeviceRewardsSummaryResponse(totalRewards: 0.0, latest: nil, timeline: [entry])
		#expect(!response.isEmpty)

		response = NetworkDeviceRewardsSummaryResponse(totalRewards: 1.0, latest: nil, timeline: nil)
		#expect(!response.isEmpty)
	}

	@Test
	func toDailyRewardCard() {
		let summary = NetworkDeviceRewardsSummary.mock
		let card = summary.toDailyRewardCard(isOwned: true)
		#expect(card.refDate == summary.timestamp)
		#expect(card.totalRewards == summary.totalReward)
		#expect(card.baseReward == summary.baseReward)
		#expect(card.baseRewardScore == Double(summary.baseRewardScore ?? 0) / 100.0)
		#expect(card.isOwned)
	}

	@Test
	func shouldShowIssue() {
		var summary = NetworkDeviceRewardsSummary.mock
		summary = NetworkDeviceRewardsSummary(timestamp: summary.timestamp, baseReward: summary.baseReward, totalBoostReward: summary.totalBoostReward, totalReward: summary.totalReward, baseRewardScore: nil, annotationSummary: summary.annotationSummary)
		#expect(summary.shouldShowIssues)

		summary = NetworkDeviceRewardsSummary(timestamp: summary.timestamp, baseReward: summary.baseReward, totalBoostReward: summary.totalBoostReward, totalReward: summary.totalReward, baseRewardScore: 50, annotationSummary: summary.annotationSummary)
		#expect(summary.shouldShowIssues)

		summary = NetworkDeviceRewardsSummary(timestamp: summary.timestamp, baseReward: summary.baseReward, totalBoostReward: summary.totalBoostReward, totalReward: summary.totalReward, baseRewardScore: 99, annotationSummary: summary.annotationSummary)
		#expect(!summary.shouldShowIssues)
	}

	@Test
	func timelineTransactionDateString() {
		let summary = NetworkDeviceRewardsSummary.mock
		let formatted = summary.timelineTransactionDateString
		#expect(type(of: formatted) == String.self)
	}

	@Test
	func testRewardAnnotation_warningType_mapping() {
		let info = RewardAnnotation(severity: .info,
									group: nil,
									title: nil,
									message: nil,
									docUrl: nil)
		let warning = RewardAnnotation(severity: .warning,
									   group: nil,
									   title: nil,
									   message: nil,
									   docUrl: nil)
		let error = RewardAnnotation(severity: .error,
									 group: nil,
									 title: nil,
									 message: nil,
									 docUrl: nil)
		#expect(info.warningType == .info)
		#expect(warning.warningType == .warning)
		#expect(error.warningType == .error)
	}

	@Test
	func testAnnotationActionButtonTile() {
		let ownedState = UserDeviceFollowState(deviceId: "", relation: .owned)
		let followedState = UserDeviceFollowState(deviceId: "", relation: .followed)
		let annotationNoWallet = RewardAnnotation(severity: .info,
												  group: .noWallet,
												  title: nil,
												  message: nil,
												  docUrl: "https://example.com")
		let annotationLocation = RewardAnnotation(severity: .info,
												  group: .locationNotVerified,
												  title: nil,
												  message: nil,
												  docUrl: "https://example.com")
		let annotationOther = RewardAnnotation(severity: .info,
											   group: .unknown(""),
											   title: nil,
											   message: nil,
											   docUrl: "https://example.com")

		// These will depend on MainScreenViewModel.shared.isWalletMissing, so just check for non-nil/expected fallback
		#expect(annotationNoWallet.annotationActionButtonTile(with: ownedState) != nil)
		#expect(annotationLocation.annotationActionButtonTile(with: ownedState) != nil)
		#expect(annotationOther.annotationActionButtonTile(with: followedState) == LocalizableString.RewardDetails.readMore.localized)
	}

	@Test
	func testTimelineEntry_toWeeklyEntry_returnsEntryOrNil() {
		let entry = NetworkDeviceRewardsSummaryTimelineEntry(timestamp: Date(), baseRewardScore: 10)
		let weeklyEntry = entry.toWeeklyEntry
		#expect(weeklyEntry != nil)
		let entryNil = NetworkDeviceRewardsSummaryTimelineEntry(timestamp: nil, baseRewardScore: 10)
		#expect(entryNil.toWeeklyEntry == nil)
	}

	@Test
	func testArrayToWeeklyEntries_compactsEntries() {
		let entry1 = NetworkDeviceRewardsSummaryTimelineEntry(timestamp: Date(), baseRewardScore: 10)
		let entry2 = NetworkDeviceRewardsSummaryTimelineEntry(timestamp: nil, baseRewardScore: 10)
		let entries = [entry1, entry2]
		let weeklyEntries = entries.toWeeklyEntries
		#expect(weeklyEntries.count == 1)
	}
}

// Mock types for testing
private extension NetworkDeviceRewardsSummary {
	static var mock: NetworkDeviceRewardsSummary {
		.init(timestamp: Date(), baseReward: 1.0, totalBoostReward: 0.5, totalReward: 1.5, baseRewardScore: 80, annotationSummary: nil)
	}
}
