//
//  DeviceRewardsOverview+.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 27/10/23.
//

import Foundation
import DomainLayer
import Toolkit

extension RewardAnnotation: Identifiable {
	public var id: Int {
		hashValue
	}
}

extension DeviceAnnotations {
	func getAnnotationsList(for rewardScore: Int) -> [DeviceAnnotation] {
		var showQod = true
		if let threshold = RemoteConfigManager.shared.rewardsHideAnnotationThreshold {
			showQod = rewardScore < threshold
		}

		let qod = showQod ? self.qod : []
		return [qod, pol, rm].compactMap { $0 }.flatMap { $0 }.compactMap { $0.annotation != nil ? $0 : nil }
	}
}

extension DeviceRewardsOverview {
	func toRewardsCardOverview(title: String, errorButtonTitle: String) -> StationRewardsCardOverview {
		StationRewardsCardOverview(title: title,
								   date: timestamp,
								   fromDate: fromDate,
								   toDate: toDate,
								   actualReward: actualReward ?? 0.0,
								   lostPercentage: lostPercentage,
								   lostAmount: lostAmount,
								   rewardScore: rewardScore,
								   maxRewards: periodMaxReward,
								   annnotationsList: rewardAnnotations ?? [],
								   timelineEntries: timeline?.rewardScores,
								   timelineAxis: timelineAxis,
								   timelineCaption: timelineCaption,
								   errorButtonTitle: errorButtonTitle)
	}

	var annotationsList: [DeviceAnnotation] {
		annotations?.getAnnotationsList(for: rewardScore ?? 0) ?? []
	}

	var lostPercentage: Int {
		100 - (rewardScore ?? 0)
	}

	var lostAmount: Double {
		guard let periodMaxReward, let actualReward else {
			return 0.0
		}

		return periodMaxReward - actualReward
	}

	var dateString: String? {
		guard let timestamp else {
			return timelineDateRangeString
		}

		return timestamp.getFormattedDate(format: .monthLiteralDayTime, relativeFormat: true).localizedCapitalized
	}

	var timelineAxis: [String]? {
		guard let from = fromDate?.getFormattedDate(format: .monthLiteralDay, timezone: .UTCTimezone).localizedCapitalized,
			  let to = toDate?.getFormattedDate(format: .monthLiteralDay, timezone: .UTCTimezone).localizedCapitalized else {
			if let refDate = timeline?.referenceDate,
			   let middleOfDay = refDate.middleOfDay,
			   let endOfDay = refDate.setHour(23) {
				let begin = refDate.startOfDay()
				return [begin.transactionsTimeFormat(), middleOfDay.transactionsTimeFormat(), endOfDay.transactionsTimeFormat()]
			}

			return nil
		}

		return [from, to]
	}

	var timelineCaption: String? {
		guard let timestamp = timeline?.referenceDate else {
			return timelineDateRangeCaption
		}

		let val = timestamp.getFormattedDate(format: .monthLiteralDayYearShort, timezone: TimeZone.UTCTimezone).localizedCapitalized
		let relativeDay = timestamp.relativeDayStringIfExists(timezone: TimeZone.UTCTimezone ?? .current) ?? ""
		let comma = relativeDay.isEmpty ? "" : ", "
		let valueString = "\(relativeDay)\(comma)\(val)"
		return LocalizableString.StationDetails.rewardsTimelineCaption(valueString).localized
	}

	private var timelineDateRangeCaption: String? {
		guard let fromDate = fromDate, let toDate = toDate else {
			return nil
		}

		let from = fromDate.getFormattedDate(format: .monthLiteralDay,
											 relativeFormat: false,
											 timezone: .UTCTimezone).capitalizedSentence

		let to = toDate.getFormattedDate(format: .monthLiteralDay,
										 relativeFormat: false,
										 timezone: .UTCTimezone).capitalizedSentence

		let rangeString = from + " - " + to

		return LocalizableString.StationDetails.rewardsTimelineCaption(rangeString).localized
	}

	private var timelineDateRangeString: String? {
		guard let from = fromDate?.getFormattedDate(format: .fullMonthLiteralDay).localizedCapitalized,
			  let to = toDate?.getFormattedDate(format: .fullMonthLiteralDay).localizedCapitalized else {
			return nil
		}

		return "\(from) - \(to)"
	}
}

extension DeviceAnnotation {

	var affectedFieldsListString: String {
		guard let affectedFields: [String] = affects?.compactMap({ $0.parameter?.displayTitle.lowercased() }), !affectedFields.isEmpty else {
			return ""
		}

		return "(\(affectedFields.joined(separator: ", ")))"
	}

