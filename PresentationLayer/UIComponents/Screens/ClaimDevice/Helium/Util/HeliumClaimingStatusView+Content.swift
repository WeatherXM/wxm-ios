//
//  HeliumClaimingStatusView+Content.swift
//  PresentationLayer
//
//  Created by Pantelis Giazitsis on 30/1/23.
//

import DomainLayer
import SwiftUI

extension HeliumClaimingStatusView {
    func dismissAndNavigate(device: DeviceDetails?) {
        dismiss()
        DispatchQueue.main.async {
            if let device {
                Router.shared.popToRoot()
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { // The only way found to avoid errors with navigation stack
                    let route = Route.stationDetails(ViewModelsFactory.getStationDetailsViewModel(deviceId: device.id ?? "",
                                                                                                  cellIndex: device.cellIndex,
                                                                                                  cellCenter: device.cellCenter?.toCLLocationCoordinate2D()))
                    Router.shared.navigateTo(route)
                }
                return
            }
            viewModel.shouldExitClaimFlow = true
        }
    }

    func dismissAndUpdateFirmware(device: DeviceDetails?) {
        dismiss()
        viewModel.disconnect()
        if let device = device {
            mainVM.showFirmwareUpdate(device: device)
        }
        DispatchQueue.main.async {
            viewModel.shouldExitClaimFlow = true
        }
    }
}

private extension HeliumClaimingStatusView {
    var centeredParagraphStyle: NSParagraphStyle {
        let style = NSMutableParagraphStyle()
        style.alignment = .center
        return style
    }
}

extension HeliumClaimingStatusView {
    enum Steps: Int, CaseIterable, CustomStringConvertible {
        case settingFrequency
        case rebooting
        case claiming

        var description: String {
            switch self {
                case .settingFrequency:
                    return LocalizableString.ClaimDevice.stepSettingFrequency.localized
                case .rebooting:
                    return LocalizableString.rebootingStation.localized
                case .claiming:
                    return LocalizableString.ClaimDevice.stepClaiming.localized
            }
        }
    }
}
