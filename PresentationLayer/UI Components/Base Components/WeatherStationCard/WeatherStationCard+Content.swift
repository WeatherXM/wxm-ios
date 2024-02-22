//
//  WeatherStationCard+Content.swift
//  PresentationLayer
//
//  Created by Pantelis Giazitsis on 30/1/23.
//

import DomainLayer
import SwiftUI
import Toolkit

/// Main ViewBuilders to be used from body callback
extension WeatherStationCard {
    @ViewBuilder
    var titleView: some View {
        StationAddressTitleView(device: device,
                                followState: followState,
                                showSubtitle: false,
                                showStateIcon: true,
                                tapStateIconAction: followAction,
                                tapAddressAction: nil)
    }

    @ViewBuilder
    var weatherView: some View {
        WeatherOverviewView(weather: device.weather)
    }

    @ViewBuilder
    var statusView: some View {
        let alertsCount = device.alertsCount(mainVM: mainScreenViewModel, followState: followState)
        if alertsCount > 1 {
            multipleAlertsView(alertsCount: alertsCount)
        } else if device.isActive {
            warningView
        } else {
            HStack(spacing: CGFloat(.smallSpacing)) {
                Image(asset: .offlineIcon)
                    .renderingMode(.template)
                    .foregroundColor(Color(colorEnum: .error))

                Text(LocalizableString.offlineStation.localized)
                    .foregroundColor(Color(colorEnum: .text))
                    .font(.system(size: CGFloat(.mediumFontSize), weight: .bold))

                Spacer()
            }
            .padding(CGFloat(.smallSidePadding))
        }
    }
}

/// Viewbuilders and stuff used internally from the main Viewbuilders
private extension WeatherStationCard {
    @ViewBuilder
    var lastActiveView: some View {
        StationLastActiveView(configuration: device.stationLastActiveConf)
    }

    @ViewBuilder
    var warningView: some View {
        if device.needsUpdate(mainVM: mainScreenViewModel, followState: followState) {
            CardWarningView(title: LocalizableString.stationWarningUpdateTitle.localized,
                            message: LocalizableString.stationWarningUpdateDescription.localized,
                            showContentFullWidth: true,
                            closeAction: nil) {
                Button {
                    updateFirmwareAction()
                    Logger.shared.trackEvent(.prompt, parameters: [.promptName: .OTAAvailable,
                                                                   .promptType: .warnPromptType,
                                                                   .action: .action])
                } label: {
                    Text(LocalizableString.stationWarningUpdateButtonTitle.localized)
                }
                .buttonStyle(WXMButtonStyle())
                .buttonStyle(.plain)
            }
			.padding(.vertical, CGFloat(.smallSidePadding))
            .onAppear {
                Logger.shared.trackEvent(.prompt, parameters: [.promptName: .OTAAvailable,
                                                               .promptType: .warnPromptType,
                                                               .action: .viewAction])
            }
        } else {
            EmptyView()
        }
    }

    @ViewBuilder
    func multipleAlertsView(alertsCount: Int) -> some View {
        HStack(spacing: CGFloat(.smallSpacing)) {
            Image(asset: .offlineIcon)
                .renderingMode(.template)
                .foregroundColor(Color(colorEnum: .error))

            Text(LocalizableString.issues(alertsCount).localized)
                .foregroundColor(Color(colorEnum: .text))
                .font(.system(size: CGFloat(.mediumFontSize), weight: .bold))

            Spacer()

            Button {
                viewMoreAction()
            } label: {
                Text(LocalizableString.viewMore.localized)
                    .foregroundColor(Color(colorEnum: .primary))
                    .font(.system(size: CGFloat(.normalFontSize), weight: .bold))
                    .padding(.horizontal, CGFloat(.smallSidePadding))
            }

        }
        .padding(CGFloat(.smallSidePadding))
    }
}
