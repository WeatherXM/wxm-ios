//
//  StationRewardsViewModel.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 20/3/23.
//

import Foundation
import Combine
import DomainLayer
import Toolkit

class StationRewardsViewModel: ObservableObject {
    let offsetObject: TrackableScrollOffsetObject = TrackableScrollOffsetObject()
	@Published private(set) var viewState: ViewState = .loading

    private(set) var device: DeviceDetails?
	private(set) var followState: UserDeviceFollowState?
    private(set) var failObj: FailSuccessStateObject?
	var isDeviceOwned: Bool {
		followState?.relation == .owned
	}

	@Published var response: NetworkDeviceRewardsSummaryResponse?
    private var useCase: RewardsUseCase?
    private weak var containerDelegate: StationDetailsViewModelDelegate?
    private let deviceId: String
    private var cancellables: Set<AnyCancellable> = []

    init(deviceId: String, containerDelegate: StationDetailsViewModelDelegate? = nil, useCase: RewardsUseCase?) {
        self.deviceId = deviceId
        self.containerDelegate = containerDelegate
        self.useCase = useCase
		
		observeOffset()
    }

    func refresh(completion: @escaping VoidCallback) {
        Task { @MainActor in
            await containerDelegate?.shouldRefresh()
            completion()
        }
    }

	func handleViewDetailsTap() {
		guard let device, let timestamp = response?.latest?.timestamp else {
			return
		}

		let viewModel = ViewModelsFactory.getRewardDetailsViewModel(device: device,
																	followState: followState,
																	date: timestamp)
		Router.shared.navigateTo(.rewardDetails(viewModel))
	}

    func handleDetailedRewardsButtonTap() {
		navigateToTransactions()
    }

    func handleRetryButtonTap() {
        viewState = .loading
        refresh { }
    }

}

private extension StationRewardsViewModel {
    func observeOffset() {
        offsetObject.$diffOffset.sink { [weak self] value in
            guard let self = self else {
                return
            }
            self.containerDelegate?.offsetUpdated(diffOffset: value)
        }
        .store(in: &cancellables)
    }
}

extension StationRewardsViewModel: StationDetailsViewModelChild {
	@MainActor
    func refreshWithDevice(_ device: DeviceDetails?, followState: UserDeviceFollowState?, error: NetworkErrorResponse?) async {
        self.device = device
		self.followState = followState
		
		let tuple = await getRewards()
		if let error = tuple.error {
			self.showErrorView(error: error)

            return
        }
		
		self.response = tuple.response
		self.viewState = tuple.response?.isEmpty == false ? .content : .empty
	}

    func showLoading() {
        viewState = .loading
    }
}

private extension StationRewardsViewModel {

	func navigateToTransactions() {
		guard let device else {
			return
		}
		Router.shared.navigateTo(.transactions(ViewModelsFactory.getTransactionDetailsViewModel(device: device, followState: followState)))
	}

    func showErrorView(error: NetworkErrorResponse) {
        let obj = error.uiInfo.defaultFailObject(type: .stationRewards) { [weak self] in
            self?.handleRetryButtonTap()
        }

        DispatchQueue.main.async {
            self.failObj = obj
            self.viewState = .fail
        }
    }

	func getRewards() async -> (response: NetworkDeviceRewardsSummaryResponse?, error: NetworkErrorResponse?) {
		do {
			guard let result = try await useCase?.getDeviceRewardsSummary(deviceId: deviceId) else {
				return (nil, nil)
			}

			switch result {
				case .success(let rewards):
					return (rewards, nil)
				case .failure(let error):
					return (nil, error)
			}
		} catch {
			print(error)
			return (nil, nil)
		}
	}
}
