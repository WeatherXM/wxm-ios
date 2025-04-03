//
//  SelectStationLocationViewModelTests.swift
//  WeatherXMTests
//
//  Created by Pantelis Giazitsis on 3/4/25.
//

import Testing
import Toolkit
@testable import WeatherXM
import DomainLayer
import CoreLocation

private class LocationDelegate: SelectStationLocationViewModelDelegate {
	var locationUpdatedCalled = false

	func locationUpdated(with device: DeviceDetails) {
		locationUpdatedCalled = true
	}
}

@MainActor
struct SelectStationLocationViewModelTests {
	let viewModel: SelectStationLocationViewModel
	let deviceLocationUseCase: MockDeviceLocationUseCase
	let meUseCase: MockMeUseCase
	private let delegate: LocationDelegate
	let cancellableWrapper: CancellableWrapper = .init()

	init() {
		let device = DeviceDetails.mockDevice
		delegate = LocationDelegate()
		deviceLocationUseCase = .init()
		meUseCase = .init()
		viewModel = .init(device: device,
						  deviceLocationUseCase: deviceLocationUseCase,
						  meUseCase: meUseCase,
						  delegate: delegate)
	}

	@Test func handleConfirmTap() async throws {
		#expect(viewModel.selectedCoordinate == nil)
		let coordinate = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
		viewModel.updatedSelectedCoordinate(coordinate: coordinate)
		#expect(viewModel.selectedCoordinate?.latitude == coordinate.latitude)
		#expect(viewModel.selectedCoordinate?.longitude == coordinate.longitude)

		#expect(!delegate.locationUpdatedCalled)
		viewModel.handleConfirmTap()
		try await Task.sleep(for: .seconds(1))
		#expect(delegate.locationUpdatedCalled)
	}
}
