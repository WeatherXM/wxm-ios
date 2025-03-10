//
//  DeviceLocationUseCaseTests.swift
//  WeatherXMTests
//
//  Created by Pantelis Giazitsis on 10/3/25.
//

import Testing
@testable import DomainLayer
import Toolkit

struct DeviceLocationUseCaseTests {
	let repository = MockDeviceLocationRepositoryImpl()
	let useCase: DeviceLocationUseCase
	let cancellableWrapper: CancellableWrapper = .init()

	init() {
		self.useCase = .init(deviceLocationRepository: repository)
	}
	
    @Test func getCountryInfos() {
		#expect(self.useCase.getCountryInfos()?.isEmpty == true)
    }

	@Test func search() async throws {
		try await confirmation { confirm in
			useCase.searchResults.sink { results in
				#expect(results.count == 1)
				confirm()
			}.store(in: &cancellableWrapper.cancellableSet)
			useCase.searchFor("124")
			try await Task.sleep(for: .seconds(1))
		}
	}

	@Test func locationFromSearchResult() async throws {
		await confirmation { confirm in
			let searchResult = DeviceLocationSearchResult(id: "124", description: "test")
			useCase.locationFromSearchResult(searchResult).sink { location in
				#expect(location.id == "124")
				confirm()
			}.store(in: &cancellableWrapper.cancellableSet)
		}
	}

	@Test func locationFromCoordinates() async throws {
		await confirmation { confirm in
			let coordinates = LocationCoordinates(lat: 0.0, long: 0.0)
			useCase.locationFromCoordinates(coordinates).sink { location in
				#expect(location?.id == "124")
				confirm()
			}.store(in: &cancellableWrapper.cancellableSet)
		}
	}

	@Test func areLocationCoordinatesValid() {
		let coordinates = LocationCoordinates(lat: 0.0, long: 0.0)
		#expect(useCase.areLocationCoordinatesValid(coordinates))
	}

	@Test func getSuggestedDeviceLocation() {
		#expect(useCase.getSuggestedDeviceLocation() == nil)
	}
}
