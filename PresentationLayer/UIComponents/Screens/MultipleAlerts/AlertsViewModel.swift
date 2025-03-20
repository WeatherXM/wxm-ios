//
//  AlertsViewModel.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 26/5/23.
//

import Foundation
import Combine
import DomainLayer
import Toolkit
import UIKit

@MainActor
class AlertsViewModel: ObservableObject {

    @Published private(set) var alerts: [MultipleAlertsView.Alert] = []
    let device: DeviceDetails
    let mainVM: MainScreenViewModel
    let followState: UserDeviceFollowState?

    init(device: DeviceDetails, mainVM: MainScreenViewModel, followState: UserDeviceFollowState?) {
        self.device = device
        self.mainVM = mainVM
        self.followState = followState
        generateAlerts()
    }

	func viewAppeared() {
		WXMAnalytics.shared.trackScreen(.deviceAlerts)
	}
}

extension AlertsViewModel: HashableViewModel {
	nonisolated func hash(into hasher: inout Hasher) {
        hasher.combine(device.id)
    }
}

private extension AlertsViewModel {
    func generateAlerts() {
        var alerts: [MultipleAlertsView.Alert] = []
		let isOwned = followState?.relation == .owned

		if !device.isActive {
			let description: LocalizableString = isOwned ? .alertsOwnedStationOfflineDescription : .alertsStationOfflineDescription
            let alert = MultipleAlertsView.Alert(type: .error,
                                                 title: LocalizableString.alertsStationOfflineTitle.localized,
                                                 message: description.localized,
												 icon: nil,
												 buttonTitle: isOwned ? LocalizableString.contactSupport.localized : nil,
                                                 buttonAction: handleContactSupportTap,
                                                 appearAction: nil)
            alerts.append(alert)
        }

        if device.needsUpdate(mainVM: mainVM, followState: followState) {
            let alert = MultipleAlertsView.Alert(type: .warning,
                                                 title: LocalizableString.stationWarningUpdateTitle.localized,
                                                 message: LocalizableString.stationWarningUpdateDescription.localized,
												 icon: .arrowsRotate,
                                                 buttonTitle: LocalizableString.stationWarningUpdateButtonTitle.localized,
                                                 buttonAction: handleFirmwareUpdateTap,
                                                 appearAction: { [weak self] in self?.trackPromptEvent(action: .viewAction) })
            alerts.append(alert)
        }

		if device.isBatteryLow(followState: followState) {
			let alert = MultipleAlertsView.Alert(type: .warning,
												 title: LocalizableString.stationWarningLowBatteryTitle.localized,
												 message: LocalizableString.stationWarningLowBatteryDescription.localized,
												 icon: .batteryLow,
												 buttonTitle: LocalizableString.stationWarningLowBatteryButtonTitle.localized,
												 buttonAction: handleLowBatteryTap,
												 appearAction: nil)
			alerts.append(alert)
		}

        self.alerts = alerts
    }

    func handleContactSupportTap() {
        WXMAnalytics.shared.trackEvent(.selectContent, parameters: [.contentType: .contactSupport,
                                                              .source: .stationOffline])

		HelperFunctions().openContactSupport(successFailureEnum: .stationOffline,
											 email: mainVM.userInfo?.email,
											 serialNumber: device.label,
											 trackSelectContentEvent: false)
    }

    func handleFirmwareUpdateTap() {
        trackPromptEvent(action: .action)
        mainVM.showFirmwareUpdate(device: device)
    }

	func handleLowBatteryTap() {
		guard let name = device.bundle?.name else {
			return
		}
		switch name {
			case .m5:
				if let url = URL(string: DisplayedLinks.m5Batteries.linkURL) {
					UIApplication.shared.open(url)
				}
			case .h1, .h2:
				if let url = URL(string: DisplayedLinks.heliumBatteries.linkURL) {
					UIApplication.shared.open(url)
				}
			case .d1:
				if let url = URL(string: DisplayedLinks.heliumBatteries.linkURL) {
					UIApplication.shared.open(url)
				}
			case .pulse:
				#warning("Open pulse link")
		}

	}

    func trackPromptEvent(action: ParameterValue) {
        WXMAnalytics.shared.trackEvent(.prompt, parameters: [.promptName: .OTAAvailable,
                                                       .promptType: .warnPromptType,
                                                       .action: action])
    }

}
