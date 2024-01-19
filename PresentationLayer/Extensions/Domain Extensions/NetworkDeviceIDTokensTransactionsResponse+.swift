//
//  NetworkDeviceIDTokensTransactionsResponse+.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 21/3/23.
//

import Foundation
import DomainLayer
import Toolkit

extension NetworkDeviceIDTokensTransactionsResponse {
    func actualRewardForLast(days: Int) -> Double {
        let now = Date.now
        guard let endDate = Calendar.current.date(byAdding: .day, value: -days, to: now) else {
            return 0.0
        }

        let dateRange = endDate...now
        let totalReward = data?.reduce(0.0) { $0 + ($1.timestamp!.stringToDate().isIn(range: dateRange) ? ($1.actualReward ?? 0.0) : 0.0)}

        return totalReward ?? 0.0
    }

    func rewardsPerDayForLast(days: Int) -> [Double] {
        let now = Date.now
        let dates = Array(0..<days).compactMap { Calendar.current.date(byAdding: .day, value: -$0, to: now) }.reversed()
        let rewards = dates.map { date in
            data?.filter { $0.timestamp?.stringToDate().isSameDay(with: date) == true }.reduce(0.0) { $0 + ($1.actualReward ?? 0.0) } ?? 0.0
        }

        return rewards
    }
}

extension Datum {
    var hexagonColor: ColorEnum {
		getHexagonColor(validationScore: Double(rewardScore ?? 0) / 100.0)
    }

    var validationScoreStr: String {
		let score = Double(rewardScore ?? 0) / 100.0
        let format = score == 0.0 ? "%.0f" : "%.2f"
        return String(format: format, score)
    }

    var actualRewardStr: String {
        let reward = actualReward ?? 0.0
        let format = reward == 0.0 ? "%.0f" : "%.2f"
        return String(format: format, reward)
    }
}

extension UITransaction {
    var hexagonColor: ColorEnum {
        getHexagonColor(validationScore: Double(rewardScore ?? 0) / 100.0)
    }

	var lostAmount: Double {
		guard let actualReward, let dailyReward else {
			return 0.0
		}

		return dailyReward - actualReward
	}

	var lostPercentage: Int {
		100 - (rewardScore ?? 0)
	}

	var lostAmountData: StationRewardsLostAmountData {
		let data = StationRewardsLostAmountData(value: lostAmount, percentage: lostPercentage)
		return data
	}

	var annotationsList: [DeviceAnnotation] {
		annotations?.getAnnotationsList(for: rewardScore ?? 0) ?? []
	}
}

func getHexagonColor(validationScore: Double?) -> ColorEnum {
    guard let validationScore else {
        return .reward_score_unknown
    }

    switch validationScore {
        case 0.0 ..< 0.2:
            return .reward_score_very_low
        case 0.2 ..< 0.4:
            return .reward_score_low
        case 0.4 ..< 0.6:
            return .reward_score_average
        case 0.6 ..< 0.8:
            return .reward_score_high
        case 0.8 ... 1.0:
            return .reward_score_very_high
        default:
            return .reward_score_unknown
    }
}
