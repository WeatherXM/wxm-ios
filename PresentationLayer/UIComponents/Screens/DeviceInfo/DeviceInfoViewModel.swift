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
import SwiftUI

@MainActor
class DeviceInfoViewModel: ObservableObject {
	
	let mainVM: MainScreenViewModel = .shared
	var sections: [[DeviceInfoRowView.Row]] {
		var fields: [[Field]] = []
		if device.isHelium {
			fields = Field.heliumSections(for: followState, photosState: photoVerificationState)
		} else {
			fields = Field.wifiSections(for: followState, photosState: photoVerificationState)
		}
		
		let rows: [[DeviceInfoRowView.Row]] = fields.map { $0.map { field in
			let title = field.titleFor(devie: device)
			return DeviceInfoRowView.Row(title: title.title,
										 badge: title.badge,
										 description: field.descriptionFor(device: device,
																		   for: followState,
																		   deviceInfo: deviceInfo,
																		   photoVerificationState: photoVerificationState).attributedMarkdown ?? "",
										 imageUrl: field.imageUrlFor(device: device, followState: followState),
										 buttonInfo: field.buttonInfoFor(devie: device,
																		 followState: followState,
																		 photoVerificationState: photoStateViewModel?.state),
										 warning: field.warning,
										 customView: customViewFor(field: field),
										 buttonAction: { [weak self] in self?.handleButtonTap(field: field) })
		}
		}
		
		return rows
	}
	
	var bottomSections: [[DeviceInfoRowView.Row]] {
		let fields = Field.bottomSections(for: followState, deviceInfo: deviceInfo)
		let rows: [[DeviceInfoRowView.Row]] = fields.map { $0.map { field in
			let title = field.titleFor(devie: device)
			return DeviceInfoRowView.Row(title: title.title,
										 badge: title.badge,
										 description: field.descriptionFor(device: device,
																		   for: followState,
																		   deviceInfo: deviceInfo,
																		   photoVerificationState: photoVerificationState).attributedMarkdown ?? "",
										 imageUrl: field.imageUrlFor(device: device, followState: followState),
										 buttonInfo: field.buttonInfoFor(devie: device,
																		 followState: followState,
																		 photoVerificationState: photoStateViewModel?.state),
										 warning: field.warning,
										 customView: customViewFor(field: field),
										 buttonAction: { [weak self] in self?.handleButtonTap(field: field) })
		}
		}
		
		return rows
	}
	
	var infoSections: [StationInfoView.Section] {
		if device.isHelium {
			return [getInfoSection(title: nil, fields: InfoField.heliumFields)]
		} else {
			let sections: [StationInfoView.Section] = [getInfoSection(title: nil, fields: InfoField.wifiInfoFields),
													   getInfoSection(title: LocalizableString.DeviceInfo.gatewayDetails.localized, fields: InfoField.wifiGatewayDetailsInfoFields),
													   getInfoSection(title: LocalizableString.DeviceInfo.stationDetails.localized, fields: InfoField.wifiStationDetailsInfoFields)]
			return sections
		}
	}
	
	@Published var showShareDialog: Bool = false
	private(set) var shareDialogText: String = ""
	@Published var isLoading: Bool = true
	@Published private(set) var device: DeviceDetails
	@Published private(set) var deviceInfo: NetworkDevicesInfoResponse? {
		didSet {
			shareDialogText = InfoField.getShareText(for: device,
													 deviceInfo: deviceInfo,
													 mainVM: mainVM,
													 followState: followState)
		}
	}
	@Published private(set) var photoVerificationState: PhotoVerificationStateView.State?
	let followState: UserDeviceFollowState?
	@Published var showRebootStation = false
	var rebootStationViewModel: RebootStationViewModel {
		RebootStationViewModel(device: device, useCase: deviceInfoUseCase)
	}
	@Published var showChangeFrequency = false
	var changeFrequencyViewModel: ChangeFrequencyViewModel {
		ViewModelsFactory.getChangeFrequencyViewModel(device: device)
	}
	
