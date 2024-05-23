//
//  NetworkStats+Content.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 12/6/23.
//

import Foundation
import SwiftUI
import Toolkit

extension NetworkStatsView {

    enum State {
        case empty
        case loading
        case content
        case fail
    }
    
    typealias XAxisTuple = (leading: String, trailing: String)
	
	struct Accessory {
		let fontIcon: FontIcon
		let action: VoidCallback
	}

    struct Statistics {
        let title: String
        let description: AttributedString?
        let showExternalLinkIcon: Bool
        let externalLinkTapAction: VoidCallback?
        let mainText: String?
        let accessory: Accessory?
        let dateString: String?
        let chartModel: NetStatsChartViewModel?
        let xAxisTuple: XAxisTuple?
        var additionalStats: [AdditionalStats]?
        let analyticsItemId: ParameterValue?
    }

    struct AdditionalStats {
        let title: String
        let value: String
        var color: ColorEnum = .text
        var accessory: Accessory?
		var progress: CGFloat?
        let analyticsItemId: ParameterValue?
    }

    struct StationStatistics: Identifiable {
        var id: String {
			"\(title.hashValue)-\(total.hashValue)-\(accessory?.fontIcon.rawValue ?? "")-\(details.hashValue)"
        }

        let title: String
        let total: String
        var accessory: Accessory?
        let details: [StationDetails]
        let analyticsItemId: ParameterValue
    }

    struct StationDetails: Hashable {
        let title: String
        let value: String
        let percentage: Float
        let color: ColorEnum
        let url: String?
    }

    struct StatisticsCTA {
        let title: String?
        let description: String
        let accessory: Accessory?
        let analyticsItemId: ParameterValue?
        let buttonTitle: String
        let buttonAction: VoidCallback
    }
}

// MARK: - View builders

extension NetworkStatsView {
    @ViewBuilder
    var dataDaysView: some View {
        if let dataDays = viewModel.dataDays {
            generateStatsView(stats: dataDays)
        } else {
            EmptyView()
        }
    }

    @ViewBuilder
    var rewardsView: some View {
        if let rewards = viewModel.rewards {
            generateStatsView(stats: rewards)
        } else {
            EmptyView()
        }
    }

    @ViewBuilder
    var tokenView: some View {
        if let token = viewModel.token {
            generateStatsView(stats: token)
        } else {
            EmptyView()
        }
    }

    @ViewBuilder
    var buyStationView: some View {
        if let buyStationCTA = viewModel.buyStationCTA {
            ctaView(buyStationCTA)
        } else {
            EmptyView()
        }
    }

    @ViewBuilder
    var manufacturerView: some View {
        if let cta = viewModel.manufacturerCTA {
            ctaView(cta)
        } else {
            EmptyView()
        }
    }

    @ViewBuilder
    var lastUpdatedView: some View {
        if let lastUpdated = viewModel.lastUpdatedText {
            HStack {
                Spacer()

                Text(lastUpdated)
                    .font(.system(size: CGFloat(.normalFontSize), weight: .thin))
                    .foregroundColor(Color(colorEnum: .text))

            }
        } else {
            EmptyView()
        }
    }
    @ViewBuilder
    var weatherStationsView: some View {
        if let stationStats = viewModel.stationStats {
            VStack(spacing: CGFloat(.mediumSpacing)) {
                HStack {
                    Text(LocalizableString.NetStats.weatherStations.localized)
                        .font(.system(size: CGFloat(.mediumFontSize), weight: .bold))
                        .foregroundColor(Color(colorEnum: .text))
                    Spacer()
                }
                .padding(.horizontal, 24.0)

                VStack(spacing: CGFloat(.mediumSpacing)) {
                    ForEach(stationStats, id: \.title) { stats in
                        stationStatsView(statistics: stats)
                    }
                }
				.padding(.horizontal, CGFloat(.smallToMediumSidePadding))
            }
            .WXMCardStyle(backgroundColor: Color(colorEnum: .top),
                          insideHorizontalPadding: 0.0,
                          insideVerticalPadding: CGFloat(.smallToMediumSidePadding))
            .wxmShadow()

        } else {
            EmptyView()
        }
    }

