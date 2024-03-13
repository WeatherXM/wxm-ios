//
//  NetworkDeviceRewardDetailsResponse+.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 28/2/24.
//

import Foundation
import DomainLayer

extension NetworkDeviceRewardDetailsResponse {
	var mainAnnotation: RewardAnnotation? {
		if let annotation = annotations?.first(where: { $0.severity == .error }) {
			return annotation
		} else if let annotation = annotations?.first(where: { $0.severity == .warning }) {
			return annotation
		} else if let annotation = annotations?.first(where: { $0.severity == .info }) {
			return annotation
		}

		return nil
	}
}

extension NetworkDeviceRewardDetailsResponse {
	func dataQualityScoreObject(followState: UserDeviceFollowState?) -> RewardFieldView.Score {
		.init(fontIcon: dataQualityfontIcon,
			  score: Float(base?.rewardScore ?? 0),
			  color: dataQualityColor,
			  message: dataQualityMessage(followState: followState),
			  showIndication: dataQualityColor != .success )
	}

	private func dataQualityMessage(followState: UserDeviceFollowState?) -> String {
		guard let rewardScore = base?.rewardScore else {
			return LocalizableString.RewardDetails.dataQualityNoInfoMessage.localized
		}

		switch rewardScore {
			case 0:
				return LocalizableString.RewardDetails.dataQualityNoInfoMessage.localized
			case 0..<20:
				if followState?.relation == .owned {
					return LocalizableString.RewardDetails.dataQualityVeryLowMessage(rewardScore).localized
				}
				return LocalizableString.RewardDetails.dataQualityPublicVeryLowMessage(rewardScore).localized
			case 20..<40:
				if followState?.relation == .owned {
					return LocalizableString.RewardDetails.dataQualityLowMessage(rewardScore).localized
				}
				return LocalizableString.RewardDetails.dataQualityPublicLowMessage(rewardScore).localized
			case 40..<60:
				if followState?.relation == .owned {
					return LocalizableString.RewardDetails.dataQualityAverageMessage(rewardScore).localized
				}
				return LocalizableString.RewardDetails.dataQualityPublicAverageMessage(rewardScore).localized
			case 60..<80:
				if followState?.relation == .owned {
					return LocalizableString.RewardDetails.dataQualityOkMessage(rewardScore).localized
				}
				return LocalizableString.RewardDetails.dataQualityPublicOkMessage(rewardScore).localized
			case 80..<95:
				if followState?.relation == .owned {
					return LocalizableString.RewardDetails.dataQualityGreatMessage(rewardScore).localized
				}
				return LocalizableString.RewardDetails.dataQualityPublicGreatMessage(rewardScore).localized
			case 95..<100:
				return LocalizableString.RewardDetails.dataQualityAlmostPerfectMessage(rewardScore).localized
			case 100:
				return LocalizableString.RewardDetails.dataQualitySolidMessage(rewardScore).localized
			default:
				return LocalizableString.RewardDetails.dataQualityNoInfoMessage.localized
		}
	}


	private var dataQualityColor: ColorEnum {
		guard let rewardScore = base?.rewardScore else {
			return .clear
		}

		switch rewardScore {
			case 0..<10:
				return .error
			case 10..<95:
				return .warning
			case 95...100:
				return .success
			default:
				return .clear
		}
	}

	private var dataQualityfontIcon: FontIcon {
		guard let rewardScore = base?.rewardScore else {
			return .hexagonExclamation
		}

		switch rewardScore {
			case 0..<10:
				return .hexagonXmark
			case 10..<95:
				return .hexagonExclamation
			case 95...100:
				return .hexagonCheck
			default:
				return .hexagonExclamation
		}
	}

}

extension NetworkDeviceRewardDetailsResponse {
	var locationQualityScoreObject: RewardFieldView.Score {
		.init(fontIcon: locationQualityFontIcon,
			  score: nil,
			  color: locationQualityColor,
			  message: locationQualityMessage,
			  showIndication: locationQualityColor != .success)
	}

	private var locationQualityFontIcon: FontIcon {
		guard let summary = annotations?.first(where: { $0.group == .locationNotVerified || $0.group == .noLocationData || $0.group == .userRelocationPenalty }),
			  let severity = summary.severity else {
			return .hexagonCheck
		}

		switch severity {
			case .info:
				return .hexagonCheck
			case .warning:
				return .hexagonExclamation
			case .error:
				return .hexagonXmark
		}
	}

