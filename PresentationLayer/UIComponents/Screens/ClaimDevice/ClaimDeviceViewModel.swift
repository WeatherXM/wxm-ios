//
//  ClaimDeviceViewModel.swift
//  PresentationLayer
//
//  Created by Manolis Katsifarakis on 1/10/22.
//

import AVFoundation
import Combine
import CoreLocation
import DataLayer
import DomainLayer
import SwiftUI

public final class ClaimDeviceViewModel: NSObject, ObservableObject {
    private static let LOCATION_UPDATE_DEBOUNCE_TIME_SECONDS = 0.2
    private static let CLAIMING_RETRIES_MAX = 25 // For 2 minutes timeout
    private static let CLAIMING_RETRIES_DELAY_SECONDS: TimeInterval = 5

    private let devicesUseCase: DevicesUseCase
    private let deviceLocationUseCase: DeviceLocationUseCase
    private let meUseCase: MeUseCase

    private var cancellableSet: Set<AnyCancellable> = []
    private var claimCancellable: AnyCancellable?
    private var locationUpdateCancellable: AnyCancellable?

    var isM5: Bool = false

    @Published var device = HeliumDevice(devEUI: "", deviceKey: "")
    @Published var serialNumber = ""

    // Claiming
    enum ClaimState: Equatable {
        typealias ClaimErrorTuple = (message: String, backendId: String?)

        static func == (lhs: ClaimDeviceViewModel.ClaimState, rhs: ClaimDeviceViewModel.ClaimState) -> Bool {
            switch (lhs, rhs) {
                case (.idle, .idle):
                    return true
                case (.claiming, .claiming):
                    return true
                case let (.success(lhsResponse, _), .success(rhsResponse, _)):
                    return lhsResponse?.id == rhsResponse?.id
                case (.failed, .failed):
                    return true
                case (.connectionError, .connectionError):
                    return true
                case (.rebooting, .rebooting):
                    return true
                case (.settingFrequency, .settingFrequency):
                    return true
                default:
                    return false
            }
        }

        case idle
        case settingFrequency
        case rebooting
        case claiming
        case connectionError
        case success(DeviceDetails?, UserDeviceFollowState?)
        case failed(ClaimErrorTuple)
    }

    @Published var claimState: ClaimState = .idle {
        didSet {
            print(claimState)
        }
    }

    @Published var shouldExitClaimFlow = false

    private var claimWorkItem: DispatchWorkItem?

    // Camera
    @Published var hasRetrievedCameraPermission = false
    @Published var hasCameraPermission = false

    // Bluetooth
    /// Toggle to show the claim sheet
    var toggleShowClaimSheet = false
    @Published var isBluetoothReady: Bool = false
    @Published var isScanning: Bool = false

    @Published var bluetoothState: BluetoothState = .unknown
    @Published var devices: [BTWXMDevice] = []

    @Published var heliumDeviceInformation: HeliumDevice?
    @Published var selectedBluetoothDevice: BTWXMDevice?

    @Published var pendingConnectionDevice: BTWXMDevice?

    // Location

    @Published var selectedCoordinates = CLLocationCoordinate2D() {
        didSet {
            currentLocationCoordinatesUpdated()
        }
    }

    @Published var locationSearchQuery = "" {
        didSet {
            deviceLocationUseCase.searchFor(locationSearchQuery)
        }
    }

    @Published var locationSearchResults: [DeviceLocationSearchResult] = []
    @Published var selectedLocation: DeviceLocation? {
        didSet {
            didSelectFrequencyFromLocation = false
        }
    }

    @Published var isLocationAcknowledged = false

    // Frequency
    @Published var isSelectingFrequency = false
    @Published var didSelectFrequency = false
    @Published var errorSettingFrequency = false

    @Published var selectedFrequency: Frequency?
    @Published var preSelectedFrequency: Frequency = .US915
    @Published var didSelectFrequencyFromLocation = false
    @Published var isFrequencyAcknowledged = false

