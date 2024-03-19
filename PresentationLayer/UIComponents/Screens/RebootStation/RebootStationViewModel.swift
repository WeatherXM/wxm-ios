//
//  RebootStationViewModel.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 9/3/23.
//

import Foundation
import DomainLayer
import Combine

class RebootStationViewModel: ObservableObject {
    @Published var state: State = .reboot
    @Published private(set) var steps: [StepsView.Step] = Step.allCases.map { StepsView.Step(text: $0.description, isCompleted: false) }
    @Published var currentStepIndex: Int?
    @Published private(set) var dismissToggle: Bool = false

    var mainVM: MainScreenViewModel?

    private let useCase: DeviceInfoUseCase?
    let device: DeviceDetails
    private var cancellables: Set<AnyCancellable> = []

    init(device: DeviceDetails, useCase: DeviceInfoUseCase?) {
        self.device = device
        self.useCase = useCase
        startReboot()
    }

    func startReboot() {
        useCase?.rebootStation(device: device).sink { [weak self] state in
            guard let self else {
                return
            }
            DispatchQueue.main.async {
                switch state {
                    case .connect:
                        self.state = .reboot
                        self.currentStepIndex = 0
                    case .rebooting:
                        self.state = .reboot
                        self.currentStepIndex = 1
                    case .failed(let rebootError):
                        self.handleRebootError(rebootError)
                    case .finished:
                        let obj = FailSuccessStateObject(type: .rebootStation,
                                                         title: LocalizableString.deviceInfoStationRebooted.localized,
                                                         subtitle: LocalizableString.deviceInfoStationRebootedDescription.localized.attributedMarkdown,
                                                         cancelTitle: nil,
                                                         retryTitle: LocalizableString.deviceInfoStationBackToSettings.localized,
                                                         contactSupportAction: nil,
                                                         cancelAction: nil,
                                                         retryAction: { [weak self] in self?.dismissToggle.toggle() })
                        self.state = .success(obj)
                }
                self.updateSteps()

                print("Reboot State \(state)")
            }
        }.store(in: &cancellables)
    }

    func navigationBackButtonTapped() {

    }
}

extension RebootStationViewModel {
    enum State: Equatable {
        static func == (lhs: RebootStationViewModel.State, rhs: RebootStationViewModel.State) -> Bool {
            switch (lhs, rhs) {
                case (.reboot, .reboot):
                    return true
                case (.failed, .failed):
                    return true
                case (.success, .success):
                    return true
                default: return false
            }
        }

        case reboot
        case failed(FailSuccessStateObject)
        case success(FailSuccessStateObject)
    }
}

private extension RebootStationViewModel {
    enum Step: Int, CaseIterable, CustomStringConvertible {
        case connect = 0
        case reboot

		var description: String {
			switch self {
				case .connect:
					return LocalizableString.connectToStation.localized
				case .reboot:
					return LocalizableString.rebootingStation.localized
			}
		}
	}

    func updateSteps() {
        guard let currentStepIndex else {
            (0 ..< steps.count).forEach { index in
                steps[index].setCompleted(false)
            }
            return
        }

        (0 ..< currentStepIndex).forEach { index in
            steps[index].setCompleted(index < currentStepIndex)
        }
    }

    func handleRebootError(_ rebootError: RebootError) {
        let title: String = LocalizableString.deviceInfoStationRebootFailed.localized
        let subtitle: String
        let cancelTitle = LocalizableString.cancel.localized
        let retryTitle = LocalizableString.retry.localized
        let contactSupportAction: () -> Void
        let cancelAction: () -> Void = { [weak self] in self?.dismissToggle.toggle()}
        let retryAction: () -> Void = { [weak self] in self?.startReboot() }

        switch rebootError {
            case .bluetooth(let bluetoothState):
                subtitle = bluetoothState.errorDescription ?? ""
                contactSupportAction = { [weak self] in
					HelperFunctions().openContactSupport(successFailureEnum: .rebootStation,
														 email: self?.mainVM?.userInfo?.email,
														 serialNumber: self?.device.label,
														 errorString: subtitle)
                }
            case .notInRange:
                subtitle = LocalizableString.FirmwareUpdate.stationNotInRangeDescription.localized
                contactSupportAction = { [weak self] in
					HelperFunctions().openContactSupport(successFailureEnum: .rebootStation,
														 email: self?.mainVM?.userInfo?.email,
														 serialNumber: self?.device.label,
														 errorString: LocalizableString.FirmwareUpdate.stationNotInRangeTitle.localized)
				}
            case .connect:
                let linkString = "[\(LocalizableString.ClaimDevice.failedTroubleshootingTextLinkTitle.localized)](\(DisplayedLinks.heliumTroubleshooting.linkURL))"
                subtitle = LocalizableString.FirmwareUpdate.failedStationConnectionDescription(linkString, LocalizableString.ClaimDevice.failedTextLinkTitle.localized).localized
				contactSupportAction = { [weak self] in
					HelperFunctions().openContactSupport(successFailureEnum: .rebootStation,
														 email: self?.mainVM?.userInfo?.email,
														 serialNumber: self?.device.label,
														 errorString: LocalizableString.FirmwareUpdate.failedToConnectError.localized)
                }
            case .unknown:
                return
        }

        let obj = FailSuccessStateObject(type: .rebootStation,
                                         title: title,
                                         subtitle: subtitle.attributedMarkdown,
                                         cancelTitle: cancelTitle,
                                         retryTitle: retryTitle,
                                         contactSupportAction: contactSupportAction,
                                         cancelAction: cancelAction,
                                         retryAction: retryAction)
        self.state = .failed(obj)
    }
}
