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
	
	@Published var overallResponse: NetworkDevicesRewardsResponse?
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
}

extension RewardAnalyticsViewModel: HashableViewModel {
	func hash(into hasher: inout Hasher) {
		hasher.combine("\(devices.map { $0.id})")
	}
}
