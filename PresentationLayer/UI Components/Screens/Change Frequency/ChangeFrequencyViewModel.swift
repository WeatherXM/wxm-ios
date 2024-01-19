//
//  ChangeFrequencyViewModel.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 13/3/23.
//

import Foundation
import Combine
import DomainLayer
import Toolkit

class ChangeFrequencyViewModel: ObservableObject {
    @Published var state: State = .setFrequency
    @Published var selectedFrequency: Frequency?
    @Published var isFrequencyAcknowledged: Bool = false
    @Published private(set) var steps: [StepsView.Step] = Step.allCases.map { StepsView.Step(text: $0.description, isCompleted: false) }
    @Published var currentStepIndex: Int?
    @Published private(set) var dismissToggle: Bool = false

	private let mainVM: MainScreenViewModel = .shared

    private let useCase: DeviceInfoUseCase?
    let device: DeviceDetails
    private var cancellables: Set<AnyCancellable> = []

    init(device: DeviceDetails, useCase: DeviceInfoUseCase?, frequency: Frequency? = Frequency.allCases.first) {
        self.device = device
        self.useCase = useCase
        self.selectedFrequency = frequency
    }

    func changeButtonTapped() {
        Logger.shared.trackEvent(.userAction, parameters: [.actionName: .changeFrequencyResult,
                                                           .contentType: .changeStationFrequency,
                                                           .action: .change])
        setFrequency()
    }

    func cancelButtonTapped() {
        Logger.shared.trackEvent(.userAction, parameters: [.actionName: .changeFrequencyResult,
                                                           .contentType: .changeStationFrequency,
                                                           .action: .cancel])

        dismissToggle.toggle()
    }
}

extension ChangeFrequencyViewModel {
    enum State: Equatable {
        static func == (lhs: ChangeFrequencyViewModel.State, rhs: ChangeFrequencyViewModel.State) -> Bool {
            switch (lhs, rhs) {
                case (.setFrequency, .setFrequency):
                    return true
                case (.changeFrequency, .changeFrequency):
                    return true
                case (.failed, .failed):
                    return true
                case (.success, .success):
                    return true
                default: return false
            }
        }

        case setFrequency
        case changeFrequency
        case failed(FailSuccessStateObject)
        case success(FailSuccessStateObject)

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

        var stateObject: FailSuccessStateObject? {
            switch self {
                case .setFrequency, .changeFrequency:
                    return nil
                case .failed(let obj):
                    return obj
                case .success(let obj):
                    return obj
            }
        }
    }
}

private extension ChangeFrequencyViewModel {
    enum Step: CaseIterable, CustomStringConvertible {
        case connect
        case settingFrequncy

        var description: String {
            switch self {
                case .connect:
                    return LocalizableString.connectToStation.localized
                case .settingFrequncy:
                    return LocalizableString.changingFrequency.localized
            }
        }
    }

    func setFrequency() {
        guard let selectedFrequency else {
            return
        }
        useCase?.changeFrequency(device: device, frequency: selectedFrequency).sink { [weak self] state in
            DispatchQueue.main.async {
                switch state {
                    case .connect:
                        self?.state = .changeFrequency
                        self?.currentStepIndex = 0
                    case .changing:
                        self?.state = .changeFrequency
                        self?.currentStepIndex = 1
                    case .failed(let error):
                        self?.handleFrequencyError(error)
                    case .finished:
                        let subtitle = LocalizableString.deviceInfoStationFrequencyChangedDescription(selectedFrequency.rawValue).localized
                        let obj = FailSuccessStateObject(type: .changeFrequency,
                                                         title: LocalizableString.deviceInfoStationFrequencyChanged.localized,
                                                         subtitle: subtitle.attributedMarkdown,
                                                         cancelTitle: nil,
                                                         retryTitle: LocalizableString.deviceInfoStationBackToSettings.localized,
                                                         contactSupportAction: nil,
                                                         cancelAction: nil,
                                                         retryAction: { [weak self] in self?.dismissToggle.toggle() })
                        self?.state = .success(obj)

                }
                self?.updateSteps()
            }
        }.store(in: &cancellables)
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

    func handleFrequencyError(_ error: ChangeFrequencyError) {
        let title: String = LocalizableString.deviceInfoStationFrequencyChangeFailed.localized
        let subtitle: String
        let cancelTitle = LocalizableString.cancel.localized
        let retryTitle = LocalizableString.retry.localized
        let contactSupportAction: () -> Void
        let cancelAction: () -> Void = { [weak self] in self?.dismissToggle.toggle()}
        let retryAction: () -> Void = { [weak self] in self?.setFrequency() }

		switch error {
			case .bluetooth(let bluetoothState):
				subtitle = bluetoothState.errorDescription ?? ""
				contactSupportAction = { [weak self] in
					HelperFunctions().openContactSupport(successFailureEnum: .changeFrequency,
														 email: self?.mainVM.userInfo?.email,
														 serialNumber: self?.device.label,
														 errorString: bluetoothState.errorDescription ?? "-")
				}
				
			case .notInRange:
				subtitle = LocalizableString.FirmwareUpdate.stationNotInRangeDescription.localized
				contactSupportAction = { [weak self] in
					HelperFunctions().openContactSupport(successFailureEnum: .changeFrequency,
														 email: self?.mainVM.userInfo?.email,
														 serialNumber: self?.device.label,
														 errorString: LocalizableString.FirmwareUpdate.stationNotInRangeTitle.localized)
				}
			case .connect:
				let linkString = "[\(LocalizableString.ClaimDevice.failedTroubleshootingTextLinkTitle.localized)](\(DisplayedLinks.heliumTroubleshooting.linkURL))"
				subtitle = LocalizableString.FirmwareUpdate.failedStationConnectionDescription(linkString, LocalizableString.ClaimDevice.failedTextLinkTitle.localized).localized
				contactSupportAction = { [weak self] in
					HelperFunctions().openContactSupport(successFailureEnum: .changeFrequency,
														 email: self?.mainVM.userInfo?.email,
														 serialNumber: self?.device.label,
														 errorString: LocalizableString.FirmwareUpdate.failedToConnectError.localized)
				}
			case .settingFrequency(let errorString):
				subtitle = LocalizableString.deviceInfoStationFrequencyChangeFailureDescription(errorString ?? "-").localized
				contactSupportAction = { [weak self] in
					HelperFunctions().openContactSupport(successFailureEnum: .changeFrequency,
														 email: self?.mainVM.userInfo?.email,
														 serialNumber: self?.device.label,
														 errorString: errorString ?? "-")
				}
			case .unknown:
				return
				
        }

        let obj = FailSuccessStateObject(type: .changeFrequency,
                                         title: title,
                                         subtitle: subtitle.attributedMarkdown,
                                         cancelTitle: cancelTitle,
                                         retryTitle: retryTitle,
                                         contactSupportAction: contactSupportAction,
                                         cancelAction: cancelAction,
                                         retryAction: retryAction)
        self.state = .failed(obj)
    }

    func trackViewContentEvent(success: Bool) {
        Logger.shared.trackEvent(.viewContent, parameters: [.contentName: .changeFrequencyResult,
                                                            .contentId: .changeFrequencyResultContentId,
                                                            .success: .custom(success ? "1" : "0")])
    }
}
