//
//  ProfileViewModelTests.swift
//  WeatherXMTests
//
//  Created by Pantelis Giazitsis on 3/4/25.
//

import Testing
@testable import WeatherXM
import Toolkit
import DomainLayer

@Suite(.serialized)
@MainActor
struct ProfileViewModelTests {
	let viewModel: ProfileViewModel
	let meUseCase: MockMeUseCase
	let remoteConfigUseCase: MockRemoteConfigUseCase
	let linkNavigation: MockLinkNavigation
	let cancellableWrapper: CancellableWrapper = .init()

	init() {
		meUseCase = .init()
		remoteConfigUseCase = .init()
		linkNavigation = .init()
		viewModel = .init(meUseCase: meUseCase,
						  remoteConfigUseCase: remoteConfigUseCase,
						  linkNavigation: linkNavigation)
	}

	@Test func userRewards() async throws {
		try await Task.sleep(for: .seconds(1))
		#expect(viewModel.totalEarned == 0.0.toWXMTokenPrecisionString)
		#expect(viewModel.totalClaimed == 0.0.toWXMTokenPrecisionString)
		#expect(viewModel.allocatedRewards == LocalizableString.Profile.noRewardsDescription.localized )
	}

	@Test func getUserInfo() async throws {
		let error = await viewModel.getUserInfo()
		#expect(error == nil)
		#expect(viewModel.userInfoResponse.email == NetworkUserInfoResponse().email)
	}


	@Test func handleBuyStationTap() {
		viewModel.handleBuyStationTap()
		#expect(linkNavigation.openedUrl == DisplayedLinks.shopLink.linkURL)
	}

	@Test func handleTotalEarnedInfoTap() {
		#expect(!viewModel.showInfo)
		viewModel.handleTotalEarnedInfoTap()
		#expect(viewModel.showInfo)
		#expect(viewModel.info?.title == LocalizableString.Profile.totalEarnedInfoTitle.localized)
	}

	@Test func handleTotalClaimedInfoTap() {
		#expect(!viewModel.showInfo)
		viewModel.handleTotalClaimedInfoTap()
		#expect(viewModel.showInfo)
		#expect(viewModel.info?.title == LocalizableString.Profile.totalClaimedInfoTitle.localized)
	}
}