	public init(devicesUseCase: DevicesUseCase,
				deviceLocationUseCase: DeviceLocationUseCase,
				meUseCase: MeUseCase) {
        self.devicesUseCase = devicesUseCase
        self.deviceLocationUseCase = deviceLocationUseCase
        self.meUseCase = meUseCase

        super.init()

        deviceLocationUseCase.searchResults.sink { [weak self] results in
            guard let self = self else { return }
            self.locationSearchResults = results
        }.store(in: &cancellableSet)

        deviceLocationUseCase.error.sink { error in
            print(error)
        }.store(in: &cancellableSet)

        devicesUseCase.bluetoothState.sink { [weak self] state in
            guard let self = self else { return }
            self.bluetoothState = state
            switch state {
                case .unsupported, .unauthorized, .poweredOff, .unknown, .resetting:
                    self.isBluetoothReady = false
                case .poweredOn:
                    self.isBluetoothReady = true
                    self.startScanning()
            }
        }.store(in: &cancellableSet)

        devicesUseCase.bluetoothDevices.sink { [weak self] devices in
            guard let self = self else { return }
            self.devices = devices
        }.store(in: &cancellableSet)

        devicesUseCase.bluetoothDeviceState.sink { [weak self] helperState in
            guard let self = self else { return }
            switch helperState {
                case .idle:
                    self.isSelectingFrequency = false
                    self.didSelectFrequency = false
                    self.errorSettingFrequency = false
                case .connected:
                    self.isSelectingFrequency = false
                    self.didSelectFrequency = false
                    self.errorSettingFrequency = false
                    self.selectedBluetoothDevice = self.pendingConnectionDevice
                    self.pendingConnectionDevice = nil
                case .settingFrequency:
                    self.isSelectingFrequency = true
                    self.didSelectFrequency = false
                    self.errorSettingFrequency = false
                    self.claimState = .settingFrequency
                case .frequencySetSuccess:
                    self.isSelectingFrequency = false
                    self.didSelectFrequency = true
                    self.errorSettingFrequency = false
                    self.rebootStation()
                case .frequencySetError:
                    self.isSelectingFrequency = false
                    self.didSelectFrequency = false
                    self.errorSettingFrequency = true
                case .communicatingWithDevice:
                    break
                case .connectionError:
                    self.isSelectingFrequency = false
                    self.errorSettingFrequency = false
                    self.claimState = .connectionError
                    self.toggleShowClaimSheet.toggle()
                    self.pendingConnectionDevice = nil
                case let .success(heliumDevice):
                    self.isSelectingFrequency = false
                    self.didSelectFrequency = false
                    self.errorSettingFrequency = false
                    self.heliumDeviceInformation = heliumDevice
                    self.claimDevice()
                case .rebooting:
                    self.claimState = .rebooting
                case .rebootingError:
                    self.isSelectingFrequency = false
                    self.errorSettingFrequency = false
                    self.claimState = .connectionError
                case .rebootingSuccess:
                    self.fetchInfo()
                case let .error(error):
                    self.pendingConnectionDevice = nil
                    self.isSelectingFrequency = false
                    self.errorSettingFrequency = false
                    let validStates: [ClaimState] = [.claiming, .rebooting, .settingFrequency]
                    if validStates.contains(self.claimState) {
                        self.claimState = .failed((error.code, nil))
                    }
                    print(error)
            }
            print(helperState)
        }.store(in: &cancellableSet)
    }

    func reset() {
        claimState = .idle
        shouldExitClaimFlow = false

        pendingConnectionDevice = nil
        selectedBluetoothDevice = nil
        heliumDeviceInformation = nil

        locationSearchQuery = ""
        locationSearchResults = []
        selectedLocation = nil

        isLocationAcknowledged = false

        isSelectingFrequency = false
        didSelectFrequency = false
        errorSettingFrequency = false

        selectedFrequency = nil

        preSelectedFrequency = .US915
        isFrequencyAcknowledged = false
        didSelectFrequencyFromLocation = false
    }

