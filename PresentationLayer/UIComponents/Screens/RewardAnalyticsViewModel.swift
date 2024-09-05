//
//  RewardAnalyticsViewModel.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 2/9/24.
//

import Foundation
import DomainLayer
import Toolkit
import Combine

class RewardAnalyticsViewModel: ObservableObject {
	
	let devices: [DeviceDetails]
	var totalEearnedText: String {
		let value = devices.reduce(0.0) { $0 + ($1.rewards?.totalRewards ?? 0.0) }
		return "\(value.toWXMTokenPrecisionString) \(StringConstants.wxmCurrency)"
	}
	var lastRunValueText: String {
		let value = devices.reduce(0.0) { $0 + ($1.rewards?.actualReward ?? 0.0) }
		return "\(value.toWXMTokenPrecisionString) \(StringConstants.wxmCurrency)"
	}
	var overallEarnedValueText: String {
		let value = overallResponse?.total ?? 0.0
		return "\(value.toWXMTokenPrecisionString) \(StringConstants.wxmCurrency)"
	}
	
	@Published var overallResponse: NetworkDevicesRewardsResponse? {
		didSet {
			updateOverallCharts()
		}
	}
	@Published var overallChartDataItems: [ChartDataItem]?
	@Published var currentStationReward: (stationId: String, stationReward: NetworkDeviceRewardsResponse)?
	@Published var state: RewardAnalyticsView.State = .noRewards
	private lazy var noStationsConfiguration: WXMEmptyView.Configuration = {
		WXMEmptyView.Configuration(imageFontIcon: (.faceSadCry, .FAProLight),
								   title: LocalizableString.RewardAnalytics.emptyStateTitle.localized,
								   description: LocalizableString.RewardAnalytics.emptyStateDescription.localized.attributedMarkdown,
								   buttonFontIcon: (.cart, .FAProSolid),
								   buttonTitle: LocalizableString.Profile.noRewardsWarningButtonTitle.localized) {
			HelperFunctions().openUrl(DisplayedLinks.shopLink.linkURL)
		}
	}()

	private let useCase: MeUseCase
	private var cancellableSet = Set<AnyCancellable>()

	init(useCase: MeUseCase, devices: [DeviceDetails]) {
		self.useCase = useCase
		self.devices = devices
		updateState()

		refresh()
	}

	func refresh(completion: VoidCallback? = nil) {
		do {
			try useCase.getUserDevicesRewards(mode: .week).sink { [weak self] response in
				defer {
					completion?()
				}

				if let error = response.error {
					if let message = error.backendError?.message.attributedMarkdown {
						WXMAnalytics.shared.trackEvent(.viewContent, parameters: [.contentName: .failure,
																				  .itemId: .custom(error.backendError?.code ?? "")])
						Toast.shared.show(text: message)
					}
					return
				}

				self?.overallResponse = response.value
			}.store(in: &cancellableSet)
		} catch {
			print(error)
		}
	}

	func isExpanded(device: DeviceDetails) -> Bool {
		guard let deviceId = device.id else {
			return false
		}

		return currentStationReward?.stationId == deviceId
	}

	func handleDeviceTap(_ device: DeviceDetails) {
		guard let deviceId = device.id, currentStationReward?.stationId != deviceId else {
			currentStationReward = nil
			return
		}

		Task { @MainActor in
			guard let result = await getRewardsBreakdown(for: deviceId) else {
				return
			}
			switch result {
				case .failure(let error):
					guard let desc = error.uiInfo.description?.attributedMarkdown else {
						return
					}
					Toast.shared.show(text: desc)
				case .success(let response):
					currentStationReward = (deviceId, response)
			}
		}
	}
}

private extension RewardAnalyticsViewModel {
	func updateState() {
		if devices.isEmpty {
			state = .empty(noStationsConfiguration)
		} else if devices.reduce(0, { $0 + ($1.rewards?.totalRewards ?? 0.0)}) == 0 {
			state = .noRewards
		} else {
			state = .content
		}
	}

	func updateOverallCharts() {
		guard let overallResponse else {
			return
		}

		overallChartDataItems = RewardAnalyticsChartFactory().getChartsData(overallResponse: overallResponse, 
																			mode: .week)
	}

	func getRewardsBreakdown(for deviceId: String) async -> Result<NetworkDeviceRewardsResponse, NetworkErrorResponse>? {
		do {
			let  result = try await useCase.getUserDeviceRewards(deviceId: deviceId,
																 mode: .week).toAsync().result
			return result
		} catch {
			print(error)
			return nil
		}
	}
}

extension RewardAnalyticsViewModel: HashableViewModel {
	func hash(into hasher: inout Hasher) {
		hasher.combine("\(devices.map { $0.id})")
	}
}
