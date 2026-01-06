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

    init(containerDelegate: StationDetailsViewModelDelegate? = nil, useCase: MeUseCaseApi?) {
        self.containerDelegate = containerDelegate
        self.useCase = useCase
        observeTransactionChanges()
    }
}

extension ForecastContainerViewModel: StationDetailsViewModelChild {
    func refreshWithDevice(_ device: DeviceDetails?, followState: UserDeviceFollowState?, error: NetworkErrorResponse?) async {
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
