//
//  ExplorerUseCaseTests.swift
//  WeatherXMTests
//
//  Created by Pantelis Giazitsis on 10/3/25.
//

import Testing
@testable import DomainLayer
import Toolkit
import MapboxMaps

struct ExplorerUseCaseTests {
	let explorerRepository: MockExplorerRepositoryImpl = .init()
	let devicesRepository: MockDevicesRepositoryImpl = .init()
	let meRepository: MockMeRepositoryImpl = .init()
	let deviceLocationRepository: MockDeviceLocationRepositoryImpl = .init()
	let useCase: ExplorerUseCase
	let cancellableWrapper: CancellableWrapper = .init()

	init() {
		self.useCase = ExplorerUseCase(explorerRepository: explorerRepository,
									   devicesRepository: devicesRepository,
									   meRepository: meRepository,
									   deviceLocationRepository: deviceLocationRepository,
									   geocoder: MockGeocoder())
	}

    @Test func getUserLocation() async throws {
		let loc = try await useCase.getUserLocation().get()
		#expect(loc.latitude == 0.0)
		#expect(loc.longitude == 0.0)
    }

	@Test func getSuggestedDeviceLocation() {
		#expect(useCase.getSuggestedDeviceLocation() == nil)
	}

	@Test func getCell() async throws {
		let hex = try await useCase.getCell(cellIndex: "").get()
		#expect(hex?.index == "")
		#expect(hex?.polygon.isEmpty == true)

		return try await confirmation { confirm in
			try explorerRepository.getPublicHexes().sink { response in
				#expect(response.value?.first == hex)
				confirm()
			}.store(in: &cancellableWrapper.cancellableSet)
		}
	}

	@Test func getPublicHexes() async throws {
		await confirmation { confirm in
			useCase.getPublicHexes { result in
				let data = try! result.get()
				#expect(data.polygonPoints.count == 1)
				#expect(data.totalDevices == 0)
				#expect(data.geoJsonSource != nil)
				confirm()
			}
		}
	}

	@Test func getPublicDevicesOfHexIndex() async throws {
		try await confirmation { confirm in
			useCase.getPublicDevicesOfHexIndex(hexIndex: "124",
											   hexCoordinates: .init()) { result in
				let data = try! result.get()
				#expect(data.count == 1)
				confirm()
			}
			try await Task.sleep(for: .seconds(1))
		}

	}

	@Test func getPublicDevice() async {
		await confirmation { confirm in
			useCase.getPublicDevice(hexIndex: "124", deviceId: "124") { result in
				let data = try? result.get()
				#expect(data != nil)
				confirm()
			}
		}
	}

	@Test func followStation() async throws {
		let res = try await useCase.followStation(deviceId: "123")
		let data = try? res.get()
		#expect(data != nil)
	}

	@Test func unfollowStation() async throws {
		let res = try await useCase.unfollowStation(deviceId: "123")
		let data = try? res.get()
		#expect(data != nil)
	}

	@Test func getDeviceFollowState() async throws {
		let res = try await useCase.getDeviceFollowState(deviceId: "123")
		let data = try? res.get()
		#expect(data == nil)
	}
}