    func handleContactSupportTap(userEmail: String?) {
        var errorString = ""
        switch claimState {
            case .idle, .settingFrequency, .rebooting, .claiming, .success:
                break
            case .connectionError:
                errorString = LocalizableString.ClaimDevice.connectionFailedTitle.localized
            case let .failed(error):
                errorString = "\(error.message)(\(error.backendId ?? "-"))"
        }
		
        HelperFunctions().openContactSupport(successFailureEnum: .claimDeviceFlow,
											 email: userEmail,
											 serialNumber: heliumDeviceInformation?.devEUI,
											 errorString: errorString)
    }

    // MARK: - Validation

    func isHeliumDeviceDevEUIValid(_ devEUI: String) -> Bool {
        return devicesUseCase.isHeliumDeviceDevEUIValid(devEUI)
    }

    func isHeliumDeviceKeyValid(_ key: String) -> Bool {
        return devicesUseCase.isHeliumDeviceKeyValid(key)
    }

    func isSelectedLocationValid() -> Bool {
        deviceLocationUseCase.areLocationCoordinatesValid(LocationCoordinates.fromCLLocationCoordinate2D(selectedCoordinates))
    }

    // MARK: - Bluetooth

    func enableBluetooth() {
        devicesUseCase.enableBluetooth()
    }

    func startScanning() {
        isScanning = true
        devicesUseCase.startBluetoothScanning()
    }

    func stopScanning() {
        isScanning = false
        devicesUseCase.stopBluetoothScanning()
    }

    private func fetchInfo() {
        guard let selectedBluetoothDevice else {
            claimState = .failed((LocalizableString.ClaimDevice.errorGeneric.localized, nil))
            return
        }
        devicesUseCase.fetchDeviceInfo(selectedBluetoothDevice)
    }

    func selectDevice(_ device: BTWXMDevice) {
        pendingConnectionDevice = device
        devicesUseCase.connect(device: device)
    }

    // MARK: - Frequency

    func setFrequencyAndClaimSelectedDevice() {
        #if targetEnvironment(simulator)
            var response = DeviceDetails.emptyDeviceDetails
            response.id = "debug-station-id"
            response.name = "Debug station"
            response.label = "Debug station"
            claimState = .success(response, nil)
        #else
            setFrequency()
        #endif
    }

    private func setFrequency() {
        guard let selectedBluetoothDevice,
              let selectedFrequency = selectedFrequency
        else {
            claimState = .failed((LocalizableString.ClaimDevice.errorGeneric.localized, nil))
            return
        }

        devicesUseCase.setHeliumFrequencyViaBluetooth(selectedBluetoothDevice, frequency: selectedFrequency)
    }

    // MARK: - Device reboot

    func rebootStation() {
        guard let selectedBluetoothDevice else {
            claimState = .failed((LocalizableString.ClaimDevice.errorGeneric.localized, nil))
            return
        }
        devicesUseCase.reboot(device: selectedBluetoothDevice)
    }

    // MARK: - Device claiming

    func claimDevice() {
        startClaimingFlow()
        performPersistentClaimDeviceCall(retries: 0)
    }

    func cancelClaim() {
        disconnect()
        devicesUseCase.cancelReboot()
        claimCancellable?.cancel()
        claimWorkItem?.cancel()
        claimState = .idle
    }

    func disconnect() {
        if let selectedBluetoothDevice {
            devicesUseCase.disconnect(device: selectedBluetoothDevice)
        }
    }

    // MARK: - Camera

    func requestCameraPermission() {
        AVCaptureDevice.requestAccess(for: .video) { [weak self] accessGranted in
            DispatchQueue.main.async { [weak self] in
                self?.hasRetrievedCameraPermission = true
                self?.hasCameraPermission = accessGranted
            }
        }
    }

