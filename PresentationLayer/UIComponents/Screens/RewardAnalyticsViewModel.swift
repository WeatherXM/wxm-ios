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
		return "+\(value.toWXMTokenPrecisionString) \(StringConstants.wxmCurrency)"
	}
	var summaryEarnedValueText: String {
		let value = summaryResponse?.total ?? 0.0
		return "\(value.toWXMTokenPrecisionString) \(StringConstants.wxmCurrency)"
	}
	
	// Summary
	@Published var suammaryRewardsIsLoading: Bool = false
	@Published var summaryMode: DeviceRewardsMode = .week {
		didSet {
			refreshSummaryRewards()
		}
	}
	@Published var summaryResponse: NetworkDevicesRewardsResponse? {
		didSet {
			updateSummaryCharts()
		}
	}
	@Published var summaryChartDataItems: [ChartDataItem]?

	// Selected station
	@Published var currentStationIsLoading: Bool = false
	@Published var currenStationMode: DeviceRewardsMode = .week {
		didSet {
			guard let decviceId = currentStationReward?.stationId else {
				return
			}

			refreshCurrentDevice(deviceId: decviceId)
		}
	}
	@Published var currentStationReward: (stationId: String, stationReward: NetworkDeviceRewardsResponse)? {
		didSet {
			updateCurrentStationCharts()
		}
	}
	@Published var currentStationChartDataItems: [ChartDataItem]?

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
		Task { @MainActor in
			defer {
				completion?()
			}
			
			var errorInfo: NetworkErrorResponse.UIInfo?

			if let overallResult = await getSummaryRewards() {
				switch overallResult {
					case .success(let response):
						self.summaryResponse = response
					case .failure(let error):
						errorInfo = error.uiInfo
				}
			}

			if let firstDeviceId = devices.first?.id,
			   let stationResult = await getRewardsBreakdown(for: firstDeviceId) {
				switch stationResult {
					case .success(let response):
						self.currentStationReward = (firstDeviceId, response)
					case .failure(let error):
						errorInfo = errorInfo ?? error.uiInfo
				}
			}

			if let errorMessage = errorInfo?.description?.attributedMarkdown {
				Toast.shared.show(text: errorMessage)
			}
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
		
		refreshCurrentDevice(deviceId: deviceId)
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

	func refreshCurrentDevice(deviceId: String) {
		currentStationIsLoading = true
		Task { @MainActor in
			defer {
				currentStationIsLoading = false
			}

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

	func refreshSummaryRewards() {
		suammaryRewardsIsLoading = true
		Task { @MainActor in
			defer {
				suammaryRewardsIsLoading = false
			}

			guard let result = await getSummaryRewards() else {
				return
			}

			switch result {
				case .failure(let error):
					guard let desc = error.uiInfo.description?.attributedMarkdown else {
						return
					}
					Toast.shared.show(text: desc)
				case .success(let response):
					summaryResponse = response
			}
		}
	}

	func updateSummaryCharts() {
		guard let summaryResponse else {
			return
		}

		summaryChartDataItems = RewardAnalyticsChartFactory().getChartsData(overallResponse: summaryResponse, 
																			mode: summaryMode)
	}

	func updateCurrentStationCharts() {
		guard let currentStationReward else {
			return
		}

		currentStationChartDataItems = RewardAnalyticsChartFactory().getChartsData(deviceResponse: currentStationReward.stationReward,
																				   mode: currenStationMode)
	}

	func getSummaryRewards() async -> Result<NetworkDevicesRewardsResponse, NetworkErrorResponse>? {
		do {
			let  result = try await useCase.getUserDevicesRewards(mode: summaryMode).toAsync().result
			return result
		} catch {
			print(error)
			return nil
		}
	}

	func getRewardsBreakdown(for deviceId: String) async -> Result<NetworkDeviceRewardsResponse, NetworkErrorResponse>? {
		do {
			let  result = try await useCase.getUserDeviceRewards(deviceId: deviceId,
																 mode: currenStationMode).toAsync().result
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
