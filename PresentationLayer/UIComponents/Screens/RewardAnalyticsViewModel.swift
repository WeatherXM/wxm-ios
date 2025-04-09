//
//  RewardAnalyticsViewModel.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 2/9/24.
//

import Foundation
import DomainLayer
import Toolkit
@preconcurrency import Combine

@MainActor
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
	@Published var stationItems: [String: StationCardItem]

	@Published var state: RewardAnalyticsView.State = .noRewards
	private lazy var noStationsConfiguration: WXMEmptyView.Configuration = {
		WXMEmptyView.Configuration(imageFontIcon: (.faceSadCry, .FAProLight),
								   title: LocalizableString.RewardAnalytics.emptyStateTitle.localized,
								   description: LocalizableString.RewardAnalytics.emptyStateDescription.localized.attributedMarkdown,
								   buttonFontIcon: (.cart, .FAProSolid),
								   buttonTitle: LocalizableString.Profile.noRewardsWarningButtonTitle.localized) {
			LinkNavigationHelper().openUrl(DisplayedLinks.shopLink.linkURL)
		}
	}()

	private let useCase: MeUseCaseApi
	private var cancellableSet = Set<AnyCancellable>()

	init(useCase: MeUseCaseApi, devices: [DeviceDetails]) {
		self.useCase = useCase
		self.devices = devices
		self.stationItems = devices.reduce(into: [:]) { $0[$1.id ?? ""] = StationCardItem() }
		updateState()

		initialFetch()
	}

	func handleDeviceTap(_ device: DeviceDetails, completion: VoidCallback? = nil) {
		let isExpanded = stationItems[device.id ?? ""]?.isExpanded == true
		let state: ParameterValue = isExpanded ? .closeState : .openState
		WXMAnalytics.shared.trackEvent(.selectContent, parameters: [.contentType: .deviceRewardsCard,
																	.state: state])

		guard isExpanded else {
			stationItems[device.id ?? ""]?.setIsExpanded(true)
			refreshCurrentDevice(deviceId: device.id, mode: .week, completion: completion)
			return
		}
		
		stationItems[device.id ?? ""] = StationCardItem()
		completion?()
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

	func refreshCurrentDevice(deviceId: String?, mode: DeviceRewardsMode, completion: VoidCallback? = nil) {
		guard let deviceId else {
			return
		}

		stationItems[deviceId]?.isLoading = true
		Task { @MainActor [weak self] in
			defer {
				self?.stationItems[deviceId]?.isLoading = false
				self?.stationItems[deviceId]?.setIsExpanded(true)
				completion?()
			}

			guard let result = await self?.getRewardsBreakdown(for: deviceId, mode: mode) else {
				return
			}

			switch result {
				case .failure(let error):
					let info = error.uiInfo(description: LocalizableString.RewardAnalytics.tapToRetry.localized)
					let failObject = info.defaultFailObject(type: .rewardAnalytics,
															failMode: .retry) {
						self?.refreshCurrentDevice(deviceId: deviceId, mode: mode)
					}
					
					self?.stationItems[deviceId]?.setReward(reward: nil)
					self?.stationItems[deviceId]?.setStationError(true,
																  failObject: failObject)
					self?.stationItems[deviceId]?.setChartDataItems(nil,
																	legendItems: nil)
				case .success(let response):
					self?.stationItems[deviceId]?.setReward(reward: response)
					let chartData = self?.getStationCharts(from: response,
														   mode: self?.stationItems[deviceId]?.mode ?? .week)
					self?.stationItems[deviceId]?.setChartDataItems(chartData?.dataItems,
																	legendItems: chartData?.legendItems)
			}
		}
	}

	func refreshSummaryRewards() {
		suammaryRewardsIsLoading = true
		Task { @MainActor [weak self] in
			defer {
				self?.suammaryRewardsIsLoading = false
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
					self?.showSummaryError = false
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
	struct StationCardItem {
		var reward: NetworkDeviceRewardsResponse?
		var mode: DeviceRewardsMode = .week
		var chartDataItems: [ChartDataItem]?
		var legendItems: [ChartLegendView.Item]?
		var stationError: Bool = false
		var failObject: FailSuccessStateObject?
		var isLoading: Bool = false
		var isExpanded: Bool = false

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

		mutating func setIsLoading(_ isLoading: Bool) {
			self.isLoading = isLoading
		}

		mutating func setIsExpanded(_ isExpanded: Bool) {
			self.isExpanded = isExpanded
		}
	}
}

extension RewardAnalyticsViewModel: HashableViewModel {
	nonisolated func hash(into hasher: inout Hasher) {
		hasher.combine("\(devices.map { $0.id})")
	}
}
