//
//  DeviceInfoViewModelTests.swift
//  WeatherXMTests
//
//  Created by Pantelis Giazitsis on 31/3/25.
//

import Testing
@testable import WeatherXM
import DomainLayer

@Suite(.serialized)
@MainActor
struct DeviceInfoViewModelTests {

	let viewModel: DeviceInfoViewModel
	let useCase: MockDeviceInfoUseCase
	let linkNavigation: MockLinkNavigation

	init() {
		useCase = MockDeviceInfoUseCase()
		linkNavigation = MockLinkNavigation()
		let device = DeviceDetails.mockDevice
		viewModel = DeviceInfoViewModel(device: device,
										followState: .init(deviceId: device.id ?? "", relation: .followed),
										useCase: useCase,
										linkNavigation: linkNavigation)
	}

    @Test func share() async throws {
		#expect(viewModel.shareDialogText.isEmpty)
		try await Task.sleep(for: .seconds(2))
		#expect(!viewModel.shareDialogText.isEmpty)

		#expect(!viewModel.showShareDialog)
		viewModel.handleShareButtonTap()
		#expect(viewModel.showShareDialog)
    }

	@Test func contactSupport() {
		#expect(!linkNavigation.openedContactSupport)
		viewModel.handleContactSupportButtonTap()
		#expect(linkNavigation.openedContactSupport)
	}
}
