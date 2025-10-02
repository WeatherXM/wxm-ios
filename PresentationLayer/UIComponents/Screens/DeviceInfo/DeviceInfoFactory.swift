//
//  DeviceInfoFactory.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 9/10/24.
//

import Foundation
import DomainLayer
import SwiftUI
import Toolkit

extension DeviceInfoViewModel.Field {
	var warning: DeviceInfoRowView.Row.Warning? {
		switch self {
			case .remove:
				return .desructive(LocalizableString.DeviceInfo.stationRemoveWarning.localized)
			default:
				return nil
		}
	}

	func titleFor(devie: DeviceDetails) -> (title: String, badge: String?) {
		switch self {
			case .name:
				return (LocalizableString.DeviceInfo.stationName.localized, nil)
			case .frequency:
				return (LocalizableString.DeviceInfo.stationFrequency.localized, nil)
			case .reboot:
				return (LocalizableString.DeviceInfo.stationReboot.localized, nil)
			case .maintenance:
#warning("TODO: Format when info is ready")
				return (LocalizableString.DeviceInfo.stationMaintenance("").localized, nil)
			case .remove:
				return (LocalizableString.DeviceInfo.stationRemove.localized, nil)
			case .reconfigureWifi:
				return (LocalizableString.DeviceInfo.stationReconfigureWifi.localized, nil)
			case .stationLocation:
				return (LocalizableString.DeviceInfo.stationLocation.localized, nil)
			case .rewardSplit:
				return (LocalizableString.RewardDetails.rewardSplit.localized, nil)
			case .photos:
				return (LocalizableString.PhotoVerification.photoVerificationIntroTitle.localized, nil)
		}
	}

	func isDescriptionCopyable() -> Bool {
		switch self {
			case .name:
				true
			default:
				false
		}
	}
	
	func descriptionFor(device: DeviceDetails,
						for followState: UserDeviceFollowState?,
						deviceInfo: NetworkDevicesInfoResponse?,
						photoVerificationState: PhotoVerificationStateView.State?) -> String {
		switch self {
			case .name:
				return device.displayName
			case .frequency:
				if device.isHelium {
					return LocalizableString.DeviceInfo.stationHeliumFrequencyDescription(DisplayedLinks.heliumRegionFrequencies.linkURL).localized
				}

				return ""
			case .reboot:
				return LocalizableString.DeviceInfo.stationRebootDescription.localized
			case .maintenance:
				return  LocalizableString.DeviceInfo.stationMaintenanceDescription(DisplayedLinks.heliumTroubleshooting.linkURL).localized
			case .remove:
				return LocalizableString.DeviceInfo.stationRemoveDescription(DisplayedLinks.documentationLink.linkURL).localized
			case .reconfigureWifi:
				return LocalizableString.DeviceInfo.stationReconfigureWifiDescription.localized
			case .stationLocation:
				if followState?.relation == .owned {
					return LocalizableString.DeviceInfo.ownedStationLocationDescription(device.address ?? "").localized
				}
				return LocalizableString.DeviceInfo.stationLocationDescription(device.address ?? "").localized
			case .rewardSplit:
				guard let rewardSplit = deviceInfo?.rewardSplit else {
					return ""
				}
				let count = rewardSplit.count
				return LocalizableString.RewardDetails.rewardSplitDescription(count).localized
			case .photos:
				guard let photoVerificationState else {
					return ""
				}

				switch photoVerificationState {
					case .uploading:
						return LocalizableString.DeviceInfo.photoVerificationUploadingDescription.localized
					case .content(let photos, _):
						if photos.isEmpty {
							return LocalizableString.DeviceInfo.photoVerificationEmptyText.localized
						}

						return LocalizableString.DeviceInfo.photoVerificationWithPhotosDescription.localized
					case .fetchPhotosFailed:
						return ""
				}
		}
	}

	func imageUrlFor(device: DeviceDetails, followState: UserDeviceFollowState?) -> URL? {
		switch self {
			case .name:
				return nil
			case .frequency:
				return nil
			case .reboot:
				return nil
			case .maintenance:
				return nil
			case .remove:
				return nil
			case .reconfigureWifi:
				return nil
			case .stationLocation:
				guard let cellCenterLocation = device.cellCenter?.toCLLocationCoordinate2D() else {
					return nil
				}

				let isOwned = followState?.relation == .owned
				let marker = isOwned ? device.location?.toCLLocationCoordinate2D() : nil
				let polygon = device.cellPolygon?.map { $0.toCLLocationCoordinate2D() }
				let options = MapBoxSnapshotUrlGenerator.Options(location: cellCenterLocation,
															markerLocation: marker,
															size: MapBoxConstants.snapshotSize,
															zoomLevel: MapBoxConstants.snapshotZoom,
															polygon: polygon)
				let fetcher = MapBoxSnapshotUrlGenerator(options: options)

				return fetcher.getUrl()
			case .rewardSplit:
				return nil
			case .photos:
				return nil
		}
	}

