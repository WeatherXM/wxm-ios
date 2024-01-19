//
//  DeviceInfoViewModel.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 7/3/23.
//

import Foundation
import DomainLayer
import Combine
import Toolkit
import UIKit

class DeviceInfoViewModel: ObservableObject {

    let offestObject = TrackableScrollOffsetObject()
	let mainVM: MainScreenViewModel = .shared
    var sections: [[DeviceInfoRowView.Row]] {
        var fields: [[Field]] = []
        switch device.profile {
            case .helium:
                fields = Field.heliumSections(for: followState)
            case .m5, .none:
                fields = Field.m5Sections(for: followState)
        }

        let rows: [[DeviceInfoRowView.Row]] = fields.map { $0.map { field in
            DeviceInfoRowView.Row(title: field.titleFor(devie: device),
								  description: field.descriptionFor(device: device, for: followState).attributedMarkdown ?? "",
								  imageUrl: field.imageUrlFor(device: device, followState: followState),
                                  buttonInfo: field.buttonInfoFor(devie: device, followState: followState),
                                  warning: field.warning,
                                  buttonAction: { [weak self] in self?.handleButtonTap(field: field) })
            }
        }

        return rows
    }

	var bottomSections: [[DeviceInfoRowView.Row]] {
		let fields = Field.bottomSections(for: followState)
		let rows: [[DeviceInfoRowView.Row]] = fields.map { $0.map { field in
			DeviceInfoRowView.Row(title: field.titleFor(devie: device),
								  description: field.descriptionFor(device: device, for: followState).attributedMarkdown ?? "",
								  imageUrl: field.imageUrlFor(device: device, followState: followState),
								  buttonInfo: field.buttonInfoFor(devie: device, followState: followState),
								  warning: field.warning,
								  buttonAction: { [weak self] in self?.handleButtonTap(field: field) })
			}
		}

		return rows
	}

    var infoRows: [StationInfoView.Row] {
        var fields: [InfoField] = []
        switch device.profile {
            case .helium:
                fields = InfoField.heliumFields
            case .m5, .none:
                fields = InfoField.m5Fields
        }

        let infoRows: [StationInfoView.Row] = fields.compactMap { field in
            guard let value = field.value(for: device,
                                          deviceInfo: deviceInfo,
                                          mainVM: mainVM,
                                          followState: followState) else {
                return nil
            }

            let buttonInfo: DeviceInfoButtonInfo? = field.button(for: device, mainVM: mainVM, followState: followState)
            let warning = field.warning(for: device, deviceInfo: deviceInfo)

			let row = StationInfoView.Row(tile: field.title,
										  subtitle: value,
										  warning: warning,
										  buttonIcon: buttonInfo?.icon,
										  buttonTitle: buttonInfo?.title,
										  buttonStyle: buttonInfo?.buttonStyle ?? .init()) { [weak self] in
                self?.handleInfoFieldButtonTap(infoField: field)
            }
            return row
        }

        return infoRows
    }

    @Published var isLoading: Bool = true
    @Published var isFailed: Bool = false
    var failObj: FailSuccessStateObject?
    @Published private(set) var device: DeviceDetails
    @Published private(set) var deviceInfo: NetworkDevicesInfoResponse?
    let followState: UserDeviceFollowState?
    @Published var showRebootStation = false
    var rebootStationViewModel: RebootStationViewModel {
        RebootStationViewModel(device: device, useCase: deviceInfoUseCase)
    }
    @Published var showChangeFrequency = false
    var changeFrequencyViewModel: ChangeFrequencyViewModel {
        ChangeFrequencyViewModel(device: device, useCase: deviceInfoUseCase)
    }

    @Published var showAccountConfirmation = false
    var accountConfirmationViewModel: AccountConfirmationViewModel {
        AccountConfirmationViewModel(title: LocalizableString.confirmPasswordTitle.localized,
                                     descriptionMarkdown: LocalizableString.deviceInfoRemoveStationAccountConfirmationMarkdown.localized,
                                     useCase: SwinjectHelper.shared.getContainerForSwinject().resolve(AuthUseCase.self)) { [weak self] isvalid in
            if isvalid {
                self?.showAccountConfirmation = false
                if let serialNumber = self?.device.convertedLabel {
                    self?.disclaimDevice(serialNumber: serialNumber)
                }
            }
        }
    }
    var contactSupportButtonTitle: String {
        let isFollowed = followState?.relation == .followed
        return isFollowed ? LocalizableString.deviceInfoFollowedContactSupportTitle.localized : LocalizableString.contactSupport.localized
    }

