//
//  FilterViewModelTests.swift
//  WeatherXMTests
//
//  Created by Pantelis Giazitsis on 3/4/25.
//

import Testing
import DomainLayer
@testable import WeatherXM

@Suite(.serialized)
@MainActor
struct FilterViewModelTests {
	let viewModel: FilterViewModel
	let filtersUseCase: MockFiltersUseCase

	init() {
		filtersUseCase = .init()
		viewModel = .init(useCase: filtersUseCase)
	}

	@Test func handleTapOnSortBy() {
		#expect(viewModel.selectedSortBy == .dateAdded)
		viewModel.handleTapOn(filterPresentable: SortBy.lastActive)
		#expect(viewModel.selectedSortBy == .lastActive)
	}

	@Test func handleTapOnFilter() {
		#expect(viewModel.selectedFilter == .all)
		viewModel.handleTapOn(filterPresentable: Filter.favoritesOnly)
		#expect(viewModel.selectedFilter == .favoritesOnly)
	}

	@Test func handleTapOnGroupBy() {
		#expect(viewModel.selectedGroupBy == .noGroup)
		viewModel.handleTapOn(filterPresentable: GroupBy.relationship)
		#expect(viewModel.selectedGroupBy == .relationship)
	}

	@Test func handleResetTap() {
		viewModel.handleTapOn(filterPresentable: SortBy.lastActive)
		viewModel.handleTapOn(filterPresentable: Filter.favoritesOnly)
		viewModel.handleTapOn(filterPresentable: GroupBy.relationship)

		#expect(viewModel.selectedSortBy == .lastActive)
		#expect(viewModel.selectedSortBy != .defaultValue)
		#expect(viewModel.selectedFilter == .favoritesOnly)
		#expect(viewModel.selectedFilter != .defaultValue)
		#expect(viewModel.selectedGroupBy == .relationship)
		#expect(viewModel.selectedGroupBy != .defaultValue)

		viewModel.handleResetTap()
		#expect(viewModel.selectedSortBy == .defaultValue)
		#expect(viewModel.selectedFilter == .defaultValue)
		#expect(viewModel.selectedGroupBy == .defaultValue)
	}

	@Test func handleSaveTap() {
		viewModel.handleTapOn(filterPresentable: SortBy.dateAdded)
		viewModel.handleTapOn(filterPresentable: Filter.all)
		viewModel.handleTapOn(filterPresentable: GroupBy.noGroup)
		viewModel.handleSaveTap()
		#expect(viewModel.isSaveEnabled == false)
	}

	@Test func checkSaveButtonAvailability() {
		#expect(viewModel.isSaveEnabled == false)
		viewModel.handleTapOn(filterPresentable: SortBy.lastActive)
		#expect(viewModel.isSaveEnabled == true)
	}
}