    // MARK: - Location

    func moveToDetectedLocation() {
        Task {
            let result = await deviceLocationUseCase.getUserLocation()
            DispatchQueue.main.async {
                switch result {
                    case .success(let coordinates):
                        self.selectedCoordinates = coordinates
                    case .failure(let error):
                        switch error {
                            case .locationNotFound:
                                Toast.shared.show(text: error.description.attributedMarkdown ?? "")
                            case .permissionDenied:
                                let title = LocalizableString.ClaimDevice.confirmLocationNoAccessToServicesTitle.localized
                                let message = LocalizableString.ClaimDevice.confirmLocationNoAccessToServicesText.localized
                                let alertObj = AlertHelper.AlertObject.getNavigateToSettingsAlert(title: title,
                                                                                                  message: message)
                                AlertHelper().showAlert(alertObj)
                        }
                }
            }
        }
    }

    func moveToLocationFromSearchResult(_ result: DeviceLocationSearchResult) {
        locationSearchQuery = result.description
        deviceLocationUseCase.locationFromSearchResult(result)
            .sink { [weak self] location in
                guard let self = self else { return }
                self.selectedCoordinates = location.coordinates.toCLLocationCoordinate2D()
            }
            .store(in: &cancellableSet)
    }

    private var locationUpdateWorkItem: DispatchWorkItem?
    typealias CountryCodeFrequency = [String: Frequency?]
    private var _countryCodeFrequency: CountryCodeFrequency?
    func updateFrequencyFromCurrentLocationCountry() {
        guard
            let countryCode = selectedLocation?.countryCode?.uppercased(),
            let frequencyForCurrentCountry = countryCodeFrequencies()
            .first(where: { $0.key.uppercased() == countryCode })?.value
        else {
            preSelectedFrequency = .US915
            selectedFrequency = preSelectedFrequency
            print("Cannot find frequency for current location.")
            return
        }

        didSelectFrequencyFromLocation = true
        preSelectedFrequency = frequencyForCurrentCountry
        selectedFrequency = preSelectedFrequency
    }

    func showInvalidLocationToast() {
        Toast.shared.show(text: LocalizableString.invalidLocationErrorText.localized.attributedMarkdown ?? "")
    }
}

private extension ClaimDeviceViewModel {
    // MARK: Location

    func currentLocationCoordinatesUpdated() {
        selectedLocation = nil
        locationUpdateCancellable?.cancel()
        locationUpdateWorkItem?.cancel()
        let locationUpdateWorkItem = DispatchWorkItem(block: { [weak self] in
            guard let self = self else { return }

            self.locationUpdateCancellable = self.deviceLocationUseCase.locationFromCoordinates(
                LocationCoordinates.fromCLLocationCoordinate2D(self.selectedCoordinates)
            )
            .sink { [weak self] location in
                self?.selectedLocation = location
            }
        })
        self.locationUpdateWorkItem = locationUpdateWorkItem

        DispatchQueue.main.asyncAfter(
            deadline: .now() + Self.LOCATION_UPDATE_DEBOUNCE_TIME_SECONDS,
            execute: locationUpdateWorkItem
        )
    }

    // MARK: Frequency

    func countryCodeFrequencies() -> CountryCodeFrequency {
        if let _frequencyCountryCodes = _countryCodeFrequency {
            return _frequencyCountryCodes
        }

		let countryInfos = deviceLocationUseCase.getCountryInfos()
		_countryCodeFrequency = countryInfos?.reduce([String: Frequency?]()) { result, info in
			var result = result
			result[info.code] = Frequency(rawValue: info.heliumFrequency ?? "")
			return result
		}

        return _countryCodeFrequency!
    }

    // MARK: Device claiming

    func startClaimingFlow() {
        claimCancellable?.cancel()
        claimState = .claiming
    }

