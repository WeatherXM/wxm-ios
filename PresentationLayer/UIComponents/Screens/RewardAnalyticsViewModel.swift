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
	@Published var stationItems: [String: StationItem] = [:]

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

		initialFetch()
	}

	func isExpanded(device: DeviceDetails) -> Bool {
		guard let deviceId = device.id else {
			return false
		}

		return stationItems[deviceId] != nil
	}

	func handleDeviceTap(_ device: DeviceDetails) {
		guard stationItems[device.id ?? ""] != nil else {
			refreshCurrentDevice(deviceId: device.id, mode: .week)
			return
		}
		
		stationItems.removeValue(forKey: device.id ?? "")
	}

	func setMode(_ mode: DeviceRewardsMode, for deviceId: String) {
		stationItems[deviceId]?.setMode(mode)
		refreshCurrentDevice(deviceId: deviceId, mode: mode)
	}
}

private extension RewardAnalyticsViewModel {
	func initialFetch(completion: VoidCallback? = nil) {
		Task { @MainActor in
			defer {
				completion?()
			}

			refreshSummaryRewards()

			if let firstDeviceId = devices.first?.id {
				refreshCurrentDevice(deviceId: firstDeviceId, mode: .week)
			}
		}
	}

	func updateState() {
		if devices.isEmpty {
			state = .empty(noStationsConfiguration)
		} else if devices.reduce(0, { $0 + ($1.rewards?.totalRewards ?? 0.0)}) == 0 {
			state = .noRewards
		} else {
			state = .content
		}
	}

	func refreshCurrentDevice(deviceId: String?, mode: DeviceRewardsMode) {
		guard let deviceId else {
			return
		}

		stationItems[deviceId]?.setStationError(false, failObject: nil)
		currentStationIdLoading = deviceId
		Task { @MainActor [weak self] in
			defer {
				currentStationIdLoading = nil
			}

			guard let result = await self?.getRewardsBreakdown(for: deviceId, mode: mode) else {
				return
			}

			let item = StationItem(mode: mode)
			self?.stationItems[deviceId] = item

			switch result {
				case .failure(let error):
					let info = error.uiInfo(description: LocalizableString.RewardAnalytics.tapToRetry.localized)
					let failObject = info.defaultFailObject(type: .rewardAnalytics,
															failMode: .retry) {
						self?.refreshCurrentDevice(deviceId: deviceId, mode: mode)
					}
					self?.stationItems[deviceId]?.setStationError(true, failObject: failObject)
				case .success(let response):
					self?.stationItems[deviceId]?.setReward(reward: response)
					let chartData = self?.getStationCharts(from: response, mode: self?.stationItems[deviceId]?.mode ?? .week)
					self?.stationItems[deviceId]?.setChartDataItems(chartData?.dataItems, legendItems: chartData?.legendItems)
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

	func getStationCharts(from reward: NetworkDeviceRewardsResponse, mode: DeviceRewardsMode) -> RewardAnalyticsChartFactory.ChartData {
		
		let data = RewardAnalyticsChartFactory().getChartsData(deviceResponse: reward,
															   mode: mode)
		return data
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

	func getRewardsBreakdown(for deviceId: String, mode: DeviceRewardsMode) async -> Result<NetworkDeviceRewardsResponse, NetworkErrorResponse>? {
		do {
			let  result = try await useCase.getUserDeviceRewards(deviceId: deviceId,
																 mode: mode).toAsync().result
			return result
		} catch {
			print(error)
			return nil
		}
	}
}

extension RewardAnalyticsViewModel {
	struct StationItem {
		var reward: NetworkDeviceRewardsResponse?
		var mode: DeviceRewardsMode = .week
		var chartDataItems: [ChartDataItem]?
		var legendItems: [ChartLegendView.Item]?
		var stationError: Bool = false
		var failObject: FailSuccessStateObject?

		mutating func setReward(reward: NetworkDeviceRewardsResponse?) {
			self.reward = reward
		}

		mutating func setMode(_ mode: DeviceRewardsMode) {
			self.mode = mode
		}

		mutating func setChartDataItems(_ dataItems: [ChartDataItem]?,
										legendItems: [ChartLegendView.Item]?) {
			self.chartDataItems = dataItems
			self.legendItems = legendItems
		}

		mutating func setStationError(_ stationError: Bool, failObject: FailSuccessStateObject?) {
			self.failObject = failObject
			self.stationError = stationError
		}
	}
}

extension RewardAnalyticsViewModel: HashableViewModel {
	func hash(into hasher: inout Hasher) {
		hasher.combine("\(devices.map { $0.id})")
	}
}
