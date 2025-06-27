//
//  NetworkStatsViews.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 14/5/25.
//

import SwiftUI

extension View {
	@ViewBuilder
	func generateStatsView(stats: NetworkStatsView.Statistics) -> some View {
		VStack(spacing: CGFloat(.smallToMediumSpacing)) {
			statsTitleView(for: stats)
			if let customView = stats.customView {
				customView
			}
			
			statsChartView(for: stats)

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
		.onTapGesture {
			stats.cardTapAction?()
		}
	}

	@ViewBuilder
	func statsTitleView(for stats: NetworkStatsView.Statistics) -> some View {
		VStack(spacing: 0.0) {
			HStack {
				HStack(spacing: CGFloat(.smallSpacing)) {
					Text(stats.title)
						.font(.system(size: CGFloat(.mediumFontSize), weight: .bold))
						.foregroundColor(Color(colorEnum: .text))

					if stats.cardTapAction != nil {
						Text(FontIcon.chevronRight.rawValue)
							.font(.fontAwesome(font: .FAProSolid, size: CGFloat(.caption)))
							.foregroundColor(Color(colorEnum: .text))
					}
				}

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
					.font(.system(size: CGFloat(.caption)))
					.foregroundColor(Color(colorEnum: .darkestBlue))

				HStack {

					if stats.showExternalLinkIcon {
						Group {
							mainText +
							Text(" ") +
							Text(FontIcon.externalLink.rawValue)
								.font(.fontAwesome(font: .FAProSolid, size: CGFloat(.caption)))
								.foregroundColor(Color(colorEnum: .wxmPrimary))
						}
						.tint(Color(colorEnum: .wxmPrimary))
						.simultaneousGesture(TapGesture().onEnded {
							stats.externalLinkTapAction?()
						})
					} else {
						mainText
							.tint(Color(colorEnum: .wxmPrimary))
					}

					Spacer()
				}
			}
		}
		.padding(.leading, 22.0)
		.padding(.trailing, CGFloat(.smallToMediumSidePadding))
		.padding(.top, CGFloat(.mediumSidePadding))
	}

	@ViewBuilder
	func statsChartView(for stats: NetworkStatsView.Statistics) -> some View {
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
	}

	@ViewBuilder
	func additionalStatsView(statistics: [NetworkStatsView.AdditionalStats]) -> some View {
		LazyVGrid(columns: [.init(), .init()], spacing: CGFloat(.smallSpacing)) {
			ForEach(statistics, id: \.title) { stats in
				VStack(spacing: CGFloat(.smallSpacing)) {
					HStack {
						Text(stats.title.uppercased())
							.font(.system(size: CGFloat(.caption)))
							.foregroundColor(Color(colorEnum: .text))
							.fixedSize(horizontal: false, vertical: true)

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
					.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)


					if let progress = stats.progress {
						ProgressView(value: progress, total: 1.0)
							.progressViewStyle(ProgressBarStyle(bgColor: Color(colorEnum: .top),
																progressColor: Color(colorEnum: .chartPrimary)))
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
	func stationStatsView(statistics: NetworkStatsView.StationStatistics,
						  detailsAction: @escaping (NetworkStatsView.StationStatistics, NetworkStatsView.StationDetails) -> Void) -> some View {
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
					detailsAction(statistics, details)					
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
	func stationDetailsRowView(details: NetworkStatsView.StationDetails) -> some View {
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
	func ctaView(_ cta: NetworkStatsView.StatisticsCTA) -> some View {
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
						.foregroundColor(Color(colorEnum: .wxmPrimary))

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
