//
//  MeUseCaseTests.swift
//  WeatherXMTests
//
//  Created by Pantelis Giazitsis on 7/3/25.
//

import Testing
@testable import DomainLayer
import Toolkit

struct MeUseCaseTests {
	let meRepository: MockMeRepositoryImpl = .init()
	let filtersRepository: MockFiltersRepositoryImpl = .init()
	let networkRepository: MockNetworkRepositoryImpl = .init()
	let userDefaultsrRepository: MockUserDefaultsRepositoryImpl = .init()
	let useCase: MeUseCase
	let cancellableWrapper: CancellableWrapper = .init()

	init() {
		self.useCase = .init(meRepository: meRepository,
							 filtersRepository: filtersRepository,
							 networkRepository: networkRepository,
							 userDefaultsrRepository: userDefaultsrRepository)
	}

    @Test func shouldShowAddButtonIndication() async throws {
        var shouldShow = await useCase.shouldShowAddButtonIndication()
		#expect(shouldShow)
		useCase.markAddButtonIndicationAsSeen()
		shouldShow = await useCase.shouldShowAddButtonIndication()
		#expect(!shouldShow)
    }

	@Test func getUser() async throws {
		try await confirmation { confirm in
			try useCase.getUserInfo().sink { response in
				#expect(response.value != nil)
				#expect(response.value?.id == "")
				#expect(response.value?.name == "")
				confirm()
			}.store(in: &cancellableWrapper.cancellableSet)
		}
	}

	@Test func getUserWallet() async throws {
		try await confirmation { confirm in
			try useCase.getUserWallet().sink { response in
				#expect(response.value != nil)
				#expect(response.value?.address == "")
				confirm()
			}.store(in: &cancellableWrapper.cancellableSet)
		}
	}

	@Test func saveUserWallet() async throws {
		try await confirmation { confirm in
			let address = "test"
			try useCase.saveUserWallet(address: address).sink { response in
				#expect(response.value != nil)
				confirm()
			}.store(in: &cancellableWrapper.cancellableSet)
		}
	}

	@Test func getDevices() async throws {
		try await confirmation { confirm in
			try useCase.getDevices().sink { response in
				#expect((try? response.get()) != nil)
				confirm()
			}.store(in: &cancellableWrapper.cancellableSet)
		}
	}

	@Test func claimDevice() async throws {
		try await confirmation { confirm in
			let body = ClaimDeviceBody(serialNumber: "",
									   location: .init())
			try useCase.claimDevice(claimDeviceBody: body).sink { response in
				#expect((try? response.get()) != nil)
				confirm()
			}.store(in: &cancellableWrapper.cancellableSet)
		}
	}

	@Test func setFrequncy() async throws {
		let error = try await useCase.setFrequency("124", frequency: .AS923_1)
		#expect(error == nil)
	}

	@Test func getFirmwares() async throws {
		try await confirmation { confirm in
			try useCase.getFirmwares(testSearch: "").sink { response in
				#expect((try? response.value) != nil)
				confirm()
			}.store(in: &cancellableWrapper.cancellableSet)
		}
	}

	@Test func getUserDeviceById() async throws {
		try await confirmation { confirm in
			try useCase.getUserDeviceById(deviceId: "1").sink { response in
				#expect((try? response.get()) != nil)
				confirm()
			}.store(in: &cancellableWrapper.cancellableSet)
		}
	}

	@Test func getUserDeviceForecastsById() async throws {
		try await confirmation { confirm in
			try useCase.getUserDeviceForecastById(deviceId: "1",
												  fromDate: "",
												  toDate: "").sink { response in
				#expect((try? response.result.get()) != nil)
				confirm()
			}.store(in: &cancellableWrapper.cancellableSet)
		}
	}

	@Test func getUserDeviceRewardsById() async throws {
		try await confirmation { confirm in
			try useCase.getUserDeviceRewards(deviceId: "124", mode: .month).sink { response in
				#expect((try? response.result.get()) != nil)
				confirm()
			}.store(in: &cancellableWrapper.cancellableSet)
		}
	}

	@Test func getUserDevicesRewards() async throws {
		try await confirmation { confirm in
			try useCase.getUserDevicesRewards(mode: .month).sink { response in
				#expect((try? response.result.get()) != nil)
				confirm()
			}.store(in: &cancellableWrapper.cancellableSet)
		}
	}

	@Test func deleteAccount() async throws {
		try await confirmation { confirm in
			try useCase.deleteAccount().sink { response in
				#expect((try? response.result.get()) != nil)
				confirm()
			}.store(in: &cancellableWrapper.cancellableSet)
		}
	}

	@Test func followStation() async throws {
		let response = try await useCase.followStation(deviceId: "124").get()
		#expect(response != nil)
	}

	@Test func unfollowStation() async throws {
		let response = try await useCase.unfollowStation(deviceId: "124").get()
		#expect(response != nil)
	}

	@Test func getFollowState() async throws {
		let response = try await useCase.getDeviceFollowState(deviceId: "124").get()
		#expect(response == nil)
	}

	@Test func hasOwnedDevice() async throws {
		let hasOwned = await useCase.hasOwnedDevices()
		#expect(!hasOwned)
	}

	@Test func getUserRewards() async throws {
		try await confirmation { confirm in
			try useCase.getUserRewards(wallet: "124").sink { response in
				#expect((try? response.result.get()) != nil)
				confirm()
			}.store(in: &cancellableWrapper.cancellableSet)
		}
	}

	@Test func setDeviceLocation() async throws {
		try await confirmation { confirm in
			try useCase.setDeviceLocationById(deviceId: "124", lat: 1.0, lon: 1.0).sink { response in
				#expect((try? response.get()) != nil)
				confirm()
			}.store(in: &cancellableWrapper.cancellableSet)
		}
	}
}
