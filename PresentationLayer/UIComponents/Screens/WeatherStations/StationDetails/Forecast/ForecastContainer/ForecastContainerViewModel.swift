//
//  ForecastContainerViewModel.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 31/12/25.
//

import Foundation
import DomainLayer
import Combine

@MainActor
class ForecastContainerViewModel: ObservableObject {
    weak var containerDelegate: StationDetailsViewModelDelegate?
    @Published var isSubscribed: Bool = false
    @Published var selectedTabIndex: Int = 0
    @Published var viewModels: [StationForecastViewModel] = []
    private let useCase: MeUseCaseApi?
    private var cancellables: Set<AnyCancellable> = []
    private lazy var basicForecastViewModel = {
        StationForecastViewModel(containerDelegate: containerDelegate,
                                 useCase: useCase,
                                 trackScrollOffset: false,
                                 isPremium: false)
    }()
    private lazy var premiumForecastViewModel = {
        StationForecastViewModel(containerDelegate: containerDelegate,
                                 useCase: useCase,
                                 trackScrollOffset: false,
                                 isPremium: true)
    }()

    init(containerDelegate: StationDetailsViewModelDelegate? = nil, useCase: MeUseCaseApi?) {
        self.containerDelegate = containerDelegate
        self.useCase = useCase
        observeTransactionChanges()
    }
}

extension ForecastContainerViewModel: StationDetailsViewModelChild {
    @MainActor
    func refreshWithDevice(_ device: DeviceDetails?, followState: UserDeviceFollowState?, error: NetworkErrorResponse?) async {
        let subscribedProducts = try? await useCase?.getSubscribedProducts()
        self.isSubscribed = subscribedProducts?.isEmpty == false

        var viewModels = [basicForecastViewModel]
        if isSubscribed {
            viewModels.append(premiumForecastViewModel)
        }

        self.viewModels = viewModels

        await viewModels.asyncForEach { await $0.refreshWithDevice(device, followState: followState, error: error) }
    }
    
    func showLoading() {
        viewModels.forEach { $0.showLoading() }
    }
}

private extension ForecastContainerViewModel {
    func observeTransactionChanges() {
        useCase?.transactionProductsPublisher?.sink { [weak self] _ in
            Task {
                await self?.containerDelegate?.shouldRefresh()
            }
        }.store(in: &cancellables)
    }
}
