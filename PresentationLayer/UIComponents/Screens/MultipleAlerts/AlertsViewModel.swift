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
}

extension AlertsViewModel: HashableViewModel {
    func hash(into hasher: inout Hasher) {
        hasher.combine(device.id)
    }
}

private extension AlertsViewModel {
    func generateAlerts() {
        var alerts: [MultipleAlertsView.Alert] = []

        if !device.isActive {
            let alert = MultipleAlertsView.Alert(type: .error,
                                                 title: LocalizableString.alertsStationOfflineTitle.localized,
                                                 message: LocalizableString.alertsStationOfflineDescription.localized,
                                                 buttonTitle: LocalizableString.contactSupport.localized,
                                                 buttonAction: handleContactSupportTap,
                                                 appearAction: nil)
            alerts.append(alert)
        }

        if device.needsUpdate(mainVM: mainVM, followState: followState) {
            let alert = MultipleAlertsView.Alert(type: .warning,
                                                 title: LocalizableString.stationWarningUpdateTitle.localized,
                                                 message: LocalizableString.stationWarningUpdateDescription.localized,
                                                 buttonTitle: LocalizableString.stationWarningUpdateButtonTitle.localized,
                                                 buttonAction: handleFirmwareUpdateTap,
                                                 appearAction: { [weak self] in self?.trackPromptEvent(action: .viewAction) })
            alerts.append(alert)
        }

		if device.isBatteryLow(followState: followState) {
			let alert = MultipleAlertsView.Alert(type: .warning,
												 title: LocalizableString.stationWarningLowBatteryTitle.localized,
												 message: LocalizableString.stationWarningLowBatteryDescription.localized,
												 buttonTitle: LocalizableString.stationWarningLowBatteryButtonTitle.localized,
												 buttonAction: handleLowBatteryTap,
												 appearAction: nil)
			alerts.append(alert)
		}

        self.alerts = alerts
    }

    func handleContactSupportTap() {
        Logger.shared.trackEvent(.selectContent, parameters: [.contentType: .contactSupport,
                                                              .source: .deviceAlertsSource])

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
		guard let profile = device.profile else {
			return
		}
		switch profile {
			case .m5:
				if let url = URL(string: DisplayedLinks.m5Batteries.linkURL) {
					UIApplication.shared.open(url)
				}
			case .helium:
				if let url = URL(string: DisplayedLinks.heliumBatteries.linkURL) {
					UIApplication.shared.open(url)
				}
		}

	}

    func trackPromptEvent(action: ParameterValue) {
        Logger.shared.trackEvent(.prompt, parameters: [.promptName: .OTAAvailable,
                                                       .promptType: .warnPromptType,
                                                       .action: action])
    }

}
