//
//  FirmwareUpdater.swift
//  DataLayer
//
//  Created by Pantelis Giazitsis on 2/2/23.
//

import Combine
import CoreBluetooth.CBPeripheral
import DomainLayer
import Foundation
import NordicDFU

class FirmwareUpdater {
    private let firmware: DFUFirmware
    private let initiator: DFUServiceInitiator
    private let btDeviceId: UUID
    private var controller: DFUServiceController?

    public let state: AnyPublisher<State, Never>
    private let stateSubject = CurrentValueSubject<State, Never>(.idle)

    private var cancellableSet: Set<AnyCancellable> = []

    /// Crates a new instance. Returns `nil` if some mandatory operations are failed (eg. `DFUFirmware` creation from the passed file url)
    /// - Parameters:
    ///   - fileUrl: The zip files url
    ///   - peripheral: The `BTWXMDevice` where should the firmware should be installed
    init?(fileUrl: URL, btDevice: BTWXMDevice) {
        do {
            firmware = try DFUFirmware(urlToZipFile: fileUrl)
        } catch {
            return nil
        }

        btDeviceId = btDevice.identifier

        state = stateSubject.eraseToAnyPublisher()

        initiator = DFUServiceInitiator().with(firmware: firmware)
        initiator.logger = self
        initiator.delegate = self
        initiator.progressDelegate = self
    }

    /// Starts the installation process
    func start() {
        if let controller, controller.paused == false, controller.aborted == false {
            return
        }

        controller = initiator.start(targetWithIdentifier: btDeviceId)
    }

    /// Stops the installation process
    func stop() {
        _ = controller?.abort()
    }
}

extension FirmwareUpdater: LoggerDelegate {
    func logWith(_ level: NordicDFU.LogLevel, message: String) {
        print("\(level.name()): \(message)")
    }
}

extension FirmwareUpdater: DFUServiceDelegate {
    func dfuStateDidChange(to state: NordicDFU.DFUState) {
        debugPrint(state.description)

        if let state = State(from: state) {
            stateSubject.send(state)
        }
    }

    func dfuError(_ error: NordicDFU.DFUError, didOccurWithMessage message: String) {
        debugPrint("Error: \(error): \(message)")
        stateSubject.send(.aborted("\(message) (\(error.rawValue))"))
    }
}

extension FirmwareUpdater: DFUProgressDelegate {
    func dfuProgressDidChange(for _: Int, outOf _: Int, to progress: Int, currentSpeedBytesPerSecond _: Double, avgSpeedBytesPerSecond _: Double) {
        debugPrint("Installation progress: \(progress)")
        stateSubject.send(.progress(progress))
    }
}

extension FirmwareUpdater {
    /// The udpatere state representation
    enum State {
        case idle
        case connecting
        case starting
        case progress(Int)
        case completed
        case aborted(String?)

        /// Maps the `DFUState` to `FirmwareUpdater.State`
        /// - Parameter dfuState: The reqeusted `DFUState`
        init?(from dfuState: NordicDFU.DFUState) {
            switch dfuState {
            case .connecting:
                self = .connecting
            case .starting, .uploading:
                self = .starting
            case .enablingDfuMode, .validating, .disconnecting:
                return nil
            case .completed:
                self = .completed
            case .aborted:
                self = .aborted(nil)
            }
        }
    }
}
