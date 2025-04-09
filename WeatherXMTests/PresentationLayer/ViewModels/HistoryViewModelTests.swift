//
//  HistoryViewModelTests.swift
//  WeatherXMTests
//
//  Created by Pantelis Giazitsis on 2/4/25.
//

import Testing
@testable import WeatherXM
import Foundation

@Suite(.serialized)
@MainActor
struct HistoryViewModelTests {
	let useCase: MockHistoryUseCase

	init() {
		useCase = .init()
	}

	@Test func refresh() async throws {
		let date = Date()
		let viewModel = HistoryViewModel(device: .mockDevice,
										 historyUseCase: useCase,
										 date: date)

		#expect(viewModel.getNoDataDateFormat() == date.getFormattedDate(format: .monthLiteralDayYear).capitalized)
		#expect(viewModel.currentHistoryData == nil)
		try await confirmation { confirm in
			viewModel.refresh {
				#expect(viewModel.currentHistoryData != nil)
				confirm()
			}
			try await Task.sleep(for: .seconds(1))
		}
    }

}
