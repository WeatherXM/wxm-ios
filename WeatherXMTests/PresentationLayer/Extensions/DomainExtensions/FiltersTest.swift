//
//  FiltersTest.swift
//  WeatherXMTests
//
//  Created by Pantelis Giazitsis on 29/4/25.
//

import Testing
@testable import WeatherXM
import DomainLayer

struct FiltersTests {

	@Test
	func groupByTitle() {
		#expect(GroupBy.title == LocalizableString.Filters.groupByTitle.localized)
	}

	@Test
	func groupByDescription() {
		#expect(GroupBy.noGroup.description == LocalizableString.Filters.groupByNoGrouping.localized)
		#expect(GroupBy.relationship.description == LocalizableString.Filters.groupByRelationship.localized)
		#expect(GroupBy.status.description == LocalizableString.Filters.groupByStatus.localized)
	}

	@Test
	func groupByAnalyticsParameterValue() {
		#expect(GroupBy.noGroup.analyticsParameterValue == .noGrouping)
		#expect(GroupBy.relationship.analyticsParameterValue == .relationship)
		#expect(GroupBy.status.analyticsParameterValue == .status)
	}

	@Test
	func sortByTitle() {
		#expect(SortBy.title == LocalizableString.Filters.sortByTitle.localized)
	}

	@Test
	func sortByDescription() {
		#expect(SortBy.dateAdded.description == LocalizableString.Filters.sortByDateAdded.localized)
		#expect(SortBy.name.description == LocalizableString.Filters.sortByName.localized)
		#expect(SortBy.lastActive.description == LocalizableString.Filters.sortByLastActive.localized)
	}

	@Test
	func sortByAnalyticsParameterValue() {
		#expect(SortBy.dateAdded.analyticsParameterValue == .dateAdded)
		#expect(SortBy.name.analyticsParameterValue == .name)
		#expect(SortBy.lastActive.analyticsParameterValue == .lastActive)
	}

	@Test
	func filterTitle() {
		#expect(Filter.title == LocalizableString.Filters.filterTitle.localized)
	}

	@Test
	func filterDescription() {
		#expect(Filter.all.description == LocalizableString.Filters.filterShowAll.localized)
		#expect(Filter.ownedOnly.description == LocalizableString.Filters.filterOwnedOnly.localized)
		#expect(Filter.favoritesOnly.description == LocalizableString.Filters.filterFavoritesOnly.localized)
	}

	@Test
	func filterAnalyticsParameterValue() {
		#expect(Filter.all.analyticsParameterValue == .all)
		#expect(Filter.ownedOnly.analyticsParameterValue == .owned)
		#expect(Filter.favoritesOnly.analyticsParameterValue == .favorites)
	}
}