    private let deviceInfoUseCase: DeviceInfoUseCase?
    private var cancellable: Set<AnyCancellable> = []

    init(device: DeviceDetails, followState: UserDeviceFollowState?) {
        self.device = device
        self.followState = followState
        self.deviceInfoUseCase = SwinjectHelper.shared.getContainerForSwinject().resolve(DeviceInfoUseCase.self)
        refresh()
    }

    func handleShareButtonTap() {
        let text = InfoField.getShareText(for: device, deviceInfo: deviceInfo, mainVM: mainVM, followState: followState)
        ShareHelper().showShareDialog(text: text)

        Logger.shared.trackEvent(.userAction, parameters: [.actionName: .shareStationInfo,
                                                           .contentType: .stationInfo,
                                                           .itemId: .custom(device.id ?? "")])
    }

    func handleContactSupportButtonTap() {
        Logger.shared.trackEvent(.selectContent, parameters: [.contentType: .contactSupport,
                                                              .source: .deviceInfoSource])

		HelperFunctions().openContactSupport(successFailureEnum: .weatherStations,
											 email: mainVM.userInfo?.email,
											 serialNumber: device.label,
											 addtionalInfo: InfoField.getShareText(for: device, deviceInfo: deviceInfo, mainVM: mainVM, followState: followState),
											 trackSelectContentEvent: false)
    }

    func refresh(completion: VoidCallback? = nil) {
        guard let deviceId = device.id else {
            return
        }

        do {
            try deviceInfoUseCase?.getDeviceInfo(deviceId: deviceId).sink { [weak self] response in
                completion?()
                self?.isLoading = false
                if let error = response.error {
                    self?.failObj = error.uiInfo.defaultFailObject(type: .deviceInfo) {
                        self?.isFailed = false
                        self?.isLoading = true
                        self?.refresh()
                    }
                    self?.isFailed = true
                }
                self?.deviceInfo = response.value
            }.store(in: &self.cancellable)
        } catch {
            isLoading = false
            print(error)
            completion?()
        }
    }
}

extension DeviceInfoViewModel: HashableViewModel {
    func hash(into hasher: inout Hasher) {
        hasher.combine(device.id)
    }
}

extension DeviceInfoViewModel: SelectStationLocationViewModelDelegate {
	func locationUpdated(with device: DeviceDetails) {
		self.device = device
	}
}

private extension DeviceInfoViewModel {
	func handleButtonTap(field: Field) {
		switch field {
			case .name:
				showChangeNameAlert()
			case .frequency:
				showChangeFrequency = true
			case .reboot:
				showRebootStation = true
			case .maintenance:
				break
			case .remove:
				Logger.shared.trackEvent(.selectContent, parameters: [.contentType: .removeDevice,
																	  .itemId: .custom(device.id ?? "")])
				showAccountConfirmation = true
			case .reconfigureWifi:
				break
			case .stationLocation:
				let viewModel = ViewModelsFactory.getSelectLocationViewModel(device: device, followState: followState, delegate: self)
				Router.shared.navigateTo(.selectStationLocation(viewModel))
		}
	}

    func handleInfoFieldButtonTap(infoField: InfoField) {
        switch infoField {
            case .name:
                break
            case .devEUI:
                break
            case .hardwareVersion:
                break
            case .firmwareVersion:
                mainVM.showFirmwareUpdate(device: device)
            case .lastHotspot:
                break
            case .lastRSSI:
                break
            case .serialNumber:
                break
            case .ATECC:
                break
            case .GPS:
                break
            case .wifiSignal:
                break
            case .batteryState:
                break
            case .claimedAt:
                break
        }
    }

