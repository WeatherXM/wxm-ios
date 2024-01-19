//
//  CustomRangeSlider.swift
//  PresentationLayer
//
//  Created by Panagiotis Palamidas on 29/7/22.
//

import SwiftUI

struct CustomRangeSlider: View {
    var minWeeklyTemp: CGFloat
    var maxWeeklyTemp: CGFloat
    var minDailyTemp: CGFloat
    var maxDailyTemp: CGFloat

    private let sliderHeight: CGFloat = 14.0

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                Color(colorEnum: .bg)
                shapeFor(size: proxy.size)
            }
        }
        .frame(height: sliderHeight)
        .cornerRadius(CGFloat(.cardCornerRadius))
    }
}

private extension CustomRangeSlider {
    var totalRange: CGFloat {
        maxWeeklyTemp - minWeeklyTemp
    }

    var diff: CGFloat {
        maxDailyTemp - minDailyTemp
    }

    var offset: CGFloat {
        minDailyTemp - minWeeklyTemp
    }

    @ViewBuilder
    func shapeFor(size: CGSize) -> some View {
        HStack {
            Rectangle()
                .fill(Color(colorEnum: .primary))
                .frame(width: (diff * size.width) / totalRange,
                       height: sliderHeight)
                .cornerRadius(CGFloat(.cardCornerRadius))
                .offset(x: (offset * size.width) / totalRange)

            Spacer(minLength: 0.0)
        }
    }
}

struct Previews_CustomRangeSlider_Previews: PreviewProvider {
    static var previews: some View {
        CustomRangeSlider(minWeeklyTemp: 8.0, maxWeeklyTemp: 19.0, minDailyTemp: 13, maxDailyTemp: 19)
    }
}
