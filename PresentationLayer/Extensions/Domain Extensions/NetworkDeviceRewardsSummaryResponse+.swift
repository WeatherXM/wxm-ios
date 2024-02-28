//
//  NetworkDeviceRewardsSummaryResponse+.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 20/2/24.
//

import DomainLayer

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
								 boostsReward: totalBoostReward,
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
