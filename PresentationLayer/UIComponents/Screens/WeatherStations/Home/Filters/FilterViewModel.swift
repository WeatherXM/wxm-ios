//
//  FilterViewModel.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 15/9/23.
//

import Foundation
import Combine
import DomainLayer
import Toolkit

class FilterViewModel: ObservableObject {
    @Published var selectedSortBy: SortBy = .defaultValue
    @Published var selectedFilter: Filter = .defaultValue
    @Published var selectedGroupBy: GroupBy = .defaultValue
    var isSaveEnabled: Bool {
        initialFilters?.sortBy != selectedSortBy ||
        initialFilters?.filter != selectedFilter ||
        initialFilters?.groupBy != selectedGroupBy
    }

	private let useCase: FiltersUseCaseApi
    private var cancellableSet: Set<AnyCancellable> = []
    private var initialFilters: FilterValues?

	init(useCase: FiltersUseCaseApi) {
        self.useCase = useCase
        observeFilters()
    }

    func handleTapOn(filterPresentable: any FilterPresentable) {
        switch filterPresentable {
            case let sortBy as SortBy:
                selectedSortBy = sortBy
                WXMAnalytics.shared.trackEvent(.selectContent, parameters: [.contentType: .filters,
                                                                      .itemId: .sortBy,
                                                                      .itemListId: selectedSortBy.analyticsParameterValue])
            case let filter as Filter:
                selectedFilter = filter
                WXMAnalytics.shared.trackEvent(.selectContent, parameters: [.contentType: .filters,
                                                                      .itemId: .filter,
                                                                      .itemListId: selectedFilter.analyticsParameterValue])
            case let groupBy as GroupBy:
                selectedGroupBy = groupBy
                WXMAnalytics.shared.trackEvent(.selectContent, parameters: [.contentType: .filters,
                                                                      .itemId: .groupBy,
                                                                      .itemListId: selectedGroupBy.analyticsParameterValue])
            default:
                break
        }
    }

    func handleResetTap() {
        resetSelectedFilters(defaults: true)
        WXMAnalytics.shared.trackEvent(.userAction, parameters: [.actionName: .filtersReset])
    }

    func handleSaveTap() {
        let values: FilterValues = .init(sortBy: selectedSortBy, filter: selectedFilter, groupBy: selectedGroupBy)
        useCase.saveFilters(filterValues: values)
        WXMAnalytics.shared.trackEvent(.userAction, parameters: getSaveEventParameters())
    }
}

private extension FilterViewModel {

    func getSaveEventParameters() -> [Parameter: ParameterValue] {
        [.actionName: .filtersSave,
         .sortBy: selectedSortBy.analyticsParameterValue,
         .filter: selectedFilter.analyticsParameterValue,
         .groupBy: selectedGroupBy.analyticsParameterValue]
    }

    func observeFilters() {
        useCase.getFiltersPublisher().sink { [weak self] filtersTuple in
            self?.initialFilters = filtersTuple
            self?.resetSelectedFilters(defaults: false)
        }.store(in: &cancellableSet)
    }

    func resetSelectedFilters(defaults: Bool) {
        guard !defaults, let initialFilters else {
            selectedSortBy = .defaultValue
            selectedFilter = .defaultValue
            selectedGroupBy = .defaultValue
            return
        }

        selectedSortBy = initialFilters.sortBy
        selectedFilter = initialFilters.filter
        selectedGroupBy = initialFilters.groupBy
    }
}
