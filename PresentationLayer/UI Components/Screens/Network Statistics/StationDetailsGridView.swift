//
//  StationDetailsGridView.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 14/6/23.
//

import SwiftUI
import Toolkit

struct StationDetailsGridView: View {
    let statistics: NetworkStatsView.StationStatistics
    var tapDetailsAction: GenericCallback<NetworkStatsView.StationDetails>?

    @State private var firstColumnSizes: [SizeWrapper]
    @State private var lastColumnSizes: [SizeWrapper]
    @State private var totalSize: CGSize = .zero

    private var columns: [GridItem] {
        [GridItem(.fixed((firstColumnSizes.max { $0.size.width < $1.size.width }?.size.width)!),
                  spacing: CGFloat(.smallSpacing), alignment: .leading),
         GridItem(.flexible(),
                  spacing: CGFloat(.smallSpacing), alignment: .leading),
         GridItem(.fixed((lastColumnSizes.max { $0.size.width < $1.size.width }?.size.width)!),
                  alignment: .leading)]
    }

    init(statistics: NetworkStatsView.StationStatistics,
         tapDetailsAction: GenericCallback<NetworkStatsView.StationDetails>? = nil) {
        self.statistics = statistics
        self.tapDetailsAction = tapDetailsAction
        self.firstColumnSizes = (0..<statistics.details.count).map { _ in SizeWrapper() }
        self.lastColumnSizes = (0..<statistics.details.count).map { _ in SizeWrapper() }
    }

    var body: some View {
        LazyVGrid(columns: columns, spacing: CGFloat(.mediumSpacing)) {
            ForEach(0..<statistics.details.count, id: \.self) { index in
                let details = statistics.details[index]
                stationDetailsRowView(details: details, index: index)
            }
        }
    }
}

extension StationDetailsGridView {
    @ViewBuilder
    func stationDetailsRowView(details: NetworkStatsView.StationDetails, index: Int) -> some View {
        Group {
            HStack(spacing: CGFloat(.minimumSpacing)) {
                Text(details.title)
                    .font(.system(size: CGFloat(.caption)))
                    .foregroundColor(Color(colorEnum: .text))
                    .lineLimit(1)
                    .fixedSize()

                Image(asset: .openExternalIcon)
                    .renderingMode(.template)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(Color(colorEnum: .text))
                    .frame(width: 12.0)
            }
            .fixedSize()
            .sizeObserver(size: $firstColumnSizes[index].size)

            ZStack {
                ProgressView(value: max(details.percentage, 0.0), total: 1.0)
                    .progressViewStyle(ProgressBarStyle(bgColor: Color(colorEnum: .top),
                                                        progressColor: Color(colorEnum: details.color)))

                Text(LocalizableString.percentage((details.percentage * 100.0).rounded()).localized)
                    .font(.system(size: CGFloat(.caption), weight: .semibold))
                    .foregroundColor(Color(colorEnum: .text))
            }
            .frame(height: 18.0)

            Text(details.value)
                .font(.system(size: CGFloat(.caption), weight: .semibold))
                .foregroundColor(Color(colorEnum: .text))
                .fixedSize()
                .sizeObserver(size: $lastColumnSizes[index].size)
        }
        .onTapGesture {
            print("tapped \(details)")
            tapDetailsAction?(details)
        }
    }
}
