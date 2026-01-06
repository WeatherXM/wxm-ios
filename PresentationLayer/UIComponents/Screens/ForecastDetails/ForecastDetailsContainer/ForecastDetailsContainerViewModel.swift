//
//  ForecastDetailsContainerViewModel.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 6/1/26.
//

import Foundation
import DomainLayer

@MainActor
class ForecastDetailsContainerViewModel: ObservableObject {
    let viewModels: [ForecastDetailsViewModel]
    let navigationTitle: String
    let navigationSubtitle: String?

    @Published var selectedTabIndex: Int = 0
    @Published var fontIconState: StateFontAwesome?


    init(configuration: ForecastDetailsViewModel.Configuration,
         premiumConfiguration: ForecastDetailsViewModel.Configuration?,
         meUseCase: MeUseCaseApi?,
         linkNavigation: LinkNavigation = LinkNavigationHelper()) {
        let basicViewModel = ForecastDetailsViewModel(configuration: configuration,
                                                      meUseCase: meUseCase,
                                                      linkNavigation: linkNavigation,
                                                      showNavigationBar: premiumConfiguration == nil)
        var viewModels = [basicViewModel]

        if let premiumConfiguration {
            let premiumViewModel = ForecastDetailsViewModel(configuration: premiumConfiguration,
                                                            meUseCase: meUseCase,
                                                            linkNavigation: linkNavigation,
                                                            showNavigationBar: false)
            viewModels.append(premiumViewModel)
        }

        self.viewModels = viewModels
        self.navigationTitle = configuration.navigationTitle
        self.navigationSubtitle = configuration.navigationSubtitle
        self.fontIconState = configuration.fontAwesomeState
    }
}

extension ForecastDetailsContainerViewModel: HashableViewModel {
    nonisolated func hash(into hasher: inout Hasher) {
        hasher.combine(navigationTitle)
    }
}
