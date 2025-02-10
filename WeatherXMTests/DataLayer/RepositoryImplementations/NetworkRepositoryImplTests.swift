//
//  NetworkRepositoryImplTests.swift
//  WeatherXMTests
//
//  Created by Pantelis Giazitsis on 6/2/25.
//

import Testing
@testable import DataLayer
import DomainLayer

@Suite(.serialized)
@MainActor
struct NetworkRepositoryImplTests {

	let repositoryImpl: NetworkRepositoryImpl = .init()
	private let device: NetworkSearchDevice
	private let address: NetworkSearchAddress

	init() {
		device = .init(id: "123",
					   name: "Device",
					   bundle: .init(name: .d1,
									 title: "Bundle",
									 connectivity: .helium,
									 wsModel: "100",
									 gwModel: "200",
									 hwClass: "300"),
					   cellIndex: "123456",
					   cellCenter: .init(lat: 0.0, long: 0.0))
		address = .init(name: "Address",
						place: "Place",
						center: .init(lat: 0.0, long: 0.0))
		repositoryImpl.deleteAllRecent()
	}

    @Test func insertSearchResult() async throws {
		insertInitialItemsAndValidate()
    }

	@Test func clearSearchResult() async throws {
		insertInitialItemsAndValidate()
		repositoryImpl.deleteAllRecent()
		let recent = repositoryImpl.getSearchRecent()
		#expect(recent.isEmpty)
	}

	@Test func maxLimit() throws {
		let count = 15
		for num in 0..<count {
			let address = NetworkSearchAddress(name: "\(num)",
											   place: "Place \(num)",
											   center: .init(lat: 0.0, long: 0.0))
			repositoryImpl.insertAddressInDB(address)
		}

		let recent = repositoryImpl.getSearchRecent()
		#expect(recent.count == 10)
		#expect((recent.first as? NetworkSearchAddress)?.name == "\(count - 1)")
	}
}

private extension NetworkRepositoryImplTests {
	func insertInitialItemsAndValidate() {
		repositoryImpl.insertDeviceInDB(device)
		repositoryImpl.insertAddressInDB(address)

		let recent = repositoryImpl.getSearchRecent()
		#expect(recent.count == 2)
		#expect((recent.first as? NetworkSearchAddress)?.name == address.name)
		#expect((recent.last as? NetworkSearchDevice)?.id == device.id)
	}
}