	private var locationQualityColor: ColorEnum {
		guard let summary = annotations?.first(where: { $0.group == .locationNotVerified || $0.group == .noLocationData || $0.group == .userRelocationPenalty }),
			  let severity = summary.severity else {
			return .success
		}

		switch severity {
			case .info:
				return .success
			case .warning:
				return .warning
			case .error:
				return .error
		}
	}

	private var locationQualityMessage: String {
		if annotations?.first(where: { $0.group == .locationNotVerified }) != nil {
			return LocalizableString.RewardDetails.locationNotVerified.localized
		}

		if annotations?.first(where: { $0.group == .noLocationData }) != nil {
			return LocalizableString.RewardDetails.noLocationData.localized
		}

		if annotations?.first(where: { $0.group == .userRelocationPenalty }) != nil {
			return LocalizableString.RewardDetails.recentlyRelocated.localized
		}

		return LocalizableString.RewardDetails.locationVerified.localized
	}
}

extension NetworkDeviceRewardDetailsResponse {
	var cellPositionScoreObject: RewardFieldView.Score {
		.init(fontIcon: cellPositionFontIcon,
			  score: nil,
			  color: cellPositionColor,
			  message: cellPositionMessage,
			  showIndication: cellPositionColor != .success)
	}

	private var cellPositionFontIcon: FontIcon {
		guard let severity = annotations?.first(where: { $0.group == .cellCapacityReached })?.severity else {
			return .hexagonCheck
		}

		switch severity {
			case .info:
				return .hexagonCheck
			case .warning:
				return .hexagonExclamation
			case .error:
				return .hexagonXmark
		}
	}

	private var cellPositionColor: ColorEnum {
		guard let severity = annotations?.first(where: { $0.group == .cellCapacityReached })?.severity else {
			return .success
		}

		switch severity {
			case .info:
				return .success
			case .warning:
				return .warning
			case .error:
				return .error
		}
	}

	private var cellPositionMessage: String {
		guard let annotation = annotations?.first(where: { $0.group == .cellCapacityReached }) else {
			return LocalizableString.RewardDetails.cellPositionSuccessMessage.localized
		}

		return annotation.message ?? ""
	}
}

extension NetworkDeviceRewardDetailsResponse.BoostReward {
	static var mock: NetworkDeviceRewardDetailsResponse.BoostReward {
		.init(code: .betaReward,
			  title: "Beta Reward",
			  description: "Beta Reward Description",
			  imageUrl: "https://s3-alpha-sig.figma.com/img/eb97/5518/24aa70629514355d092dfc646d9b51bd?Expires=1710720000&Key-Pair-Id=APKAQ4GOSFWCVNEHN3O4&Signature=OVc-UV-lBgXfX~Nl1VFoL-JijJx72Wld-L40tKQBLBo2afCyJijAJWkRicakQ~celi0ACIuP8W~N2Ixev1roqtO9JAl2IW0u55fOQdITuhDYq0pcqW-Nen7vzvATzti9A-c-pm6IDE37Md7gc0dYgnM55HhR1GAM4FlEIx4~RWOYmOI5rOgXQl6wN7YCB1gv3WI3JvmA1YgZKxLoei0Adny6PVGOlmQYXacN3WMcy6EfPFUO4rVvk~lrgQIOBJi8bSOnVX8RFHZ0RMW9lPljynCPKgbpuwUl0X6djRmdku-ntEnlCCsFp0LF0d~Y-qEK-edLpT96KdG4MM7TS64Qsg__",
			  docUrl: nil,
			  actualReward: 0.2442141,
			  rewardScore: nil,
			  maxReward: 1.0)
	}

	func toBoostViewObject(with date: Date?) -> BoostCardView.Boost {
		.init(title: title ?? "",
			  reward: actualReward ?? 0.0,
			  date: date,
			  score: rewardScore ?? 0,
			  lostRewardString: lostRewardString,
			  imageUrl: imageUrl)
	}

	private var lostRewardString: String {
		let lostAmount = ((maxReward ?? 0.0) - (actualReward ?? 0.0)).toWXMTokenPrecisionString
		switch code {
			case .betaReward:
				return LocalizableString.Boosts.lostTokensBecauseOfQod(lostAmount).localized
			default:
				return LocalizableString.Boosts.lostTokens(lostAmount).localized
		}
	}
}