	@Published var showAccountConfirmation = false
	var accountConfirmationViewModel: AccountConfirmationViewModel {
		AccountConfirmationViewModel(title: LocalizableString.confirmPasswordTitle.localized,
									 descriptionMarkdown: LocalizableString.DeviceInfo.removeStationAccountConfirmationMarkdown.localized,
									 useCase: SwinjectHelper.shared.getContainerForSwinject().resolve(AuthUseCaseApi.self)) { [weak self] isvalid in
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
		return isFollowed ? LocalizableString.DeviceInfo.followedContactSupportTitle.localized : LocalizableString.contactSupport.localized
	}
	
	private let deviceInfoUseCase: DeviceInfoUseCaseApi?
	private var cancellable: Set<AnyCancellable> = []
	private let friendlyNameRegex = "^\\S.{0,64}$"
	private let photoStateViewModel: PhotoVerificationStateViewModel?
	private let linkNavigation: LinkNavigation

	init(device: DeviceDetails,
		 followState: UserDeviceFollowState?,
		 useCase: DeviceInfoUseCaseApi,
		 linkNavigation: LinkNavigation = LinkNavigationHelper()) {
		self.device = device
		self.followState = followState
		self.deviceInfoUseCase = useCase
		self.linkNavigation = linkNavigation

		if let deviceId = device.id {
			self.photoStateViewModel = ViewModelsFactory.getPhotoVerificationStateViewModel(deviceId: deviceId)
		} else {
			self.photoStateViewModel = nil
		}
		
		photoStateViewModel?.$state.sink { [weak self] state in
			self?.photoVerificationState = state
		}.store(in: &cancellable)
		
		refresh { [weak self] in
			self?.trackRewardSplitViewEvent()
		}
	}
	
	func handleShareButtonTap() {
		shareDialogText = InfoField.getShareText(for: device, deviceInfo: deviceInfo, mainVM: mainVM, followState: followState)
		showShareDialog = true
		
		WXMAnalytics.shared.trackEvent(.userAction, parameters: [.actionName: .shareStationInfo,
																 .contentType: .stationInfo,
																 .itemId: .custom(device.id ?? "")])
	}
	
	func handleContactSupportButtonTap() {
		WXMAnalytics.shared.trackEvent(.selectContent, parameters: [.contentType: .contactSupport,
																	.source: .deviceInfoSource])
		
		linkNavigation.openContactSupport(successFailureEnum: .weatherStations,
										  email: mainVM.userInfo?.email,
										  serialNumber: device.label,
										  errorString: nil,
										  addtionalInfo: InfoField.getShareText(for: device, deviceInfo: deviceInfo, mainVM: mainVM, followState: followState),
										  trackSelectContentEvent: false)
	}

	func refresh(completion: VoidCallback? = nil) {
		guard let deviceId = device.id else {
			return
		}
		
		Task { @MainActor [weak self] in
			let photosError = await self?.photoStateViewModel?.refresh()
			
			do {
				let response = try await self?.deviceInfoUseCase?.getDeviceInfo(deviceId: deviceId).toAsync()
				self?.isLoading = false
				if let error = response?.error {
					let uiInfo = error.uiInfo
					let text = uiInfo.description ?? uiInfo.title
					if let message = text.attributedMarkdown {
						Toast.shared.show(text: message)
					}
				}
				self?.deviceInfo = response?.value
				completion?()
			} catch {
				self?.isLoading = false
				print(error)
				completion?()
			}
		}
	}
}

extension DeviceInfoViewModel: HashableViewModel {
	nonisolated func hash(into hasher: inout Hasher) {
		MainActor.assumeIsolated {
			hasher.combine(device.id)
		}
	}
}

extension DeviceInfoViewModel: SelectStationLocationViewModelDelegate {
	func locationUpdated(with device: DeviceDetails) {
		self.device = device
	}
}

private extension DeviceInfoViewModel {
	
	func getInfoSection(title: String?, fields: [InfoField]) -> StationInfoView.Section {
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
		
		return .init(title: title, rows: infoRows)
	}
	
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
				WXMAnalytics.shared.trackEvent(.selectContent, parameters: [.contentType: .removeDevice,
																			.itemId: .custom(device.id ?? "")])
				showAccountConfirmation = true
			case .reconfigureWifi:
				break
			case .stationLocation:
				let viewModel = ViewModelsFactory.getSelectLocationViewModel(device: device, followState: followState, delegate: self)
				Router.shared.navigateTo(.selectStationLocation(viewModel))
			case .rewardSplit:
				break
			case .photos:
				guard let deviceId = device.id else {
					return
				}
				
				PhotoIntroViewModel.startPhotoVerification(deviceId: deviceId, images: [], isNewPhotoVerification: true)
				
