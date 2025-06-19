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
		let cardTapAction: VoidCallback?
		var customView: AnyView?
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
	var healthView: some View {
		if let health = viewModel.health {
			generateStatsView(stats: health)
		} else {
			EmptyView()
		}
	}

	@ViewBuilder
	var growthView: some View {
		if let growth = viewModel.growth {
			generateStatsView(stats: growth)
		} else {
			EmptyView()
		}
	}

    @ViewBuilder
    var buyStationView: some View {
		PercentageGridLayoutView {
			Group {
				VStack(spacing: CGFloat(.mediumSpacing)) {
					HStack {
						Text(LocalizableString.NetStats.enterWebThree.localized)
							.font(.system(size: CGFloat(.smallTitleFontSize), weight: .bold))
							.foregroundStyle(Color(colorEnum: .text))

						Spacer()
					}

					VStack(spacing: CGFloat(.smallSpacing)) {
						let bullets = [LocalizableString.NetStats.deployYourStation.localized,
									   LocalizableString.NetStats.checkTheWeather.localized,
									   LocalizableString.NetStats.earnWXM.localized]
						ForEach(bullets, id: \.self) { bullet in
							HStack(spacing: CGFloat(.smallSpacing)) {
								HStack {
									Text(FontIcon.check.rawValue)
										.font(.fontAwesome(font: .FAProSolid, size: CGFloat(.caption)))
										.foregroundStyle(Color(colorEnum: .success))

									Text(bullet)
										.font(.system(size: CGFloat(.normalFontSize)))
										.foregroundStyle(Color(colorEnum: .text))

									Spacer()
								}

							}
						}
					}

					HStack {
						Button {
							viewModel.handleBuyStationTap()
						} label: {
							Text(LocalizableString.NetStats.buyStationCardButtonTitle.localized)
								.padding(.horizontal, CGFloat(.defaultSidePadding))
						}
						.buttonStyle(WXMButtonStyle.filled())
						.fixedSize()

						Spacer()
					}
				}

				Image(asset: .imageStation)
					.resizable()
					.aspectRatio(contentMode: .fit)
			}
		}
		.WXMCardStyle(backgroundColor: Color(colorEnum: .blueTint),
					  insideHorizontalPadding: CGFloat(.mediumSidePadding),
					  insideVerticalPadding: CGFloat(.mediumSidePadding))
		.wxmShadow()
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
						stationStatsView(statistics: stats) { statistics, details in
							viewModel.handleDetailsActionTap(statistics: statistics, details: details)
						}
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

}