	@MainActor
	func buttonInfoFor(devie: DeviceDetails,
					   followState: UserDeviceFollowState?,
					   photoVerificationState: PhotoVerificationStateView.State?) -> DeviceInfoButtonInfo? {
		switch self {
			case .name:
				return .init(icon: nil, title: LocalizableString.DeviceInfo.buttonChangeName.localized)
			case .frequency:
				return .init(icon: nil, title: LocalizableString.DeviceInfo.buttonChangeFrequency.localized)
			case .reboot:
				return .init(icon: nil, title: LocalizableString.DeviceInfo.buttonReboot.localized)
			case .maintenance:
				return .init(icon: nil, title: LocalizableString.DeviceInfo.buttonEnterMaintenance.localized)
			case .remove:
				return .init(icon: nil, title: LocalizableString.DeviceInfo.buttonRemove.localized)
			case .reconfigureWifi:
				return .init(icon: nil, title: LocalizableString.DeviceInfo.buttonReconfigureWifi.localized)
			case .stationLocation:
				guard followState?.relation == .owned else {
					return nil
				}
				return .init(icon: .editIcon,
							 title: LocalizableString.DeviceInfo.stationLocationButtonTitle.localized,
							 buttonStyle: .filled())
			case .rewardSplit:
				return nil
			case .photos:
				guard let photoVerificationState else {
					return nil
				}

				switch photoVerificationState {
					case .content(let photos, _):
						if photos.isEmpty {
							return .init(icon: nil,
										 title: LocalizableString.DeviceInfo.photoVerificationStartButtonTitle.localized,
										 buttonStyle: .filled())

						}
						
						fallthrough
					default:
						return nil
				}
		}
	}
}

@MainActor
extension DeviceInfoViewModel.InfoField {
	static func getShareText(for device: DeviceDetails, deviceInfo: NetworkDevicesInfoResponse?, mainVM: MainScreenViewModel, followState: UserDeviceFollowState?) -> String {
		var fields: [Self] = []
		if device.isHelium {
			fields = heliumFields
		} else {
			fields = wifiFields
		}

		let textComps: [String] = fields.compactMap { field in
			guard let value = field.value(for: device, deviceInfo: deviceInfo, mainVM: mainVM, followState: followState) else {
				return nil
			}
			return "\(field.title): \(value)"
		}

		return textComps.joined(separator: "\n")
	}

	private static func getRssiText(rssi: String?, lastActivityDate: Date?, timezone: String?) -> String? {
		guard var rssi else {
			return nil
		}
		rssi = "\(rssi) \(UnitConstants.DBM)"
		let timestamp = lastActivityDate?.getFormattedDate(format: .monthLiteralYearDayTime,
														   timezone: timezone?.toTimezone ?? .current).capitalizedSentence
		let elements = [rssi, timestamp].compactMap { $0 }
		return elements.joined(separator: " @ ")
	}

	private static func getGpsSatsText(gpsSats: String?, lastActivityDate: Date?, timezone: String?) -> String? {
		guard var gpsSats else {
			return nil
		}
		gpsSats = LocalizableString.DeviceInfo.satellites(gpsSats).localized
		let timestamp = lastActivityDate?.getFormattedDate(format: .monthLiteralYearDayTime,
														   timezone: timezone?.toTimezone ?? .current).capitalizedSentence
		let elements = [gpsSats, timestamp].compactMap { $0 }
		return elements.joined(separator: " @ ")
	}

	private static func getLastHotspotText(lastHs: String?, lastActivityDate: Date?, timezone: String?) -> String? {
		let timestamp = lastActivityDate?.getFormattedDate(format: .monthLiteralYearDayTime,
														   timezone: timezone?.toTimezone ?? .current).capitalizedSentence
		let elements = [lastHs, timestamp].compactMap { $0 }
		return elements.isEmpty ? nil : elements.joined(separator: " @ ")
	}

	private static func getFirmwareVersionText(for device: DeviceDetails, mainVM: MainScreenViewModel, followState: UserDeviceFollowState?) -> String? {
		guard let current = device.firmware?.current else {
			return nil
		}

		if device.needsUpdate(mainVM: mainVM, followState: followState) {
			return device.firmware?.versionUpdateString
		}
		return current
	}

