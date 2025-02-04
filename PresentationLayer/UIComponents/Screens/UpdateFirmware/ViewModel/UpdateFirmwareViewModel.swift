//
//  UpdateFirmwareViewModel.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 3/2/23.
//

import Combine
import DataLayer
import DomainLayer
import Foundation
import UIKit
import Toolkit

@MainActor
class UpdateFirmwareViewModel: ObservableObject {
    let topTitle: String?
    let topSubtitle: String?
    @Published var title: String = ""
    @Published var subtile: AttributedString?
    @Published var steps: [StepsView.Step] = []
    @Published var progress: UInt?
    @Published var currentStepIndex: Int?
    @Published var state: State = .installing
    let navigationTitle = LocalizableString.FirmwareUpdate.title.localized
    var mainVM: MainScreenViewModel?

    private var device: DeviceDetails?
    private let firmwareUseCase: UpdateFirmwareUseCase?
    private let successCallback: (() -> Void)?
    private let cancelCallback: (() -> Void)?
    private var cancellableSet: Set<AnyCancellable> = []
    private let scanningTimeout: TimeInterval = 10.0
    private var scanningTimeoutWorkItem: DispatchWorkItem?
    private var started: Bool {
        currentStepIndex != nil
    }

    init(useCase: UpdateFirmwareUseCase? = .init(firmwareRepository: FirmwareUpdateImpl()),
		 device: DeviceDetails,
		 successCallback: (() -> Void)? = nil,
		 cancelCallback: (() -> Void)? = nil) {
        self.firmwareUseCase = useCase
        self.device = device
        self.successCallback = successCallback
        self.cancelCallback = cancelCallback

		self.topTitle = LocalizableString.DeviceInfo.stationInfoFirmwareVersion.localized
        self.topSubtitle = device.firmware?.versionUpdateString
        generateSteps()
        firmwareUseCase?.enableBluetooth()
        retry()
    }

    func navigationBackButtonTapped() {
        stopScanning()
        firmwareUseCase?.stopDeviceFirmwareUpdate()
    }
}

private extension UpdateFirmwareViewModel {
    /// Resets the UI state and starts the flow from the beginning
    func retry() {
        cancellableSet.forEach { $0.cancel() }
        cancellableSet.removeAll()
        reset()
        observeBluetoothState()
    }

    /// Starts the update firmware process for the specific BT device
    /// - Parameter device: The device to update firmware
    func startFirmwareUpdate(device: BTWXMDevice) {
        guard let firmwareDeviceId = self.device?.id, !started else {
            return
        }

        UIApplication.shared.isIdleTimerDisabled = true
        let publisher = firmwareUseCase?.updateDeviceFirmware(device: device, firmwareDeviceId: firmwareDeviceId)
		publisher?.receive(on: DispatchQueue.main).sink { [weak self] state in
			self?.handleState(state: state)
        }.store(in: &cancellableSet)
    }

    /// Observe changes in scanned devices list to find which one is refering to the current `device`.
    /// Once the BT device is found we the firmware update process
    func observeBluetoothDevices() {
        firmwareUseCase?.bluetoothDevices.sink { [weak self] btDevices in
            guard let self = self,
                  let device = self.device,
                  let btDevice = btDevices.first(where: { $0.isSame(with: device) })
            else {
                return
            }
            self.stopScanning()
            self.startFirmwareUpdate(device: btDevice)
        }.store(in: &cancellableSet)
    }

    /// Observe changes in BT state. Once is `.poweredOn` we launch the process
    func observeBluetoothState() {
        firmwareUseCase?.bluetoothState.sink { [weak self] state in
            guard let self = self else { return }

            var errorDescription = ""

            switch state {
                case .unknown:
                    return
                case .unsupported:
                    errorDescription = LocalizableString.Bluetooth.unsupportedTitle.localized
                case .unauthorized:
                    errorDescription = LocalizableString.Bluetooth.noAccessTitle.localized
                case .poweredOff:
                    errorDescription = LocalizableString.Bluetooth.title.localized
                case .poweredOn, .resetting:
                    // Once the BT is available we start the process
                    self.observeBluetoothDevices()
                    self.startScanning()
                    return
            }

            let finishedObject = FailSuccessStateObject(type: .otaFlow,
                                                        title: LocalizableString.FirmwareUpdate.failureTitle.localized,
                                                        subtitle: errorDescription.attributedMarkdown,
                                                        cancelTitle: LocalizableString.cancel.localized,
                                                        retryTitle: LocalizableString.FirmwareUpdate.failureButtonTitle.localized,
                                                        contactSupportAction: { [weak self] in
				HelperFunctions().openContactSupport(successFailureEnum: .otaFlow,
													 email: self?.mainVM?.userInfo?.email,
													 serialNumber: self?.device?.label,
													 errorString: errorDescription)
            },
                                                        cancelAction: self.cancelCallback,
                                                        retryAction: { [weak self] in self?.retry() })

            DispatchQueue.main.async {
                self.state = .failed(finishedObject)
            }
        }.store(in: &cancellableSet)
    }

    /// Starts the scannig to find the correct BT device. The list is getting observed in `observeBluetoothDevices`
    /// The scanning stops after `scanningTimeout` seconds and if no device found we show a failed view
    func startScanning() {
        scanningTimeoutWorkItem?.cancel()
        scanningTimeoutWorkItem = DispatchWorkItem { [weak self] in
            self?.stopScanning()
            self?.showNotInRangeErrorView()
        }

        firmwareUseCase?.startBluetoothScanning()
        DispatchQueue.main.asyncAfter(deadline: .now() + scanningTimeout, execute: scanningTimeoutWorkItem!)
    }

