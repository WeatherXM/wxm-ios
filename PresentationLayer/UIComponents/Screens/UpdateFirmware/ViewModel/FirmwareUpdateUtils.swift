//
//  FirmwareUpdateUtils.swift
//  PresentationLayer
//
//  Created by Pantelis Giazitsis on 14/2/23.
//

import DomainLayer
import Foundation
import SwiftUI
import Toolkit

extension FirmwareUpdateError: @retroactive CustomStringConvertible {
    public var title: String {
        switch self {
            case .downloadFile:
                return LocalizableString.FirmwareUpdate.failureTitle.localized
            case .connection:
                return LocalizableString.FirmwareUpdate.failedConnectionTitle.localized
            case .installation:
                return LocalizableString.FirmwareUpdate.failureTitle.localized
        }
    }

    public var description: String {
        let description = LocalizableString.FirmwareUpdate.failureDescription(errorString).localized

        switch self {
            case .downloadFile, .installation:
                return description
            case .connection:
                let linkString = "[\(LocalizableString.ClaimDevice.failedTroubleshootingTextLinkTitle.localized)](\(DisplayedLinks.heliumTroubleshooting.linkURL))"

                return LocalizableString.FirmwareUpdate.failedStationConnectionDescription(linkString, LocalizableString.ClaimDevice.failedTextLinkTitle.localized).localized
        }
    }

    public var errorString: String {
        switch self {
            case .downloadFile:
                return LocalizableString.FirmwareUpdate.downloadFileError.localized
            case .connection:
                return LocalizableString.FirmwareUpdate.failedToConnectError.localized
            case let .installation(errorMessage):
                return LocalizableString.FirmwareUpdate.installError(errorMessage ?? "").localized
        }
    }
}

extension UpdateFirmwareViewModel {
    enum State: Equatable {
        static func == (lhs: UpdateFirmwareViewModel.State, rhs: UpdateFirmwareViewModel.State) -> Bool {
            switch (lhs, rhs) {
                case (.installing, .installing):
                    return true
                case (.failed, .failed):
                    return true
                case (.success, .success):
                    return true
                default: return false
            }
        }

        case installing
        case failed(FailSuccessStateObject)
        case success(FailSuccessStateObject)

        var stateObject: FailSuccessStateObject? {
            switch self {
                case .installing:
                    return nil
                case .failed(let obj):
                    return obj
                case .success(let obj):
                    return obj
            }
        }

        var isFailed: Bool {
            if case .failed = self {
                return true
            }

            return false
        }

        var isSuccess: Bool {
            if case .success = self {
                return true
            }

            return false
        }
    }

    enum Step: Int, CaseIterable, CustomStringConvertible {
        case connect = 0
        case download
        case install

        var description: String {
            switch self {
                case .connect:
                    return LocalizableString.connectToStation.localized
                case .download:
                    return LocalizableString.FirmwareUpdate.stepDownload.localized
                case .install:
                    return LocalizableString.FirmwareUpdate.stepInstall.localized
            }
        }

        var analyticsValue: ParameterValue {
            switch self {
                case .connect:
                    return .connect
                case .download:
                    return .download
                case .install:
                    return .install
            }
        }
    }
}

// MARK: - Mock

extension UpdateFirmwareViewModel {
    static var mockInstance: UpdateFirmwareViewModel {
        let viewModel = UpdateFirmwareViewModel(useCase: nil, device: DeviceDetails.emptyDeviceDetails)
        viewModel.title = "Connecting"
        viewModel.subtile = nil
        viewModel.currentStepIndex = 2
        viewModel.progress = 20
        viewModel.steps = [StepsView.Step(text: "Download Firmware Update", isCompleted: true),
                           StepsView.Step(text: "Connect to Station", isCompleted: true),
                           StepsView.Step(text: "Install Firmware Update", isCompleted: false)]

        return viewModel
    }

    static var successMockInstance: UpdateFirmwareViewModel {
        let viewModel = UpdateFirmwareViewModel(useCase: nil, device: DeviceDetails.emptyDeviceDetails)
        viewModel.state = .success(FailSuccessStateObject.mockSuccessObj)

        return viewModel
    }

    static var errorMockInstance: UpdateFirmwareViewModel {
        let viewModel = UpdateFirmwareViewModel(useCase: nil, device: DeviceDetails.emptyDeviceDetails)
        viewModel.state = .failed(FailSuccessStateObject.mockErrorObj)

        return viewModel
    }
}
