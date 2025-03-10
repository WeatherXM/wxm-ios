//
//  HistoryUseCaseTest.swift
//  WeatherXMTests
//
//  Created by Pantelis Giazitsis on 10/3/25.
//

import Testing
@testable import DomainLayer
import Toolkit

struct HistoryUseCaseTest {
	let meRepository: MockMeRepositoryImpl = .init()
	let useCase: HistoryUseCase
	let cancellableWrapper: CancellableWrapper = .init()

	init() {
		self.useCase = HistoryUseCase(meRepository: meRepository)
	}

    @Test func fetch() async throws {
		try await confirmation { confirm in
			try useCase.getWeatherHourlyHistory(deviceId: "124", date: .now).sink { response in
				let value = response.value
				#expect(value?.isEmpty == true)
				confirm()
			}.store(in: &cancellableWrapper.cancellableSet)
		}
    }

}
