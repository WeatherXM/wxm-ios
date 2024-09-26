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
		guard !suammaryRewardsIsLoading, let value = summaryResponse?.total else {
			return ""
		}
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
	@Published var showSummaryError: Bool = false
	private(set) var summaryFailObject: FailSuccessStateObject?

	// Selected station
	@Published var currentStationIdLoading: String? = nil
	@Published var currenStationMode: DeviceRewardsMode = .week {
		didSet {
			guard let decviceId = currentStationReward?.stationId else {
				return
			}

			refreshCurrentDevice(deviceId: decviceId)
		}
	}
	@Published var currentStationReward: (stationId: String, stationReward: NetworkDeviceRewardsResponse?)? {
		didSet {
			updateCurrentStationCharts()
		}
	}
	@Published var currentStationChartDataItems: [ChartDataItem]?
	@Published var currentStationChartLegendItems: [ChartLegendView.Item]?
	@Published var currentStationError: Bool = false
	private(set) var currentStationFailObject: FailSuccessStateObject?

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
			
			refreshSummaryRewards()

			if let firstDeviceId = devices.first?.id {
				refreshCurrentDevice(deviceId: firstDeviceId)
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
		currentStationError = false
		currentStationIdLoading = deviceId
		Task { @MainActor [weak self] in
			defer {
				currentStationIdLoading = nil
			}

			guard let result = await self?.getRewardsBreakdown(for: deviceId) else {
				return
			}

			switch result {
				case .failure(let error):
					let info = error.uiInfo(description: LocalizableString.RewardAnalytics.tapToRetry.localized)
					self?.currentStationFailObject = info.defaultFailObject(type: .rewardAnalytics,
																			failMode: .retry) {
							self?.refreshCurrentDevice(deviceId: deviceId)
						}
					self?.currentStationError = true
					self?.currentStationReward = (deviceId, nil)
				case .success(let response):
					self?.currentStationReward = (deviceId, response)
			}
		}
	}

	func refreshSummaryRewards() {
		showSummaryError = false
		suammaryRewardsIsLoading = true
		Task { @MainActor [weak self] in
			defer {
				suammaryRewardsIsLoading = false
			}

			guard let result = await self?.getSummaryRewards() else {
				return
			}

			switch result {
				case .failure(let error):
					let info = error.uiInfo(description: LocalizableString.RewardAnalytics.tapToRetry.localized)
					self?.summaryFailObject = info.defaultFailObject(type: .changeFrequency,
																	 failMode: .retry) {
						self?.refreshSummaryRewards()
					}
					self?.showSummaryError = true
					self?.summaryResponse = nil
				case .success(let response):
					self?.summaryResponse = response
			}
		}
	}

	func updateSummaryCharts() {
		guard let summaryResponse else {
			summaryChartDataItems = nil
			return
		}

		summaryChartDataItems = RewardAnalyticsChartFactory().getChartsData(overallResponse: summaryResponse, 
																			mode: summaryMode)
	}

	func updateCurrentStationCharts() {
		guard let stationReward = currentStationReward?.stationReward else {
			currentStationChartDataItems = nil
			currentStationChartLegendItems = nil
			return
		}

		let data = RewardAnalyticsChartFactory().getChartsData(deviceResponse: stationReward,
															   mode: currenStationMode)
		currentStationChartDataItems = data.dataItems
		currentStationChartLegendItems = data.legendItems
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
