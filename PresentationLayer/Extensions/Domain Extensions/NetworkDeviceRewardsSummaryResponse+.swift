//
//  NetworkDeviceRewardsSummaryResponse+.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 20/2/24.
//

import DomainLayer

extension NetworkDeviceRewardsSummary: Identifiable {
	public var id: Int {
		hashValue
	}

	var toDailyRewardCard: DailyRewardCardView.Card {
		DailyRewardCardView.Card(refDate: timestamp,
								 totalRewards: totalReward ?? 0.0,
								 baseReward: baseReward ?? 0.0,
								 baseRewardScore: Double(baseRewardScore ?? 0) / 100.0,
								 boostsReward: totalBoostReward)
	}

	var timelineTransactionDateString: String {
		timestamp?.transactionsDateFormat(timeZone: .UTCTimezone ?? .current) ?? ""
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

extension NetworkDeviceRewardsSummaryTimelineEntry {
	var toWeeklyEntry: WeeklyStreakView.Entry? {
		guard let timestamp else {
			return nil
		}
		return .init(timestamp: timestamp, value: baseRewardScore ?? 0)
	}
}


extension Array where Element == NetworkDeviceRewardsSummaryTimelineEntry {
	var toWeeklyEntries: [WeeklyStreakView.Entry] {
		compactMap { $0.toWeeklyEntry }
	}
}
