//
//  MockSwinject.swift
//  WeatherXMTests
//
//  Created by Pantelis Giazitsis on 1/4/25.
//

import Foundation
import Swinject
import DomainLayer
import WeatherXM

class MockSwinject: SwinjectInterface {

	init() {}

	let swinjectContainer: Container = {

		let container = Container()

		container.register(MeUseCaseApi.self) { resolver in
			MockMeUseCase()
		}

		container.register(DeviceDetailsUseCaseApi.self) { resolver in
			MockDeviceDetailsUseCase()
		}

		return container
	}()

	// MARK: - Implementing the protocol

	func getContainerForSwinject() -> Container {
		return swinjectContainer
	}
}
