//
//  NetworkDeviceRewardsSummaryResponse+.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 20/2/24.
//

import DomainLayer
import UIKit
import Toolkit

extension NetworkDeviceRewardsSummaryResponse {
	var isEmpty: Bool {
		latest == nil &&
		timeline == nil &&
		totalRewards == 0.0
	}
}

extension NetworkDeviceRewardsSummary: Identifiable {
	public var id: Int {
		hashValue
	}

	func toDailyRewardCard(isOwned: Bool) -> DailyRewardCardView.Card {
		DailyRewardCardView.Card(refDate: timestamp,
								 totalRewards: totalReward ?? 0.0,
								 baseReward: baseReward ?? 0.0,
								 baseRewardScore: Double(baseRewardScore ?? 0) / 100.0,
								 baseRewardFontIcon: (baseRewardScore ?? 0).rewardScoreFontIcon,
								 baseRewardColor: (baseRewardScore ?? 0).rewardScoreColor,
								 boostsReward: totalBoostReward,
								 boostsFontIcon: boostFontIcon,
								 boostsColor: boostFontColor,
								 warningType: warningType,
								 issues: annotationSummary?.count ?? 0,
								 isOwned: isOwned)
	}

	var timelineTransactionDateString: String {
		timestamp?.transactionsDateFormat(timeZone: .UTCTimezone ?? .current) ?? ""
	}

	private var warningType: CardWarningType? {
		guard let annotationSummary else {
			return nil
		}

		if annotationSummary.contains(where: { $0.severity == .error }) {
			return .error
		} else if annotationSummary.contains(where: { $0.severity == .warning }) {
			return .warning
		} else if annotationSummary.contains(where: { $0.severity == .info }) {
			return .info
		}

		return nil
	}

	private var boostFontIcon: FontIcon {
		guard let totalBoostReward else {
			return .hexagonXmark
		}

		return .hexagonCheck
	}

	private var boostFontColor: ColorEnum {
		guard totalBoostReward != nil else {
			return .midGrey
		}

		return .chartPrimary
	}

	static var mock: Self {
		.init(timestamp: .now,
			  baseReward: 3.454353,
			  totalBoostReward: 1.345235,
			  totalReward: 5.3432423,
			  baseRewardScore: 87,
			  annotationSummary: nil)
	}
}

extension RewardAnnotation {
	var warningType: CardWarningType? {
		guard let severity else {
			return nil
		}

		switch severity {
			case .info:
				return .info
			case .warning:
				return .warning
			case .error:
				return .error
		}
	}

	func annotationActionButtonTile(with followState: UserDeviceFollowState?) -> String? {
		guard let group else {
			return nil
		}

		let isOwned = followState?.relation == .owned
		switch group {
			case .noWallet:
				if MainScreenViewModel.shared.isWalletMissing, isOwned {
					return LocalizableString.RewardDetails.noWalletProblemButtonTitle.localized
				} else if docUrl != nil {
					return LocalizableString.RewardDetails.readMore.localized
				}
				return nil
			case .locationNotVerified:
				if isOwned {
					return LocalizableString.RewardDetails.editLocation.localized
				} else if docUrl != nil {
					return LocalizableString.RewardDetails.readMore.localized
				}
				return nil
			default:
				if docUrl != nil {
					return LocalizableString.RewardDetails.readMore.localized
				}
				return nil
		}
	}

	func handleRewardAnnotationTap(with device: DeviceDetails, followState: UserDeviceFollowState?) {
		guard let group else {
			return
		}
		
		let isOwned = followState?.relation == .owned

		switch group {
			case .noWallet:
				if MainScreenViewModel.shared.isWalletMissing, isOwned {
					Router.shared.navigateTo(.wallet(ViewModelsFactory.getMyWalletViewModel()))
				} else if let docUrl,
				   let url = URL(string: docUrl) {
					UIApplication.shared.open(url)

					WXMAnalytics.shared.trackEvent(.selectContent, parameters: [.contentType: .webDocumentation,
																		  .itemId: .custom(docUrl)])
				}
			case .locationNotVerified:
				if isOwned {
					let viewModel = ViewModelsFactory.getSelectLocationViewModel(device: device,
																				 followState: followState,
																				 delegate: nil)
					Router.shared.navigateTo(.selectStationLocation(viewModel))
				} else if let docUrl,
						  let url = URL(string: docUrl) {
					 UIApplication.shared.open(url)

					WXMAnalytics.shared.trackEvent(.selectContent, parameters: [.contentType: .webDocumentation,
																		  .itemId: .custom(docUrl)])
				 }
			default:
				if let docUrl,
				   let url = URL(string: docUrl) {
					UIApplication.shared.open(url)

					WXMAnalytics.shared.trackEvent(.selectContent, parameters: [.contentType: .webDocumentation,
																		  .itemId: .custom(docUrl)])
				}
		}
	}
}

extension NetworkDeviceRewardsSummaryTimelineEntry {
	var toWeeklyEntry: WeeklyStreakView.Entry? {
		guard let timestamp else {
			return nil
		}
		return .init(timestamp: timestamp,
					 value: baseRewardScore,
					 color: (baseRewardScore ?? 0).rewardScoreColor)
	}
}


extension Array where Element == NetworkDeviceRewardsSummaryTimelineEntry {
	var toWeeklyEntries: [WeeklyStreakView.Entry] {
		compactMap { $0.toWeeklyEntry }
	}
}