	var title: String {
		switch self {
			case .name:
				return LocalizableString.DeviceInfo.stationInfoName.localized
			case .bundleName:
				return LocalizableString.DeviceInfo.stationInfoBundleName.localized
			case .gatewayModel, .stationModel:
				return LocalizableString.DeviceInfo.stationInfoModel.localized
			case .devEUI:
				return LocalizableString.DeviceInfo.stationInfoDevEUI.localized
			case .hardwareVersion:
				return LocalizableString.DeviceInfo.stationInfoHardwareVersion.localized
			case .firmwareVersion:
				return LocalizableString.DeviceInfo.stationInfoFirmwareVersion.localized
			case .lastHotspot:
				return LocalizableString.DeviceInfo.stationInfoLastHotspot.localized
			case .lastRSSI:
				return LocalizableString.DeviceInfo.stationInfoLastRSSI.localized
			case .serialNumber:
				return LocalizableString.DeviceInfo.stationInfoSerialNumber.localized
			case .ATECC:
				return LocalizableString.DeviceInfo.stationInfoATECC.localized
			case .GPS:
				return LocalizableString.DeviceInfo.stationInfoGPS.localized
			case .wifiSignal:
				return LocalizableString.DeviceInfo.stationInfoWifiSignal.localized
			case .batteryState:
				return LocalizableString.DeviceInfo.stationInfoBattery.localized
			case .claimedAt:
				return LocalizableString.DeviceInfo.claimDate.localized
			case .lastGatewayActivity:
				return LocalizableString.DeviceInfo.lastGatewayActivity.localized
			case .lastStationActivity:
				return LocalizableString.DeviceInfo.lastStationActivity.localized
			case .stationRssi:
				return LocalizableString.DeviceInfo.stationRssi.localized
			case .gsmSignal:
				return LocalizableString.DeviceInfo.gsmSignal.localized
			case .gwFrequency:
				return LocalizableString.DeviceInfo.gwFrequency.localized
			case .externalSim:
				return LocalizableString.DeviceInfo.externalSim.localized
			case .iccid:
				return LocalizableString.DeviceInfo.iccid.localized
			case .mobileCountryCode:
				return LocalizableString.DeviceInfo.mobileCountryCode.localized
			case .gwBatteryState:
				return LocalizableString.DeviceInfo.gwBatteryState.localized
			case .signalGwStation:
				return LocalizableString.DeviceInfo.signalGwStation.localized
			case .nextServerCommunication:
				return LocalizableString.DeviceInfo.nextServerCommunication.localized
			case .stationId:
				return LocalizableString.DeviceInfo.stationId.localized
			case .signalStationGw:
				return LocalizableString.DeviceInfo.signalStationGw.localized
		}
	}

	var isSubtitleCopyable: Bool {
		switch self {
			case .name, .devEUI, .serialNumber:
				return true
			default:
				return false

		}
	}
	
	func value(for device: DeviceDetails,
			   deviceInfo: NetworkDevicesInfoResponse? = nil,
			   mainVM: MainScreenViewModel,
			   followState: UserDeviceFollowState?) -> String? {
		switch self {
			case .name:
				return device.name
			case .gatewayModel:
				return deviceInfo?.gateway?.model
			case .bundleName:
				return device.bundle?.title
			case .devEUI:
				return deviceInfo?.weatherStation?.devEui?.convertedDeviceIdentifier ?? device.convertedLabel
			case .hardwareVersion:
				return deviceInfo?.weatherStation?.hwVersion
			case .firmwareVersion:
				return Self.getFirmwareVersionText(for: device, mainVM: mainVM, followState: followState)
			case .lastHotspot:
				return Self.getLastHotspotText(lastHs: deviceInfo?.weatherStation?.lastHs,
											   lastActivityDate: deviceInfo?.weatherStation?.lastHsActivity,
											   timezone: device.timezone)
			case .lastRSSI:
				return Self.getRssiText(rssi: deviceInfo?.weatherStation?.lastTxRssi,
										lastActivityDate: deviceInfo?.weatherStation?.lastTxRssiActivity,
										timezone: device.timezone)
			case .serialNumber:
				return deviceInfo?.gateway?.serialNumber?.convertedDeviceIdentifier  ?? device.convertedLabel
			case .ATECC:
				return nil
			case .GPS:
				return Self.getGpsSatsText(gpsSats: deviceInfo?.gateway?.gpsSats,
										   lastActivityDate: deviceInfo?.gateway?.gpsSatsLastActivity,
										   timezone: device.timezone)
			case .wifiSignal:
				return Self.getRssiText(rssi: deviceInfo?.gateway?.wifiRssi,
										lastActivityDate: deviceInfo?.gateway?.wifiRssiLastActivity,
										timezone: device.timezone)
			case .batteryState:
				return deviceInfo?.weatherStation?.batState?.description
			case .claimedAt:
				return deviceInfo?.claimedAt?.getFormattedDate(format: .monthLiteralYearDayTime,
															   timezone: device.timezone?.toTimezone ?? .current).capitalizedSentence
			case .lastGatewayActivity:
				return deviceInfo?.gateway?.lastActivity?.getFormattedDate(format: .monthLiteralYearDayTime,
																		   timezone: device.timezone?.toTimezone ?? .current).capitalizedSentence
			case .stationModel:
				return deviceInfo?.weatherStation?.model
			case .lastStationActivity:
				return deviceInfo?.weatherStation?.lastActivity?.getFormattedDate(format: .monthLiteralYearDayTime,
																				  timezone: device.timezone?.toTimezone ?? .current).capitalizedSentence
			case .stationRssi:
				return Self.getRssiText(rssi: deviceInfo?.weatherStation?.stationRssi?.formatted(),
										lastActivityDate: deviceInfo?.weatherStation?.stationRssiLastActivity,
										timezone: device.timezone)
		}
	}

