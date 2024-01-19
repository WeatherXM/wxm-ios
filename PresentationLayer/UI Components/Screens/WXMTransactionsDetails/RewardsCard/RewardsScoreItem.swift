//
//  RewardsScoreItem.swift
//  PresentationLayer
//
//  Created by Danae Kikue Dimou on 12/9/22.
//

import SwiftUI

struct RewardsScoreItem: View {
    let score: String
    let caption: String
    let hexagonColor: Color

    var body: some View {
        rewardsScoreItem
    }

    var rewardsScoreItem: some View {
        HStack(alignment: .top) {
            rewardScoreIcon
            rewardsScoreInformation
        }
    }

    var rewardScoreIcon: some View {
        Image(asset: .hexagonBigger)
            .renderingMode(.template)
            .foregroundColor(hexagonColor)
    }

    var rewardsScoreInformation: some View {
        VStack(alignment: .leading, spacing: 4) {
            rewardScore
            rewardScoreCaption
        }
        .padding(.top, 5)
    }

    var rewardScore: some View {
        Text(score)
            .font(.system(size: CGFloat(.caption)))
            .foregroundColor(Color(colorEnum: .text))
    }

    var rewardScoreCaption: some View {
        Text(caption)
            .font(.system(size: CGFloat(.littleCaption)))
            .foregroundColor(Color(colorEnum: .darkGrey))
    }
}