				WXMAnalytics.shared.trackEvent(.selectContent, parameters: [.contentType: .goToPhotoVerification,
																			.source: .settingsSource])
		}
	}
	
	func handleInfoFieldButtonTap(infoField: InfoField) {
		switch infoField {
			case .name:
				break
			case .bundleName:
				break
			case .gatewayModel:
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
			case .lastGatewayActivity:
				break
			case .stationModel:
				break
			case .lastStationActivity:
				break
			case .stationRssi:
				break
		}
	}
	
	func showChangeNameAlert() {
		let okAction: AlertHelper.AlertObject.Action = (LocalizableString.save.localized, { [weak self] text in
			guard let self,
				  let deviceId = self.device.id,
				  let text = text?.trimWhiteSpaces() else {
				return
			}
			
			if !text.matches(friendlyNameRegex) {
				Toast.shared.show(text: LocalizableString.DeviceInfo.invalidFriendlyName.localized.attributedMarkdown ?? "")
				return
			}
			
			self.setFriendlyName(deviceId: deviceId, name: text.trimWhiteSpaces())
			
			WXMAnalytics.shared.trackEvent(.userAction, parameters: [.actionName: .changeStationNameResult,
																	 .contentType: .changeStationName,
																	 .action: .edit])
		})
		
		let clearAction: AlertHelper.AlertObject.Action = (LocalizableString.clear.localized, { [weak self] _ in
			guard let self,
				  let deviceId = self.device.id else {
				return
			}
			
			self.deleteFriendlyName(deviceId: deviceId)
			
			WXMAnalytics.shared.trackEvent(.userAction, parameters: [.actionName: .changeStationNameResult,
																	 .contentType: .changeStationName,
																	 .action: .clear])
		})
		
		let alertObject = AlertHelper.AlertObject(title: LocalizableString.DeviceInfo.editNameAlertTitle.localized,
												  message: LocalizableString.DeviceInfo.editNameAlertMessage.localized,
												  textFieldPlaceholder: Field.name.titleFor(devie: device).title,
												  textFieldValue: device.displayName,
												  textFieldDelegate: AlertTexFieldDelegate(),
												  cancelAction: {
			WXMAnalytics.shared.trackEvent(.userAction, parameters: [.actionName: .changeStationNameResult,
																	 .contentType: .changeStationName,
																	 .action: .cancel])
		},
												  okAction: okAction,
												  secondaryActions: [clearAction])
		AlertHelper().showAlert(alertObject)
		// Since we present a system dialog,
		// we track the screen here.
		WXMAnalytics.shared.trackScreen(.changeStationName, parameters: [.itemId: .custom(device.id ?? "")])
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
		
		WXMAnalytics.shared.trackEvent(.viewContent, parameters: [.contentName: .failure,
																  .itemId: .custom(error.backendError?.code ?? "")])
		Toast.shared.show(text: message, retryAction: retry)
	}
	
	func trackChangeNameViewContent(isSuccessful: Bool) {
		WXMAnalytics.shared.trackEvent(.viewContent, parameters: [.contentName: .changeStationNameResult,
																  .success: .custom(isSuccessful ? "1" : "0")])
	}
	
	func customViewFor(field: Field) -> AnyView? {
		switch field {
			case .rewardSplit:
				guard let rewardsplit = deviceInfo?.rewardSplit, rewardsplit.count > 0 else {
					return nil
				}
				let items = rewardsplit.map { split in
					let userWallet = MainScreenViewModel.shared.userInfo?.wallet?.address
					let isUserWallet = split.wallet == userWallet
					return split.toSplitViewItem(showReward: false, isUserWallet: isUserWallet)
				}
				return RewardsSplitView.WalletsListView(items: items).toAnyView
			case .photos:
				guard let photoStateViewModel else {
					return nil
				}
				return PhotoVerificationStateView(viewModel: photoStateViewModel).toAnyView
			default:
				return nil
		}
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
	
	func trackRewardSplitViewEvent() {
		let isStakeholder = deviceInfo?.isUserStakeholder(followState: followState) == true
		let isRewardSplitted = deviceInfo?.isRewardSplitted == true
		let userState: ParameterValue = isStakeholder ? .stakeholder : .nonStakeholder
		let deviceState: ParameterValue = isRewardSplitted ? .rewardSplitting : .noRewardSplitting
		
		let params: [Parameter: ParameterValue] = [.contentName: .rewardSplittingInDeviceSettings,
												   .deviceState: deviceState,
												   .userState: userState]
		WXMAnalytics.shared.trackEvent(.viewContent, parameters: params)
	}
}
