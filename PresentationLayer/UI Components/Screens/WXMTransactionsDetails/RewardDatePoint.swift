//
//  RewardDatePoint.swift
//  PresentationLayer
//
//  Created by Danae Kikue Dimou on 12/9/22.
//

import SwiftUI

struct RewardDatePoint: View {
    let dateOfTransaction: String

    var body: some View {
        datePoint
    }

    var datePoint: some View {
        HStack(spacing: 16) {
            circlePoint
            dateOfTransactionText
        }
        .padding(.leading, 36)
    }

    var circlePoint: some View {
        Circle()
            .fill(Color(colorEnum: .midGrey))
            .frame(width: 12, height: 12)
    }

    var dateOfTransactionText: some View {
        Text(dateOfTransaction)
            .foregroundColor(Color(colorEnum: .darkGrey))
            .font(.system(size: CGFloat(.normalFontSize), weight: .bold))
    }
}
