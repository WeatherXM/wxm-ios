//
//  ChangeFrequencyViewModelTests.swift
//  WeatherXMTests
//
//  Created by Pantelis Giazitsis on 4/4/25.
//

import Testing
@testable import WeatherXM
import DomainLayer
import Combine

@MainActor
struct ChangeFrequencyViewModelTests {
	let viewModel: ChangeFrequencyViewModel
	let device: DeviceDetails
	let useCase: MockDeviceInfoUseCase
	let meUseCase: MockMeUseCase

	init() {
		device = DeviceDetails.mockDevice
		useCase = MockDeviceInfoUseCase()
		meUseCase = MockMeUseCase()
		viewModel = ChangeFrequencyViewModel(device: device, useCase: useCase, meUseCase: meUseCase)
	}

	@Test func testInitialization() {
		#expect(viewModel.device.id == device.id)
		#expect(viewModel.state == .setFrequency)
		#expect(viewModel.selectedFrequency == Frequency.allCases.first)
	}

	@Test func testChangeButtonTapped() async throws{
		#expect(self.viewModel.state == .setFrequency)
		viewModel.changeButtonTapped()
		try await Task.sleep(for: .seconds(1))
		#expect(self.viewModel.state == .changeFrequency)
	}

	@Test func testCancelButtonTapped() {
		#expect(viewModel.dismissToggle == false)
		viewModel.cancelButtonTapped()
		#expect(viewModel.dismissToggle == true)
	}
}
