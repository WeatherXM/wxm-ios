//
//  BaseRewardsCard.swift
//  PresentationLayer
//
//  Created by Danae Kikue Dimou on 12/9/22.
//

import DomainLayer
import SwiftUI

struct BaseRewardsCard: View {
	let transactionDate: String
    let stationRewards: Double
    let colorOfProgressBar: Color
    let rewardScore: Int
    let networkMaxValue: Double
    let rewardScoreHexagonColor: Color
    let networkMaxHexagonColor: Color
	let lostRewardsData: StationRewardsLostAmountData?

    var body: some View {
        rewardCard
    }

    var rewardCard: some View {
        VStack(alignment: .leading, spacing: CGFloat(.defaultSpacing)) {
			titleView
            wxmRewards
            rewardsProgressBar
            rewardsScores
        }
        .WXMCardStyle()
    }

	var titleView: some View {
		HStack {
			Text(transactionDate)
				.font(.system(size: CGFloat(.normalFontSize)))
				.foregroundColor(Color(colorEnum: .darkGrey))

			Spacer()

			if let lostRewardsData {
				StationLostRewardsView(lostRewards: lostRewardsData, rounded: false)
			}
		}
	}

    var wxmRewards: some View {
		HStack {
			Text("+ \(stationRewards.toWXMTokenPrecisionString) \(StringConstants.wxmCurrency)")
				.font(.system(size: CGFloat(.titleFontSize), weight: .bold))
				.foregroundColor(Color(colorEnum: .text))

			Spacer()
		}
    }

    var rewardsProgressBar: some View {
        ProgressBar(colorOfProgressBar: colorOfProgressBar, progressOfBar: stationRewards / networkMaxValue)
    }

    var rewardsScores: some View {
        HStack(spacing: 16) {
            RewardsScoreItem(
				score: (Double(rewardScore) / 100.0).toPrecisionString(minDecimals: 2, precision: 2),
                caption: LocalizableString.rewardScoreText.localized,
                hexagonColor: rewardScoreHexagonColor
            )
            RewardsScoreItem(
				score: networkMaxValue.toWXMTokenPrecisionString,
                caption: LocalizableString.networkMax.localized,
                hexagonColor: networkMaxHexagonColor
            )
        }
    }
}

extension BaseRewardsCard {
	init(record: UITransaction) {
		transactionDate = record.formattedTimestamp
		stationRewards = record.actualReward ?? 0
		colorOfProgressBar = Color(colorEnum: record.hexagonColor)
		rewardScore = record.rewardScore ?? 0
		networkMaxValue = record.dailyReward ?? 0
		rewardScoreHexagonColor = Color(colorEnum: record.hexagonColor)
		networkMaxHexagonColor = Color(colorEnum: .reward_score_unknown)
		lostRewardsData = StationRewardsLostAmountData(value: record.lostAmount, percentage: record.lostPercentage)
	}
}

#Preview {
	BaseRewardsCard(transactionDate: Date.now.getFormattedDate(format: .monthLiteralDayTime, relativeFormat: true).localizedCapitalized,
					stationRewards: 1.035869637693,
					colorOfProgressBar: .red,
					rewardScore: 100,
					networkMaxValue: 4.5,
					rewardScoreHexagonColor: .blue,
					networkMaxHexagonColor: .green,
					lostRewardsData: .init(value: 1.231324, percentage: 80))
}
