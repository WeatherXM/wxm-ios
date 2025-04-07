//
//  OverviewViewModelTests.swift
//  WeatherXMTests
//
//  Created by Pantelis Giazitsis on 2/4/25.
//

import Testing
import Foundation
@testable import WeatherXM
import DomainLayer

class StationDetailsContainerDelegate: StationDetailsViewModelDelegate {
	var shouldRefreshCalled = false
	var didEndScrollerDraggingCalled = false
	var shouldAskToFollowCalled = false
	var offsetUpdatedCalled = false

	func shouldRefresh() async {
		shouldRefreshCalled = true
	}

	func offsetUpdated(diffOffset: CGFloat) {
		offsetUpdatedCalled = true
	}

	func didEndScrollerDragging() {
		didEndScrollerDraggingCalled = true
	}

	func shouldAskToFollow() {
		shouldAskToFollowCalled = true
	}
}


@Suite(.serialized)
@MainActor
struct OverviewViewModelTests {
	let viewModel: OverviewViewModel
	let linkNavigator: MockLinkNavigation = .init()
	private let delegate: StationDetailsContainerDelegate

	init() {
		delegate = StationDetailsContainerDelegate()
		viewModel = OverviewViewModel(device: DeviceDetails.mockDevice, linkNavigation: linkNavigator)
		viewModel.containerDelegate = delegate
	}

    @Test func refresh() async throws {
		#expect(delegate.shouldRefreshCalled == false)
		try await confirmation { confirmation in
			viewModel.refresh {
				#expect(delegate.shouldRefreshCalled == true)
				confirmation()
			}
			try await Task.sleep(for: .seconds(1))
		}
    }

	@Test func retry() async throws {
		#expect(delegate.shouldRefreshCalled == false)
		viewModel.handleRetryButtonTap()
		try await Task.sleep(for: .seconds(1))
		#expect(delegate.shouldRefreshCalled == true)
	}

	@Test func healthInfoTap() {
		#expect(!viewModel.showStationHealthInfo)
		viewModel.handleStationHealthInfoTap()
		#expect(viewModel.showStationHealthInfo)
	}

	@Test func headlthBottomSheetTap() {
		#expect(linkNavigator.openedUrl == nil)
		viewModel.handleStationHealthBottomSheetButtonTap()
		#expect(linkNavigator.openedUrl == DisplayedLinks.qodAlgorithm.linkURL)
	}
}
