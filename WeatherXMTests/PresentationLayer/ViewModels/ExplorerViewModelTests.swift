//
//  ExplorerViewModelTests.swift
//  WeatherXMTests
//
//  Created by Pantelis Giazitsis on 3/4/25.
//

import Testing
@testable import WeatherXM
import DomainLayer
import Toolkit

@Suite(.serialized)
@MainActor
struct ExplorerViewModelTests {
	let viewModel: ExplorerViewModel
	let explorerUseCase: MockExplorerUseCase
	let cancellableWrapper: CancellableWrapper = .init()

	init() {
		explorerUseCase = .init()
		viewModel = .init(explorerUseCase: explorerUseCase)
	}

	@Test func fetchExplorerData() async throws {
		viewModel.fetchExplorerData()
		try await Task.sleep(for: .seconds(2))
		#expect(!viewModel.isLoading)
		#expect(viewModel.explorerData == ExplorerData())
	}

	@Test func userLocationButtonTapped() async throws {
		viewModel.userLocationButtonTapped()
		try await confirmation { confirm in
			viewModel.snapLocationPublisher.first().sink { location in
				#expect(location?.coordinates.latitude == 0.0)
				#expect(location?.coordinates.longitude == 0.0)
				confirm()
			}.store(in: &cancellableWrapper.cancellableSet)
			try await Task.sleep(for: .seconds(2))
			#expect(viewModel.showUserLocation)
		}
	}

	@Test func snapToInitialLocation() async throws {
		viewModel.snapToInitialLocation()
		try await Task.sleep(for: .seconds(2))
		#expect(viewModel.showUserLocation)
	}
}