    /// Stops the scanning for devices
    func stopScanning() {
        scanningTimeoutWorkItem?.cancel()
        firmwareUseCase?.stopBluetoothScanning()
    }

    /// Resets all the required fields
    func reset() {
        state = .installing
        title = ""
        subtile = nil
        currentStepIndex = nil
        progress = nil
        markCompletedSteps()
    }

    /// Updates the UI state according to the firmware state updates
    /// - Parameter state: The state to be handled
    func handleState(state: FirmwareUpdateState) {
        switch state {
            case .unknown:
                break
            case .connecting:
                self.state = .installing
                title = LocalizableString.FirmwareUpdate.titleConnecting.localized
                subtile = nil
                currentStepIndex = Step.connect.rawValue
                progress = nil
            case .downloading:
                self.state = .installing
                title = LocalizableString.FirmwareUpdate.titleDownloading.localized
                subtile = LocalizableString.FirmwareUpdate.descriptionDownloading.localized.attributedMarkdown
                currentStepIndex = Step.download.rawValue
                progress = nil
            case let .installing(progress: progress):
                self.state = .installing
                title = LocalizableString.FirmwareUpdate.titleInstalling.localized
                subtile = LocalizableString.FirmwareUpdate.descriptionInstalling.localized.attributedMarkdown
                currentStepIndex = Step.install.rawValue
                self.progress = UInt(progress)
            case .finished:
				showFinishedState()
            case let .error(error):
				trackErrorEvents(error: error)
                handleError(error)
        }

        markCompletedSteps()
    }

	func showFinishedState() {
		let finishedObject = FailSuccessStateObject(type: .otaFlow,
													title: LocalizableString.FirmwareUpdate.successTitle.localized,
													subtitle: LocalizableString.FirmwareUpdate.successDescription.localized.attributedMarkdown,
													cancelTitle: nil,
													retryTitle: LocalizableString.FirmwareUpdate.successButtonTitle.localized,
													contactSupportAction: nil,
													cancelAction: cancelCallback,
													retryAction: { [weak self] in
			self?.successCallback?()
		})

		self.state = .success(finishedObject)
		UIApplication.shared.isIdleTimerDisabled = false
		if let deviceId = device?.id, let version = device?.firmware?.current {
			mainVM?.firmwareUpdated(for: deviceId, version: version)
		}
		WXMAnalytics.shared.trackEvent(.viewContent, parameters: [.contentName: .OTAResult,
															.contentId: .otaResultContentId,
															.itemId: .custom(device?.id ?? ""),
															.success: .custom("1")])
	}

	func trackErrorEvents(error: FirmwareUpdateError) {
		var params: [Parameter: ParameterValue] = [.contentName: .OTAError,
												   .contentId: .failureOtaContentId,
												   .itemId: .custom(device?.id ?? "")]
		if let currentStepIndex, let step = Step(rawValue: currentStepIndex) {
			params += [.step: step.analyticsValue]
		}
		WXMAnalytics.shared.trackEvent(.viewContent, parameters: params)

		WXMAnalytics.shared.trackEvent(.viewContent, parameters: [.contentName: .OTAResult,
															.contentId: .otaResultContentId,
															.itemId: .custom(device?.id ?? ""),
															.success: .custom("0")])
	}

    /// Updates the UI state according to the firmware update error
    /// - Parameter error: The error to be handled
    func handleError(_ error: FirmwareUpdateError) {
        let finishedObject = FailSuccessStateObject(type: .otaFlow,
                                                    title: error.title,
                                                    subtitle: error.description.attributedMarkdown,
                                                    cancelTitle: LocalizableString.cancel.localized,
                                                    retryTitle: LocalizableString.FirmwareUpdate.failureButtonTitle.localized,
                                                    contactSupportAction: { [weak self] in
			HelperFunctions().openContactSupport(successFailureEnum: .otaFlow,
												 email: self?.mainVM?.userInfo?.email,
												 serialNumber: self?.device?.label,
												 errorString: error.errorString)
        },
                                                    cancelAction: cancelCallback,
                                                    retryAction: { [weak self] in self?.retry() })

        state = .failed(finishedObject)
        UIApplication.shared.isIdleTimerDisabled = false
    }

    /// The process steps
    func generateSteps() {
        let steps = Step.allCases.map { StepsView.Step(text: $0.description, isCompleted: false) }
        self.steps = steps
    }

    /// Marks all the completed steps in `steps` array
    func markCompletedSteps() {
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

    func showNotInRangeErrorView() {
        let finishedObject = FailSuccessStateObject(type: .otaFlow,
                                                    title: LocalizableString.FirmwareUpdate.stationNotInRangeTitle.localized,
                                                    subtitle: LocalizableString.FirmwareUpdate.stationNotInRangeDescription.localized.attributedMarkdown,
                                                    cancelTitle: LocalizableString.cancel.localized,
                                                    retryTitle: LocalizableString.FirmwareUpdate.failureButtonTitle.localized,
                                                    contactSupportAction: { [weak self] in
			HelperFunctions().openContactSupport(successFailureEnum: .otaFlow,
												 email: self?.mainVM?.userInfo?.email,
												 serialNumber: self?.device?.label,
												 errorString: LocalizableString.FirmwareUpdate.stationNotInRangeTitle.localized)
		},
													cancelAction: cancelCallback,
													retryAction: { [weak self] in self?.retry() })

		state = .failed(finishedObject)
	}
}
