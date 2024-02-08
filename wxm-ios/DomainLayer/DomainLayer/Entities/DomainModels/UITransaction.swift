//
//  UITransaction.swift
//  DomainLayer
//
//  Created by Lampros Zouloumis on 13/9/22.
//

public struct UITransaction: Identifiable, Hashable, Equatable {
	public var id: Int {
		hashValue
	}
    public let formattedDate: String
    public let sortDate: Date
    public let formattedTimestamp: String
	public let lostRewards: Double?
    public let rewardScore: Int?
    public let dailyReward: Double?
    public let actualReward: Double?
	public let datum: Datum?

    public static func == (left: UITransaction, right: UITransaction) -> Bool {
        return left.id == right.id
    }

	public static func generate(from datum: Datum) -> UITransaction {
		let timestamp = datum.timestamp?.timestampToDate() ?? .distantPast
		return UITransactionBuilder()
			.withFormattedDate(timestamp)
			.withFormattedTimestamp(timestamp)
			.withLostRewards(datum.lostRewards)
			.withRewardScore(datum.rewardScore)
			.withDailyReward(datum.dailyReward)
			.withActualReward(datum.actualReward)
			.withDatum(datum)
			.build()
	}
}

public class UITransactionBuilder {
    public private(set) var formattedDate: String = ""
    public private(set) var formattedTimestamp: String = ""
    public private(set) var sortDate: Date = .distantPast
	public private(set) var lostRewards: Double?
    public private(set) var rewardScore: Int?
    public private(set) var dailyReward: Double?
    public private(set) var actualReward: Double?   
	public private(set) var annotations: DeviceAnnotations?
	public private(set) var datum: Datum?

    public func withFormattedDate(_ formattedDate: Date) -> Self {
		self.formattedDate = formattedDate.transactionsDateFormat(timeZone: .UTCTimezone ?? .current)
        sortDate = formattedDate
        return self
    }

    public func withFormattedTimestamp(_ timestamp: Date) -> Self {
		formattedTimestamp = timestamp.getFormattedDate(format: .monthLiteralDayTime,
														timezone: .UTCTimezone,
														showTimeZoneIndication: true).capitalizedSentence
        return self
    }

    public func withRewardScore(_ rewardScore: Int?) -> Self {
        self.rewardScore = rewardScore
        return self
    }

    public func withDailyReward(_ dailyReward: Double?) -> Self {
        self.dailyReward = dailyReward
        return self
    }

    public func withActualReward(_ actualReward: Double?) -> Self {
        self.actualReward = actualReward
        return self
    }

	public func withLostRewards(_ lostRewards: Double?) -> Self {
		self.lostRewards = lostRewards
		return self
	}

	public func withDatum(_ datum: Datum) -> Self {
		self.datum = datum
		return self
	}

    public func build() -> UITransaction {
		UITransaction(formattedDate: formattedDate,
					  sortDate: sortDate,
					  formattedTimestamp: formattedTimestamp,
					  lostRewards: lostRewards,
					  rewardScore: rewardScore,
					  dailyReward: dailyReward,
					  actualReward: actualReward,
					  datum: datum)
    }
}
