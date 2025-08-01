//
//  MyStationsViewModelTests.swift
//  WeatherXMTests
//
//  Created by Pantelis Giazitsis on 3/4/25.
//

import Testing
@testable import WeatherXM
import DomainLayer

@Suite(.serialized)
@MainActor
struct MyStationsViewModelTests {
	let viewModel: MyStationsViewModel
	let meUseCase: MockMeUseCase
	let remoteConfigUseCase: MockRemoteConfigUseCase
	let photoGalleryUseCase: MockPhotoGalleryUseCase
	let linkNavigation: MockLinkNavigation

	init() {
		meUseCase = .init()
		remoteConfigUseCase = .init()
		photoGalleryUseCase = .init()
		linkNavigation = MockLinkNavigation()
		viewModel = .init(meUseCase: meUseCase,
						  remoteConfigUseCase: remoteConfigUseCase,
						  photosGalleryUseCase: photoGalleryUseCase,
						  linkNavigation: linkNavigation)
	}

	@Test func updateProgressUpload() {
		viewModel.updateProgressUpload()
		#expect(viewModel.uploadState == nil)
	}

	@Test func getDevices() async throws {
		try await confirmation { confirm in
			viewModel.getDevices() {
				#expect(!viewModel.devices.isEmpty)
				confirm()
			}
			try await Task.sleep(for: .seconds(1))
		}
	}

	@Test func getFollowState() async throws {
		#expect(viewModel.devices.isEmpty)
		viewModel.getDevices()
		try await Task.sleep(for: .seconds(1))
		let device = try #require(viewModel.devices.first)
		var followState = viewModel.getFollowState(for: device)
		#expect(followState == nil)

		let invalidDevice = DeviceDetails(id: "InvalidId",
										  name: "Name",
										  isActive: false)
		followState = viewModel.getFollowState(for: invalidDevice)
		#expect(followState == nil)
	}

	@Test func handleInfoBannerDismissTap() {
		#expect(remoteConfigUseCase.lastDismissedInfoBannerId == nil)
		viewModel.handleInfoBannerDismissTap()
		#expect(remoteConfigUseCase.lastDismissedInfoBannerId == "124")
	}

	@Test func handleBuyButtonTap() {
		#expect(linkNavigation.openedUrl == nil)
		viewModel.handleBuyButtonTap()
		#expect(linkNavigation.openedUrl == DisplayedLinks.shopLink.linkURL)
	}

	@Test func handleFollowInExplorerTap() {
		#expect(viewModel.mainVM?.selectedTab == .home)
		viewModel.handleFollowInExplorerTap()
		#expect(viewModel.mainVM?.selectedTab == .explorer)
	}
}
