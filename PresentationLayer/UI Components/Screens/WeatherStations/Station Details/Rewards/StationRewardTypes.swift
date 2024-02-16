//
//  StationRewardTypes.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 25/10/23.
//

import Foundation
import Charts
import UIKit
import Toolkit
import DomainLayer

struct StationRewardsCardOverview: Hashable {
	let title: String
	let date: Date?
	let fromDate: Date?
	let toDate: Date?
	let actualReward: Double
	let lostPercentage: Int
	let lostAmount: Double
	let rewardScore: Int?
	let maxRewards: Double?
	let annnotationsList: [RewardAnnotation]
	let timelineEntries: [Int]?
	let timelineAxis: [String]?
	let timelineCaption: String?
	let errorButtonTitle: String

	var lostAmountData: StationRewardsLostAmountData {
		let data = StationRewardsLostAmountData(value: lostAmount, percentage: lostPercentage)
		return data
	}

	static func mock(title: String) -> Self {
		StationRewardsCardOverview(title: title,
								   date: nil,
								   fromDate: .now,
								   toDate: .now.advancedByDays(days: 5),
								   actualReward: 3784.32,
								   lostPercentage: 0,
								   lostAmount: 0.0,
								   rewardScore: nil,
								   maxRewards: nil,
								   annnotationsList: [.init(severity: .error, group: .noWallet, title: "This is a title", message: "This is a message", docUrl: "https://docs.weatherxm.com/faqs")],
								   timelineEntries: [],
								   timelineAxis: [],
								   timelineCaption: "Timeline for yesterday",
								   errorButtonTitle: LocalizableString.StationDetails.rewardsErrorButtonTitle.localized)
	}
}

struct StationRewardsLostAmountData {
	let value: Double
	let percentage: Int
	var fontIcon: FontIcon!
	var iconColor: ColorEnum!
	var tintColor: ColorEnum!
	var problemsViewBackground: ColorEnum!
	var problemsViewBorder: ColorEnum!
	var cardWarningType: CardWarningType {
		switch percentage {
			case let val where val > lostRewardsThreshold:
				return .error
			default:
				return .warning
		}
	}

	/// The threshold to change error color from `warning` to `error`
	/// If  <=30 warning (user claimed more than 70% of available tokens)
	/// If  >30 error (user claimed less than 70% of available tokens)
	private let lostRewardsThreshold = 30

	init(value: Double, percentage: Int) {
		self.value = value
		self.percentage = percentage
		self.fontIcon = getFontIcon(percentage: percentage)
		self.iconColor = getIconColor(percentage: percentage)
		self.tintColor = getTintColor(percentage: percentage)
		self.problemsViewBackground = getProblemsViewColor(percentage: percentage)
		self.problemsViewBorder = getProblemsViewBorderColor(percentage: percentage)
	}

	private func getFontIcon(percentage: Int) -> FontIcon {
		let lostWxm = percentage > 0
		let fontIcon: FontIcon = lostWxm ? .triangleExclamation : .badgeCheck
		return fontIcon
	}

	private func getIconColor(percentage: Int) -> ColorEnum {
		switch percentage {
			case let val where val == 0:
				return .darkestBlue
			case let val where val > lostRewardsThreshold:
				return .error
			case let val where val <= lostRewardsThreshold:
				return .warning
			default:
				return .success
		}
	}

	private func getTintColor(percentage: Int) -> ColorEnum {
		switch percentage {
			case let val where val == 0:
				return .successTint
			case let val where val > lostRewardsThreshold:
				return .errorTint
			case let val where val <= lostRewardsThreshold:
				return .warningTint
			default:
				return .successTint
		}
	}

	private func getProblemsViewBorderColor(percentage: Int) -> ColorEnum {
		switch percentage {
			case let val where val > lostRewardsThreshold:
				return .error
			case let val where val <= lostRewardsThreshold:
				return .warning
			default:
				return .success
		}
	}

	private func getProblemsViewColor(percentage: Int) -> ColorEnum {
		switch percentage {
			case let val where val > lostRewardsThreshold:
				return .errorTint
			case let val where val <= lostRewardsThreshold:
				return .warningTint
			default:
				return .successTint
		}
	}
}

/// The actions to be called
struct RewardsOverviewButtonActions {
	typealias Info = (title: String?, description: String)
	let rewardsScoreInfoAction: VoidCallback
	let dailyMaxInfoAction: VoidCallback
	let timelineInfoAction: VoidCallback
	let errorButtonAction: VoidCallback

	static let rewardsScoreInfo: Info = (LocalizableString.RewardDetails.rewardScoreInfoTitle.localized,
										 LocalizableString.RewardDetails.rewardScoreInfoDescription(DisplayedLinks.rewardMechanism.linkURL).localized)
	static let dailyMaxInfo: Info = (LocalizableString.RewardDetails.maxRewardsInfoTitle.localized,
									 LocalizableString.RewardDetails.maxRewardsInfoDescription(DisplayedLinks.rewardMechanism.linkURL).localized)
	static func timelineInfo(timezoneOffset: String?) -> Info {
		(LocalizableString.RewardDetails.timelineInfoTitle.localized,
		 LocalizableString.RewardDetails.timelineInfoDescription(timezoneOffset, DisplayedLinks.rewardMechanism.linkURL).localized)
	}
}
