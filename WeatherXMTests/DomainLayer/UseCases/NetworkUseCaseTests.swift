//
//  NetworkUseCaseTests.swift
//  WeatherXMTests
//
//  Created by Pantelis Giazitsis on 7/3/25.
//

import Testing
@testable import DomainLayer
import Toolkit

struct NetworkUseCaseTests {
	let repository: MockNetworkRepositoryImpl = .init()
	let useCase: NetworkUseCase
	let cancellableWrapper: CancellableWrapper = .init()

	init() {
		self.useCase = .init(repository: repository)
	}

    @Test func getNetworkStats() async throws {
		try await confirmation { confirm in
			try useCase.getNetworkStats().sink { response in
				#expect(response.error == nil)
				#expect(response.value != nil)
				#expect(response.value?.weatherStations == nil)
				confirm()
			}.store(in: &cancellableWrapper.cancellableSet)
		}
    }

	@Test func search() async throws {
		try await confirmation { confirm in
			try useCase.search(term: "").sink { response in
				#expect(response.error == nil)
				#expect(response.value != nil)
				#expect(response.value?.addresses == nil)
				#expect(response.value?.devices == nil)
				confirm()
			}.store(in: &cancellableWrapper.cancellableSet)
		}
	}

	@Test func insertRecentDevice() {
		#expect(!repository.insertedDeviceInDB)
		useCase.insertSearchRecentDevice(device: .init(id: nil,
													   name: nil,
													   bundle: nil,
													   cellIndex: nil,
													   cellCenter: nil))
		#expect(repository.insertedDeviceInDB)
	}

	@Test func insertRecentAddress() {
		#expect(!repository.insertedAddressInDB)
		useCase.insertSearchRecentAddress(address: .init(name: nil,
														 place: nil,
														 center: nil))
		#expect(repository.insertedAddressInDB)
	}

	@Test func getSearchRecent() {
		#expect(useCase.getSearchRecent().isEmpty)
	}

	@Test func deleteAllRecent() {
		#expect(!repository.allRecentDeleted)
		useCase.deleteAllRecent()
		#expect(repository.allRecentDeleted)
	}

}