    @ViewBuilder
    func generateStatsView(stats: Statistics) -> some View {
		VStack(spacing: CGFloat(.smallToMediumSpacing)) {
			VStack(spacing: CGFloat(.minimumSpacing)) {
                HStack {
                    Text(stats.title)
                        .font(.system(size: CGFloat(.mediumFontSize), weight: .bold))
                        .foregroundColor(Color(colorEnum: .text))

                    Spacer()

                    if let accessory = stats.accessory {
                        Button {
							accessory.action()
                        } label: {
							Text(accessory.fontIcon.rawValue)
                                .font(.fontAwesome(font: .FAProLight, size: CGFloat(.caption)))
                                .foregroundColor(Color(colorEnum: .text))
                                .frame(width: 30.0, height: 30.0)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }
                }

                if let description = stats.description {
                    let mainText = Text(description)
                        .font(.system(size: CGFloat(.normalFontSize)))
                        .foregroundColor(Color(colorEnum: .darkestBlue))

                    HStack {

                        if stats.showExternalLinkIcon {
                            Group {
                                mainText +
                                Text(" ") +
                                Text(FontIcon.externalLink.rawValue)
                                    .font(.fontAwesome(font: .FAProSolid, size: CGFloat(.normalFontSize)))
                                    .foregroundColor(Color(colorEnum: .primary))
                            }
                            .tint(Color(colorEnum: .primary))
                            .simultaneousGesture(TapGesture().onEnded {
                                stats.externalLinkTapAction?()
                            })
                        } else {
                            mainText
                                .tint(Color(colorEnum: .primary))
                        }

                        Spacer()
                    }
                }
            }
            .padding(.leading, 22.0)
			.padding(.trailing, CGFloat(.smallToMediumSidePadding))
			.padding(.top, CGFloat(.mediumSidePadding))

            if let chartModel = stats.chartModel {
                HStack(spacing: CGFloat(.defaultSidePadding)) {
                    VStack(spacing: CGFloat(.smallToMediumSpacing)) {
                        StatisticsChart(chartDataModel: chartModel)
                            .frame(height: 45.0)
                            .aspectRatio(4, contentMode: .fill)
							.padding(.horizontal, CGFloat(.smallToMediumSidePadding))

                        if let xAxis = stats.xAxisTuple {
                            HStack {
                                Text(xAxis.leading.uppercased())
                                Spacer()
                                Text(xAxis.trailing.uppercased())
                            }
                            .font(.system(size: CGFloat(.caption)))
                            .foregroundColor(Color(colorEnum: .darkGrey))
                        }
                    }

                    Spacer()

                    VStack(spacing: 0.0) {
                        if let mainText = stats.mainText {
                            Text(mainText)
                                .font(.system(size: CGFloat(.titleFontSize), weight: .bold))
                                .foregroundColor(Color(colorEnum: .text))
                                .multilineTextAlignment(.center)
                        }

                        if let dateString = stats.dateString {
                            Text(dateString)
                                .font(.system(size: CGFloat(.caption)))
                                .foregroundColor(Color(colorEnum: .darkGrey))
                                .multilineTextAlignment(.center)
                        }
                    }
                }
                .padding(.leading, 24.0)
                .padding(.trailing, 28.0)
            }

            if let additionalStats = stats.additionalStats {
                additionalStatsView(statistics: additionalStats)
                    .padding(.horizontal, CGFloat(.smallToMediumSidePadding))
					.padding(.bottom, CGFloat(.smallToMediumSidePadding))
            }
        }
        .WXMCardStyle(backgroundColor: Color(colorEnum: .top),
                      insideHorizontalPadding: 0.0,
                      insideVerticalPadding: 0.0)
        .wxmShadow()
    }

    @ViewBuilder
    func additionalStatsView(statistics: [AdditionalStats]) -> some View {
		LazyVGrid(columns: [.init(.adaptive(minimum: 80.0)), .init(.adaptive(minimum: 80.0))], spacing: CGFloat(.smallSpacing)) {
            ForEach(statistics, id: \.title) { stats in
                VStack(spacing: CGFloat(.smallSpacing)) {
                    HStack {
                        Text(stats.title.uppercased())
                            .font(.system(size: CGFloat(.caption)))
                            .foregroundColor(Color(colorEnum: .text))

                        Spacer()

                        if let accessory = stats.accessory {
                            Button {
								accessory.action()
                            } label: {
								Text(accessory.fontIcon.rawValue)
                                    .font(.fontAwesome(font: .FAPro, size: CGFloat(.caption)))
                                    .foregroundColor(Color(colorEnum: .text))
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    HStack {
                        Text(stats.value)
                            .font(.system(size: CGFloat(.titleFontSize), weight: .bold))
                            .foregroundColor(Color(colorEnum: stats.color))
                            .lineLimit(1)

                        Spacer()
                    }

					if let progress = stats.progress {
						ProgressView(value: progress, total: 1.0)
							.progressViewStyle(ProgressBarStyle(bgColor: Color(colorEnum: .top),
																progressColor: Color(colorEnum: .chartSecondary)))
							.frame(height: 4.0)
					}
                }
				.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .WXMCardStyle(backgroundColor: Color(colorEnum: .layer1),
                              insideHorizontalPadding: CGFloat(.mediumSidePadding),
                              insideVerticalPadding: CGFloat(.smallSidePadding),
                              cornerRadius: CGFloat(.buttonCornerRadius))
            }
        }
    }

    @ViewBuilder
    func stationStatsView(statistics: StationStatistics) -> some View {
        VStack(spacing: CGFloat(.smallSpacing)) {
            HStack {
                Text(statistics.title.uppercased())
                    .font(.system(size: CGFloat(.normalFontSize)))
                    .foregroundColor(Color(colorEnum: .text))

                Spacer()

                if let accessory = statistics.accessory {
                    Button {
						accessory.action()
                    } label: {
						Text(accessory.fontIcon.rawValue)
                            .font(.fontAwesome(font: .FAProLight, size: CGFloat(.caption)))
                            .foregroundColor(Color(colorEnum: .text))
                            .frame(width: 30.0, height: 30.0)
                            .contentShape(Rectangle())

                    }
                    .buttonStyle(.plain)
                }
            }

            HStack(spacing: CGFloat(.mediumSpacing)) {
                StationDetailsGridView(statistics: statistics) { details in
                    viewModel.handleDetailsActionTap(statistics: statistics, details: details)
                }
                .frame(maxWidth: .infinity)
                .id(statistics.id)

                Text(statistics.total)
                    .font(.system(size: CGFloat(.titleFontSize), weight: .bold))
                    .foregroundColor(Color(colorEnum: .text))
                    .lineLimit(1)
            }
			.padding(.trailing, CGFloat(.smallSidePadding))
        }
        .WXMCardStyle(backgroundColor: Color(colorEnum: .layer1),
                      insideHorizontalPadding: 12.0,
                      insideVerticalPadding: 12.0,
                      cornerRadius: CGFloat(.buttonCornerRadius))
    }

    @ViewBuilder
    func stationDetailsRowView(details: StationDetails) -> some View {
        Text(details.title)
            .font(.system(size: CGFloat(.caption)))
            .foregroundColor(Color(colorEnum: .text))
            .lineLimit(1)
            .fixedSize()

        ZStack {
            ProgressView(value: details.percentage, total: 1.0)
                .progressViewStyle(ProgressBarStyle(bgColor: Color(colorEnum: .top),
                                                    progressColor: Color(colorEnum: details.color)))

            Text(LocalizableString.percentage(details.percentage * 100.0).localized)
                .font(.system(size: CGFloat(.normalFontSize), weight: .semibold))
                .foregroundColor(Color(colorEnum: .text))
        }
        .frame(width: .infinity, height: 18.0)

        Text(details.value)
            .font(.system(size: CGFloat(.caption), weight: .semibold))
            .foregroundColor(Color(colorEnum: .text))
            .fixedSize()
    }

    @ViewBuilder
    func ctaView(_ cta: StatisticsCTA) -> some View {
        HStack(spacing: 0.0) {
            VStack(spacing: CGFloat(.minimumSpacing)) {
                if let title = cta.title {
                    HStack(alignment: .center, spacing: CGFloat(.minimumSpacing)) {
                        Text(title)
                            .font(.system(size: CGFloat(.caption)))
                            .foregroundColor(Color(colorEnum: .text))

                        Spacer(minLength: 0.0)
                    }
                }

                HStack {
                    let mainText = Text(cta.description)
                        .font(.system(size: CGFloat(.mediumFontSize), weight: .bold))
                        .foregroundColor(Color(colorEnum: .primary))

                    if let accessory = cta.accessory {
                        Button {
							accessory.action()
                        } label: {
                            mainText +
                            Text(" ") +
							Text(accessory.fontIcon.rawValue)
                                .font(.fontAwesome(font: .FAProLight, size: CGFloat(.littleCaption)))
                                .fontWeight(.bold)
                                .foregroundColor(Color(colorEnum: .darkestBlue))
                        }
                        .buttonStyle(.plain)
                    } else {
                        mainText
                    }

                    Spacer(minLength: 0.0)
                }
            }

            Button {
                cta.buttonAction()
            } label: {
                Text(cta.buttonTitle)
					.padding(.horizontal, CGFloat(.mediumSidePadding))
            }
            .buttonStyle(WXMButtonStyle.filled())
            .fixedSize()
        }
        .padding(.trailing, CGFloat(.smallToMediumSidePadding))
        .padding(.leading, CGFloat(.mediumToLargeSidePadding))
		.padding(.vertical, CGFloat(.smallToMediumSidePadding))
        .WXMCardStyle(backgroundColor: Color(colorEnum: .blueTint),
                      insideHorizontalPadding: 0.0,
                      insideVerticalPadding: 0.0)
        .wxmShadow()
    }
}
