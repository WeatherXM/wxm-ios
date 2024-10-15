//
//  OverviewViewModel.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 6/3/23.
//

import Foundation
import DomainLayer
import Toolkit
import Combine

class OverviewViewModel: ObservableObject {
    @Published private(set) var viewState: ViewState = .loading
    @Published private(set) var ctaObject: CTAContainerView.CTAObject?
	@Published private(set) var showNoDataInfo: Bool = false
	@Published var showStationHealthInfo: Bool = false

    let offsetObject: TrackableScrollOffsetObject = TrackableScrollOffsetObject()
	private(set) var device: DeviceDetails? {
		didSet {
			guard let device else {
				showNoDataInfo = false
				return
			}

			showNoDataInfo = device.qod == nil
		}
	}
    private(set) var followState: UserDeviceFollowState?
    weak var containerDelegate: StationDetailsViewModelDelegate?
    private(set) var failObj: FailSuccessStateObject?
    private var cancellables: Set<AnyCancellable> = []

    init(device: DeviceDetails?) {
        self.device = device
        refresh {}
        observeOffset()
    }

    func refresh(completion: @escaping VoidCallback) {
        Task { @MainActor [weak self] in
            await self?.containerDelegate?.shouldRefresh()
            completion()
        }
    }

    func handleRetryButtonTap() {
        viewState = .loading
        refresh {

        }
    }

    func handleHistoricalDataButtonTap() {
        guard let device else {
            return
        }
        Router.shared.navigateTo(.history(ViewModelsFactory.getHistoryContainerViewModel(device: device)))
    }

	func handleStationHealthInfoTap() {
		showStationHealthInfo = true
	}

	func handleStationHealthBottomSheetButtonTap() {
		HelperFunctions().openUrl(DisplayedLinks.qodAlgorithm.linkURL)
	}

	func handleDataQualityTap() {
		navigateToRewardDetails()
	}

	func handleLocationQualityTap() {
		navigateToRewardDetails()
	}
}

private extension OverviewViewModel {
    func observeOffset() {
        offsetObject.$diffOffset.sink { [weak self] value in
            guard let self = self else {
                return
            }
            self.containerDelegate?.offsetUpdated(diffOffset: value)
        }
        .store(in: &cancellables)
    }

    func generateCtaObject() -> CTAContainerView.CTAObject {
        let description: LocalizableString.StationDetails = .overviewFollowCtaText
        let buttonTitle: LocalizableString = .favorite
        let buttonIcon: FontIcon = .heart
        let buttonAction: VoidCallback = { [weak self] in self?.containerDelegate?.shouldAskToFollow() }

        let obj = CTAContainerView.CTAObject(description: description.localized,
                                             buttonTitle: buttonTitle.localized,
                                             buttonFontIcon: buttonIcon,
                                             buttonAction: buttonAction)

        return obj
    }

	func navigateToRewardDetails() {
		guard let device, let ts = device.latestQodTs else {
			return
		}

		let viewModel = ViewModelsFactory.getRewardDetailsViewModel(device: device,
																	followState: followState,
																	date: ts)
		Router.shared.navigateTo(.rewardDetails(viewModel))
	}
}

// MARK: - StationDetailsViewModelChild

extension OverviewViewModel: StationDetailsViewModelChild {
	@MainActor
	func refreshWithDevice(_ device: DeviceDetails?, followState: UserDeviceFollowState?, error: NetworkErrorResponse?) async {
		self.device = device
		self.followState = followState
		self.ctaObject = followState == nil ? self.generateCtaObject() : nil
		
		if let error {
			let info = error.uiInfo
			self.failObj = info.defaultFailObject(type: .overview, retryAction: self.handleRetryButtonTap)
			self.viewState = .fail
		} else {
			self.viewState = .content
		}
	}

    func showLoading() {
        viewState = .loading
    }
}

// MARK: - Mock

extension OverviewViewModel {
    private convenience init() {
        var device = NetworkDevicesResponse()
        device.address = "WetherXM HQ"
        device.name = "A nice station"
        device.attributes.isActive = true
        device.attributes.lastActiveAt = Date().ISO8601Format()
        self.init(device: nil)
    }

    static var mockInstance: OverviewViewModel {
        OverviewViewModel()
    }
}