    func showChangeNameAlert() {
        let okAction: AlertHelper.AlertObject.Action = (LocalizableString.save.localized, { [weak self] text in
            guard let self,
                  let deviceId = self.device.id,
                  let text = text?.trimWhiteSpaces(),
                  !text.isEmpty else {
                return
            }

            self.setFriendlyName(deviceId: deviceId, name: text.trimWhiteSpaces())

            Logger.shared.trackEvent(.userAction, parameters: [.actionName: .changeStationNameResult,
                                                               .contentType: .changeStationName,
                                                               .action: .edit])
        })

        let clearAction: AlertHelper.AlertObject.Action = (LocalizableString.clear.localized, { [weak self] _ in
            guard let self,
                  let deviceId = self.device.id else {
                return
            }

            self.deleteFriendlyName(deviceId: deviceId)

            Logger.shared.trackEvent(.userAction, parameters: [.actionName: .changeStationNameResult,
                                                               .contentType: .changeStationName,
                                                               .action: .clear])
        })

        let alertObject = AlertHelper.AlertObject(title: LocalizableString.deviceInfoEditNameAlertTitle.localized,
                                                  message: LocalizableString.deviceInfoEditNameAlertMessage.localized,
                                                  textFieldPlaceholder: Field.name.titleFor(devie: device),
                                                  textFieldValue: device.displayName,
                                                  textFieldDelegate: AlertTexFieldDelegate(),
                                                  cancelAction: {
            Logger.shared.trackEvent(.userAction, parameters: [.actionName: .changeStationNameResult,
                                                               .contentType: .changeStationName,
                                                               .action: .cancel])
        },
                                                  okAction: okAction,
                                                  secondaryActions: [clearAction])
        AlertHelper().showAlert(alertObject)
        // Since we present a system dialog,
        // we track the screen here.
        Logger.shared.trackScreen(.changeStationName, parameters: [.itemId: .custom(device.id ?? "")])
    }

    func setFriendlyName(deviceId: String, name: String) {
        LoaderView.shared.show()
        do {
            try deviceInfoUseCase?.setFriendlyName(deviceId: deviceId, name: name).sink { [weak self] response in
                LoaderView.shared.dismiss {
                    self?.trackChangeNameViewContent(isSuccessful: response.error == nil)

                    if let error = response.error {
                        self?.showErrorToast(error: error) {
                            self?.setFriendlyName(deviceId: deviceId, name: name)
                        }
                        return
                    }
                    self?.device.friendlyName = name
                }
            }.store(in: &self.cancellable)
        } catch {
            LoaderView.shared.dismiss()
        }
    }

    func deleteFriendlyName(deviceId: String) {
        LoaderView.shared.show()
        do {
            try deviceInfoUseCase?.deleteFriendlyName(deviceId: deviceId).sink { [weak self] response in
                LoaderView.shared.dismiss {
                    self?.trackChangeNameViewContent(isSuccessful: response.error == nil)

                    if let error = response.error {
                        self?.showErrorToast(error: error) {
                            self?.deleteFriendlyName(deviceId: deviceId)
                        }
                        return
                    }
                    self?.device.friendlyName = nil
                }
            }.store(in: &self.cancellable)
        } catch {
            LoaderView.shared.dismiss()
        }
    }

    func disclaimDevice(serialNumber: String) {
        LoaderView.shared.show()
        do {
            try deviceInfoUseCase?.disclaimDevice(serialNumber: serialNumber).sink { [weak self] response in
                LoaderView.shared.dismiss {
                    if let error = response.error {
                        self?.showErrorToast(error: error) {
                            self?.disclaimDevice(serialNumber: serialNumber)
                        }
                        return
                    }
                    Router.shared.popToRoot()
                }
            }.store(in: &cancellable)
        } catch {
            LoaderView.shared.dismiss()
        }
    }

    func showErrorToast(error: NetworkErrorResponse, retry: @escaping VoidCallback) {
        guard let message = error.uiInfo.description?.attributedMarkdown else {
            return
        }

        Logger.shared.trackEvent(.viewContent, parameters: [.contentName: .failure,
                                                            .itemId: .custom(error.backendError?.code ?? "")])
        Toast.shared.show(text: message, retryAction: retry)
    }

    func trackChangeNameViewContent(isSuccessful: Bool) {
        Logger.shared.trackEvent(.viewContent, parameters: [.contentName: .changeStationNameResult,
                                                            .contentId: .changeStationNameResultContentId,
                                                            .success: .custom(isSuccessful ? "1" : "0")])
    }
}

private extension DeviceInfoViewModel {
    class AlertTexFieldDelegate: NSObject, UITextFieldDelegate {
        var textLimit: Int? = 64

        func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            guard let textLimit else {
                return true
            }

            let newText = (textField.text as? NSString)?.replacingCharacters(in: range, with: string) ?? ""
            return newText.count <= textLimit
        }
    }
}
