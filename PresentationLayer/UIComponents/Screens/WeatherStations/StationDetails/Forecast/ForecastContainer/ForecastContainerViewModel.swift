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
    private var device: DeviceDetails?
    private var followState: UserDeviceFollowState?
    private lazy var basicForecastViewModel = {
        let vm = StationForecastViewModel(containerDelegate: containerDelegate,
                                          useCase: useCase,
                                          trackScrollOffset: false,
                                          isPremium: false)
        vm.delegate = self
        return vm
    }()
    private lazy var premiumForecastViewModel = {
        let vm = StationForecastViewModel(containerDelegate: containerDelegate,
                                          useCase: useCase,
                                          trackScrollOffset: false,
                                          isPremium: true)
        vm.delegate = self
        return vm
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
        self.device = device
        self.followState = followState

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

extension ForecastContainerViewModel: StationForecastViewModelDelegate {
    func handleForecastTap(forecast: NetworkDeviceForecastResponse) {
        guard let device,
                let index = basicForecastViewModel.forecasts.firstIndex(where: { $0.date == forecast.date }) else {
            return
        }

        let conf = ForecastDetailsViewModel.Configuration(isPremium: false,
                                                          forecasts: basicForecastViewModel.forecasts,
                                                          selectedforecastIndex: index,
                                                          selectedHour: nil,
                                                          device: device,
                                                          followState: followState)

        var premiumConf: ForecastDetailsViewModel.Configuration?
        if isSubscribed {
            let conf = ForecastDetailsViewModel.Configuration(isPremium: true,
                                                              forecasts: premiumForecastViewModel.forecasts,
                                                              selectedforecastIndex: index,
                                                              selectedHour: nil,
                                                              device: device,
                                                              followState: followState)
            premiumConf = conf
        }

        let viewModel = ViewModelsFactory.getForecastDetailsContainerViewModel(configuration: conf,
                                                                               premiumConfiguration: premiumConf)
        Router.shared.navigateTo(.forecastDetailsContainer(viewModel))
    }

    func handleWeatherTap(weather: CurrentWeather) {
        guard let device, let timezone = basicForecastViewModel.forecasts.first?.tz.toTimezone else {
            return
        }

        let selectedHour = weather.timestamp?.timestampToDate().getHour(with: timezone)
        let conf = ForecastDetailsViewModel.Configuration(isPremium: false,
                                                          forecasts: basicForecastViewModel.forecasts,
                                                          selectedforecastIndex: 0,
                                                          selectedHour: selectedHour,
                                                          device: device,
                                                          followState: followState)

        var premiumConf: ForecastDetailsViewModel.Configuration?
        if isSubscribed {
            let conf = ForecastDetailsViewModel.Configuration(isPremium: true,
                                                              forecasts: premiumForecastViewModel.forecasts,
                                                              selectedforecastIndex: 0,
                                                              selectedHour: selectedHour,
                                                              device: device,
                                                              followState: followState)
            premiumConf = conf
        }

        let viewModel = ViewModelsFactory.getForecastDetailsContainerViewModel(configuration: conf,
                                                                               premiumConfiguration: premiumConf)
        Router.shared.navigateTo(.forecastDetailsContainer(viewModel))
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
