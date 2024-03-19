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

extension RewardAnnotation.Severity: Comparable {
	public static func < (lhs: RewardAnnotation.Severity, rhs: RewardAnnotation.Severity) -> Bool {
		lhs.sortOrder < rhs.sortOrder
	}

	private var sortOrder: Int {
		switch self {
			case .info:
				2
			case .warning:
				1
			case .error:
				0
		}
	}

	var toCardWarningType: CardWarningType {
		switch self {
			case .info:
				CardWarningType.info
			case .warning:
				CardWarningType.warning
			case .error:
				CardWarningType.error
		}
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