	func warning(for device: DeviceDetails, deviceInfo: NetworkDevicesInfoResponse?) -> (CardWarningConfiguration, VoidCallback)? {
		switch self {
			case .name:
				return nil
			case .bundleName:
				return nil
			case .gatewayModel:
				return nil
			case .devEUI:
				return nil
			case .hardwareVersion:
				return nil
			case .firmwareVersion:
				return nil
			case .lastHotspot:
				return nil
			case .lastRSSI:
				return nil
			case .serialNumber:
				return nil
			case .ATECC:
				return nil
			case .GPS:
				return nil
			case .wifiSignal:
				return nil
			case .batteryState:
				return warningForBatteryState(deviceInfo?.weatherStation?.batState, deviceId: device.id ?? "")
			case .claimedAt:
				return nil
			case .lastGatewayActivity:
				return nil
			case .stationModel:
				return nil
			case .lastStationActivity:
				return nil
			case .stationRssi:
				return warningForStationRssi(for: deviceInfo?.weatherStation?.stationRssi)
		}
	}

	func warningForBatteryState(_ state: BatteryState?, deviceId: String) -> (CardWarningConfiguration, VoidCallback)? {
		guard let state else {
			return nil
		}
		switch state {
			case .low:
				let callback = {
					WXMAnalytics.shared.trackEvent(.prompt, parameters: [.promptName: .lowBattery,
																		 .promptType: .warnPromptType,
																		 .action: .viewAction,
																		 .itemId: .custom(deviceId)])
				}
				return (CardWarningConfiguration(type: .warning,
												 message: LocalizableString.DeviceInfo.lowBatteryWarningMarkdown.localized,
												 closeAction: nil),
						callback)
			case .ok:
				return nil
		}
	}

	func warningForStationRssi(for rssi: Int?) -> (CardWarningConfiguration, VoidCallback)? {
		guard let rssi else {
			return nil
		}

		let urlText = "**\(LocalizableString.troubleshootInstructionsHere.localized)**"
		switch rssi {
			case _ where rssi >= -80:
				return nil
			case _ where rssi >= -95:
				return (CardWarningConfiguration(type: .warning,
												 message: LocalizableString.DeviceInfo.stationRssiWarning.localized,
												 linkText: LocalizableString.url(urlText, DisplayedLinks.troubleshooting.linkURL).localized,
												 closeAction: nil), {})
			default:
				return (CardWarningConfiguration(type: .error,
												 message: LocalizableString.DeviceInfo.stationRssiError.localized,
												 linkText: LocalizableString.url(urlText, DisplayedLinks.troubleshooting.linkURL).localized,
												 closeAction: nil), {})
		}
	}

	@MainActor
	func button(for device: DeviceDetails, mainVM: MainScreenViewModel, followState: UserDeviceFollowState?) -> DeviceInfoButtonInfo? {
		switch self {
			case .name:
				return nil
			case .bundleName:
				return nil
			case .gatewayModel:
				return nil
			case .devEUI:
				return nil
			case .hardwareVersion:
				return nil
			case .firmwareVersion:
				let buttonInfo = DeviceInfoButtonInfo(icon: .updateFirmwareIcon,
													  title: LocalizableString.ClaimDevice.updateFirmwareButton.localized,
													  buttonStyle: .filled())
				return device.needsUpdate(mainVM: mainVM, followState: followState) ? buttonInfo : nil
			case .lastHotspot:
				return nil
			case .lastRSSI:
				return nil
			case .serialNumber:
				return nil
			case .ATECC:
				return nil
			case .GPS:
				return nil
			case .wifiSignal:
				return nil
			case .batteryState:
				return nil
			case .claimedAt:
				return nil
			case .lastGatewayActivity:
				return nil
			case .stationModel:
				return nil
			case .lastStationActivity:
				return nil
			case .stationRssi:
				return nil
		}
	}
}
