//
//  DeviceInfoUseCaseTests.swift
//  WeatherXMTests
//
//  Created by Pantelis Giazitsis on 10/3/25.
//

import Testing
@testable import DomainLayer
import Combine
import Toolkit

struct DeviceInfoUseCaseTests {
	let repository: MockDeviceInfoRepositoryImpl = .init()
	let useCase: DeviceInfoUseCase
	let cancellableWrapper: CancellableWrapper = .init()

	init() {
		self.useCase = .init(repository: repository)
	}

    @Test func getDeviceInfo() async throws {
		try await confirmation { confirm in
			try useCase.getDeviceInfo(deviceId: "124").sink { response in
				let res = try? response.result.get()
				#expect(res != nil)
				#expect(res?.name == nil)

				confirm()
			}.store(in: &cancellableWrapper.cancellableSet)
		}
    }

	@Test func setFriendlyName() async throws {
		try await confirmation { confirm in
			try useCase.setFriendlyName(deviceId: "124", name: "test").sink { response in
				let res = try? response.result.get()
				#expect(res != nil)

				confirm()
			}.store(in: &cancellableWrapper.cancellableSet)
		}
	}

	@Test func deleteFriendlyName() async throws {
		try await confirmation { confirm in
			try useCase.deleteFriendlyName(deviceId: "124").sink { response in
				let res = try? response.result.get()
				#expect(res != nil)

				confirm()
			}.store(in: &cancellableWrapper.cancellableSet)
		}
	}

	@Test func disclaimDevice() async throws {
		try await confirmation { confirm in
			try useCase.disclaimDevice(serialNumber: "124").sink { response in
				let res = try? response.result.get()
				#expect(res != nil)

				confirm()
			}.store(in: &cancellableWrapper.cancellableSet)
		}
	}

	@Test func rebootStation() async {
		await confirmation { confirm in
			useCase.rebootStation(device: .emptyDeviceDetails).sink { state in
				#expect(state == .connect)
				confirm()
			}.store(in: &cancellableWrapper.cancellableSet)
		}
	}

	@Test func changeFrequency() async {
		await confirmation { confirm in
			useCase.changeFrequency(device: .emptyDeviceDetails, frequency: .AS923_1).sink { state in
				#expect(state == .changing)
				confirm()
			}.store(in: &cancellableWrapper.cancellableSet)
		}
	}

	@Test func getDevicePhotos() async throws {
		let result = try await useCase.getDevicePhotos(deviceId: "123").get()
		#expect(result.isEmpty)
	}
}