    func performPersistentClaimDeviceCall(retries: Int) {
        guard let heliumDeviceInformation = heliumDeviceInformation else {
            claimState = .failed((LocalizableString.ClaimDevice.errorGeneric.localized, nil))
            return
        }

        do {
            let claimDeviceBody = ClaimDeviceBody(
                serialNumber: heliumDeviceInformation.devEUI.replacingOccurrences(of: ":", with: ""),
                location: selectedCoordinates,
                secret: !heliumDeviceInformation.deviceKey.isEmpty
                    ? heliumDeviceInformation.deviceKey
                    : nil
            )

            claimCancellable = try meUseCase.claimDevice(claimDeviceBody: claimDeviceBody)
                .sink { [weak self] response in
                    guard let self = self else { return }
                    switch response {
                        case.failure(let responseError):
                            if responseError.backendError?.code == FailAPICodeEnum.deviceClaiming.rawValue,
                               retries < Self.CLAIMING_RETRIES_MAX {
                                print("Claiming Failed with \(responseError). Retrying after 5 seconds...")

                                // Still claiming.
                                self.claimWorkItem?.cancel()
                                let claimWorkItem = DispatchWorkItem { [weak self] in
                                    self?.performPersistentClaimDeviceCall(retries: retries + 1)
                                }
                                self.claimWorkItem = claimWorkItem

                                DispatchQueue.main.asyncAfter(
                                    deadline: .now() + Self.CLAIMING_RETRIES_DELAY_SECONDS,
                                    execute: claimWorkItem
                                )

                                return
                            }

                            self.claimState = .failed(
                                (self.errorMessageForNetworkErrorResponse(responseError), responseError.backendError?.id)
                            )

                        case .success(let deviceResponse):
                            Task { @MainActor in
                                var followState: UserDeviceFollowState?
                                if let deviceId = deviceResponse.id {
                                    followState = try? await self.meUseCase.getDeviceFollowState(deviceId: deviceId).get()
                                }
                                self.claimState = .success(deviceResponse, followState)
                            }
                    }
                }
        } catch {
            claimState = .failed((LocalizableString.ClaimDevice.errorGeneric.localized, nil))
        }
    }

    func errorMessageForNetworkErrorResponse(_ response: NetworkErrorResponse) -> String {
        if let error = (response.initialError.underlyingError as? URLError) {
            if error.code == .notConnectedToInternet {
                return LocalizableString.ClaimDevice.errorNoInternet.localized
            } else if error.code == .timedOut {
                return LocalizableString.ClaimDevice.errorConnectionTimeOut.localized
            } else {
                return LocalizableString.ClaimDevice.errorGeneric.localized
            }
        } else if response.backendError?.code == FailAPICodeEnum.invalidClaimId.rawValue {
            if isM5 {
                return LocalizableString.ClaimDevice.errorInvalidIdM5.localized
            }

            return LocalizableString.ClaimDevice.errorInvalidId.localized
        } else if response.backendError?.code == FailAPICodeEnum.invalidClaimLocation.rawValue {
            return LocalizableString.ClaimDevice.errorInvalidLocation.localized
        } else if response.backendError?.code == FailAPICodeEnum.deviceAlreadyClaimed.rawValue {
            return LocalizableString.ClaimDevice.alreadyClaimed.localized
        } else if response.backendError?.code == FailAPICodeEnum.deviceNotFound.rawValue {
            return LocalizableString.ClaimDevice.notFound.localized
        } else if response.backendError?.code == FailAPICodeEnum.deviceClaiming.rawValue {
            if isM5 {
                return LocalizableString.ClaimDevice.claimingErrorM5.localized
            }

            return LocalizableString.ClaimDevice.claimingError.localized
        }

        return LocalizableString.ClaimDevice.errorGeneric.localized
    }
}

extension LocationCoordinates {
    func toCLLocationCoordinate2D() -> CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }
}

extension CLLocationCoordinate2D {
    var isSet: Bool {
        return latitude != 0 && longitude != 0
    }
}
