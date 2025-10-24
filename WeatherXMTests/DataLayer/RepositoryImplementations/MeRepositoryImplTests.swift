//
//  MeRepositoryImplTests.swift
//  WeatherXMTests
//
//  Created by Pantelis Giazitsis on 7/2/25.
//

import Testing
@testable import DataLayer
import DomainLayer
import Toolkit

@Suite(.serialized)
struct MeRepositoryImplTests {

	private let repositoryImpl: MeRepositoryImpl
	private let keychainService = KeychainHelperService()
	private let cancellableWrapper: CancellableWrapper = .init()

	init() async {
		let userDeviceService = UserDevicesService(followStatesCacheManager: MockCacheManager(),
												   userDevicesCacheManager: MockCacheManager())
		let userInfoService = UserInfoService()
		repositoryImpl = .init(userDevicesService: userDeviceService,
							   userInfoService: userInfoService)

		keychainService.deleteNetworkTokenResponseFromKeychain()
		DatabaseService.shared.deleteWeatherFromDB()
	}

	@Test func getUser() async throws {
		try await confirmation { confirm in
			repositoryImpl.userInfoPublisher.dropFirst().sink { user in
				#expect(user?.email == "user@example.com")
				#expect(user?.name == "TestUser")
				confirm()
			}.store(in: &cancellableWrapper.cancellableSet)

			let user = try await repositoryImpl.getUser().toAsync().result.get()
			#expect(user.email == "user@example.com")
			#expect(user.name == "TestUser")
			try await Task.sleep(for: .seconds(1))
		}
    }

	@Test func saveWallet() async throws {
		try await confirmation { confirm in
			repositoryImpl.userInfoPublisher.dropFirst().sink { user in
				#expect(user?.email == "user@example.com")
				#expect(user?.name == "TestUser")
				confirm()
			}.store(in: &cancellableWrapper.cancellableSet)

			let _ = try await repositoryImpl.saveUserWallet(address: "1234").toAsync().result.get()
			try await Task.sleep(for: .seconds(2))
		}
	}

	@Test func getDevices() async throws {
		var cachedDevices = repositoryImpl.getCachedDevices()
		#expect(cachedDevices == nil)

		let devices = try await repositoryImpl.getDevices(useCache: false).toAsync().result.get()
		#expect(devices.count == 3)

		cachedDevices = repositoryImpl.getCachedDevices()
		#expect(cachedDevices?.count == devices.count)
	}

	@Test func claimDevice() async throws {
		let deviceBody = ClaimDeviceBody(serialNumber: "124",
										 location: .init(latitude: 0.0, longitude: 0.0))
		let _ = try await repositoryImpl.claimDevice(claimDeviceBody: deviceBody).toAsync()
		let cachedDevices = repositoryImpl.getCachedDevices()
		#expect(cachedDevices == nil)
	}

	@Test func historicalData() async throws {
		let data = try await repositoryImpl.getUserDeviceHourlyHistoryById(deviceId: "124", date: .now, force: false).toAsync().result.get()
		#expect(!data.isEmpty)

		let date = try #require(data.first?.date)
		var persistedData = repositoryImpl.getPersistedHistoricalData(deviceId: "124", date: date)
		#expect(persistedData.count == data.count)

		DatabaseService.shared.deleteWeatherFromDB()

		persistedData = repositoryImpl.getPersistedHistoricalData(deviceId: "124", date: date)
		#expect(persistedData.isEmpty)
	}

	@Test func getFollowState() async throws {
		var state = try await repositoryImpl.getDeviceFollowState(deviceId: "124").get()
		#expect(state == nil)

		keychainService.saveNetworkTokenResponseToKeychain(item: .init(token: "123",
																	   refreshToken: "456"))

		state = try await repositoryImpl.getDeviceFollowState(deviceId: "124").get()
		#expect(state?.relation == .owned)
	}

	@Test func getFollowStates() async throws {
		var states = try await repositoryImpl.getUserDevicesFollowStates().get()
		#expect(states == nil)

		keychainService.saveNetworkTokenResponseToKeychain(item: .init(token: "123",
																	   refreshToken: "456"))

		states = try await repositoryImpl.getUserDevicesFollowStates().get()
		#expect(states?.first?.relation == .owned)
	}

	@Test func setLocation() async throws {
		let devices = try await repositoryImpl.getDevices(useCache: false).toAsync().result.get()
		#expect(devices.count == 3)

		let _ = try await repositoryImpl.setDeviceLocationById(deviceId: "124", lat: 0.0, lon: 0.0).toAsync().result

		let cachedDevices = repositoryImpl.getCachedDevices()
		#expect(cachedDevices == nil)
	}

	@Test func getDeviceSupport() async throws {
		let response = try await repositoryImpl.getDeviceSupport(deviceName: "Station").toAsync().result.get()
		#expect(response.status == .succeeded)
		let output = try #require(response.outputs?.result)
		#expect(!output.isEmpty)
	}

}