	var title: String {
		guard let annotation else {
			return ""
		}

		switch annotation {
			case .obc:
				return LocalizableString.Error.obcTitle.localized
			case .spikes:
				return LocalizableString.Error.spikesTitle.localized
			case .unidentifiedSpike:
				return LocalizableString.Error.unidentifiedSpikeTitle.localized
			case .noMedian:
				return LocalizableString.Error.noMedianTitle.localized
			case .noData:
				return LocalizableString.Error.noDataTitle.localized
			case .shortConst:
				return LocalizableString.Error.shortConstTitle.localized
			case .longConst:
				return LocalizableString.Error.longConstTitle.localized
			case .frozenSensor:
				return LocalizableString.Error.frozenSensorTitle.localized
			case .anomIncrease:
				return LocalizableString.Error.anomIncreaseTitle.localized
			case .unidentifiedAnomalousChange:
				return LocalizableString.Error.unidentifiedAnomalousChangeTitle.localized
			case .locationNotVerified:
				return LocalizableString.Error.locationNotVerifiedTitle.localized
			case .noLocationData:
				return LocalizableString.Error.noLocationDataTitle.localized
			case .noWallet:
				return LocalizableString.Error.noWalletTitle.localized
			case .relocated:
				return LocalizableString.Error.relocatedTitle.localized
			case .cellCapacityReached:
				return LocalizableString.Error.cellCapacityReachedTitle.localized
			case .polThresholdNotReached:
				return LocalizableString.Error.polThresholdNotReachedTitle.localized
			case .qodThresholdNotReached:
				return LocalizableString.Error.qodThresholdNotReachedTitle.localized
			case .unknown:
				return LocalizableString.Error.unknownTitle.localized
		}
	}

	public func dercription(for profile: Profile?, followState: UserDeviceFollowState?) -> String {
		guard let annotation else {
			return ""
		}

		switch annotation {
			case .obc:
				return LocalizableString.Error.obcDescription(affectedFieldsListString).localized
			case .spikes:
				if followState?.relation == .owned {
					return LocalizableString.Error.spikesDescription(affectedFieldsListString).localized
				}

				return LocalizableString.Error.unownedSpikesDescription(affectedFieldsListString).localized
			case .unidentifiedSpike:
				if followState?.relation == .owned {
					return LocalizableString.Error.unidentifiedSpikeDescription(affectedFieldsListString).localized
				}

				return LocalizableString.Error.unownedUnidentifiedSpikeDescription(affectedFieldsListString).localized
			case .noMedian:
				if followState?.relation == .owned {
					return LocalizableString.Error.noMedianDescription.localized
				}
					
				return LocalizableString.Error.unownedNoMedianDescription.localized
			case .noData:
				if followState?.relation == .owned {
					return LocalizableString.Error.noDataDescription.localized
				}
					
				return LocalizableString.Error.unownedNoDataDescription.localized
			case .shortConst:
				if followState?.relation == .owned {
					return LocalizableString.Error.shortConstDescription(affectedFieldsListString).localized
				}

				return LocalizableString.Error.unownedShortConstDescription(affectedFieldsListString).localized
			case .longConst:
				if followState?.relation == .owned {
					return LocalizableString.Error.longConstDescription(affectedFieldsListString).localized
				}

				return LocalizableString.Error.unownedLongConstDescription(affectedFieldsListString).localized
			case .frozenSensor:
				return LocalizableString.Error.frozenSensorDescription.localized
			case .anomIncrease:
				if followState?.relation == .owned {
					return LocalizableString.Error.anomIncreaseDescription(affectedFieldsListString).localized
				}
					
				return LocalizableString.Error.unownedAnomIncreaseDescription(affectedFieldsListString).localized
			case .unidentifiedAnomalousChange:
				if followState?.relation == .owned {
					return LocalizableString.Error.unidentifiedAnomalousChangeDescription(affectedFieldsListString).localized
				}

				return LocalizableString.Error.unownedUnidentifiedAnomalousChangeDescription(affectedFieldsListString).localized

			case .locationNotVerified:
				guard followState?.relation == .owned else {
					return LocalizableString.Error.locationNotVerifiedDescription.localized
				}

				return LocalizableString.Error.locationNotVerifiedDescription.localized
			case .noLocationData:
				guard followState?.relation == .owned else {
					return LocalizableString.Error.unownedNoLocationDataDescription.localized
				}

				let polLink = DisplayedLinks.polAlgorithm.linkURL
				switch profile {
					case .m5:
						return LocalizableString.Error.noLocationDataM5Description.localized
					case .helium:
						return LocalizableString.Error.noLocationDataHeliumDescription.localized
					case nil:
						return LocalizableString.Error.noLocationDataM5Description.localized
				}
			case .noWallet:
				if followState?.relation == .owned {
					return LocalizableString.Error.noWalletDescription.localized
				}

				return LocalizableString.Error.unownedNoWalletDescription.localized
			case .cellCapacityReached:
				if followState?.relation == .owned {
					return LocalizableString.Error.cellCapacityReachedDescription.localized
				}

				return LocalizableString.Error.unownedCellCapacityReachedDescription.localized
			case .polThresholdNotReached:
				if followState?.relation == .owned {
					return LocalizableString.Error.polThresholdNotReachedDescription.localized
				}

				return LocalizableString.Error.unownedPolThresholdNotReachedDescription.localized
			case .qodThresholdNotReached:
				if followState?.relation == .owned {
					return LocalizableString.Error.qodThresholdNotReachedDescription.localized
				}

				return LocalizableString.Error.unownedQodThresholdNotReachedDescription.localized
			case .relocated:
				return LocalizableString.Error.relocatedDescription.localized
			case .unknown:
				if followState?.relation == .owned {
					return LocalizableString.Error.unknownDescription.localized
				}

				return LocalizableString.Error.unownedUnknownDescription.localized
		}
	}
}
