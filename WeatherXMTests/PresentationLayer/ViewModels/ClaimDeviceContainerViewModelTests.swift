//
//  ClaimDeviceContainerViewModelTests.swift
//  WeatherXMTests
//
//  Created by Pantelis Giazitsis on 4/4/25.
//

import Testing
@testable import WeatherXM
import DomainLayer
import Combine

@MainActor
struct ClaimDeviceContainerViewModelTests {
	let viewModel: ClaimDeviceContainerViewModel
	let useCase: MockMeUseCase
	let devicesUseCase: MockDevicesUseCase
	let deviceLocationUseCase: MockDeviceLocationUseCase

	init() {
		useCase = .init()
		devicesUseCase = .init()
		deviceLocationUseCase = .init()
		viewModel = .init(useCase: useCase,
						  devicesUseCase: devicesUseCase,
						  deviceLocationUseCase: deviceLocationUseCase)
	}

	@Test func testInitialization() {
		#expect(viewModel.selectedIndex == 0)
		#expect(viewModel.isMovingNext == true)
		#expect(viewModel.showLoading == false)
		#expect(viewModel.loadingState == .loading(.init(title: "", subtitle: "")))
	}

	@Test func testMoveNext() async throws {
		viewModel.moveNext()
		try await Task.sleep(for: .seconds(1))
		#expect(self.viewModel.selectedIndex == 1)
		#expect(self.viewModel.isMovingNext == true)
	}

	@Test func testMovePrevious() async throws {
		viewModel.movePrevious()
		try await Task.sleep(for: .seconds(1))
		#expect(self.viewModel.selectedIndex == -1)
		#expect(self.viewModel.isMovingNext == false)
	}

	@Test func testHandleSerialNumber() {
		let serialNumber = ClaimDeviceSerialNumberViewModel.SerialNumber(serialNumber: "123456", key: "key")
		viewModel.handleSeriaNumber(serialNumber: serialNumber)
		#expect(viewModel.claimingKey == "key")
		#expect(viewModel.serialNumber == "123456")
	}

	@Test func testPerformClaim() async throws {
		viewModel.serialNumber = "123456"
		viewModel.location = DeviceLocation(id: "1", name: "Test Location", country: "Test Country", countryCode: "TC", coordinates: .init(lat: 0.0, long: 0.0))
		viewModel.performClaim()
		#expect(self.viewModel.showLoading == true)
		try await Task.sleep(for: .seconds(2))
		if case let .success(object) = viewModel.loadingState {
			#expect(object.title == LocalizableString.ClaimDevice.successTitle.localized)
		} else {
			Issue.record("State is not success")
		}
	}
}
