//
//  DeviceInfoViewModel+Content.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 8/3/23.
//

import Foundation
import DomainLayer
import Toolkit
import SwiftUI

struct DeviceInfoButtonInfo: Equatable {
	static func == (lhs: DeviceInfoButtonInfo, rhs: DeviceInfoButtonInfo) -> Bool {
		lhs.icon == rhs.icon &&
		lhs.title == rhs.title
	}
	
	let icon: AssetEnum?
	let title: String?
	var buttonStyle: WXMButtonStyle = WXMButtonStyle()
}

extension DeviceInfoViewModel {
    enum Field {
        case name
        case frequency
        case reboot
        case maintenance
        case remove
        case reconfigureWifi
		case stationLocation
		case rewardSplit

        static func heliumSections(for followState: UserDeviceFollowState?) -> [[Field]] {
            if followState?.state == .owned {
                return [[.name, .frequency, .reboot],
						[.stationLocation]]
            }

            return [[.name], [.stationLocation]]
        }

        static func wifiSections(for followState: UserDeviceFollowState?) -> [[Field]] {
            if followState?.state == .owned {
                return [[.name],
						[.stationLocation]]
            }
            
			return [[.name], [.stationLocation]]
        }

		static func bottomSections(for followState: UserDeviceFollowState?,
								   deviceInfo: NetworkDevicesInfoResponse?) -> [[Field]] {
			var sections: [[Field]] = []

			if let rewardSplit = deviceInfo?.rewardSplit,
			   rewardSplit.count > 1 {
				sections.append([.rewardSplit])
			}

			if followState?.state == .owned {
				sections.append([.remove])
			}

			return sections
		}

        var warning: DeviceInfoRowView.Row.Warning? {
            switch self {
                case .remove:
                    return .desructive(LocalizableString.deviceInfoStationRemoveWarning.localized)
                default:
                    return nil
            }
        }

		func titleFor(devie: DeviceDetails) -> String {
			switch self {
				case .name:
					return LocalizableString.deviceInfoStationName.localized
				case .frequency:
					return LocalizableString.deviceInfoStationFrequency.localized
				case .reboot:
					return LocalizableString.deviceInfoStationReboot.localized
				case .maintenance:
#warning("TODO: Format when info is ready")
					return LocalizableString.deviceInfoStationMaintenance("").localized
				case .remove:
					return LocalizableString.deviceInfoStationRemove.localized
				case .reconfigureWifi:
					return LocalizableString.deviceInfoStationReconfigureWifi.localized
				case .stationLocation:
					return LocalizableString.deviceInfoStationLocation.localized
				case .rewardSplit:
					return LocalizableString.RewardDetails.rewardSplit.localized
			}
        }

		func descriptionFor(device: DeviceDetails, for followState: UserDeviceFollowState?, deviceInfo: NetworkDevicesInfoResponse?) -> String {
			switch self {
				case .name:
					return device.displayName
				case .frequency:
					if device.isHelium {
						return LocalizableString.deviceInfoStationHeliumFrequencyDescription(DisplayedLinks.heliumRegionFrequencies.linkURL).localized
					}

					return ""
				case .reboot:
					return LocalizableString.deviceInfoStationRebootDescription.localized
				case .maintenance:
					return  LocalizableString.deviceInfoStationMaintenanceDescription(DisplayedLinks.heliumTroubleshooting.linkURL).localized
				case .remove:
					return LocalizableString.deviceInfoStationRemoveDescription(DisplayedLinks.documentationLink.linkURL).localized
				case .reconfigureWifi:
					return LocalizableString.deviceInfoStationReconfigureWifiDescription.localized
				case .stationLocation:
					if followState?.relation == .owned {
						return LocalizableString.deviceInfoOwnedStationLocationDescription(device.address ?? "").localized
					}
					return LocalizableString.deviceInfoStationLocationDescription(device.address ?? "").localized
				case .rewardSplit:
					guard let rewardSplit = deviceInfo?.rewardSplit else {
						return ""
					}
					let count = rewardSplit.count
					return LocalizableString.RewardDetails.rewardSplitDescription(count).localized
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
			}
		}
		
		func buttonInfoFor(devie: DeviceDetails, followState: UserDeviceFollowState?) -> DeviceInfoButtonInfo? {
			switch self {
				case .name:
					return .init(icon: nil, title: LocalizableString.deviceInfoButtonChangeName.localized)
				case .frequency:
					return .init(icon: nil, title: LocalizableString.deviceInfoButtonChangeFrequency.localized)
				case .reboot:
					return .init(icon: nil, title: LocalizableString.deviceInfoButtonReboot.localized)
				case .maintenance:
					return .init(icon: nil, title: LocalizableString.deviceInfoButtonEnterMaintenance.localized)
				case .remove:
					return .init(icon: nil, title: LocalizableString.deviceInfoButtonRemove.localized)
				case .reconfigureWifi:
					return .init(icon: nil, title: LocalizableString.deviceInfoButtonReconfigureWifi.localized)
				case .stationLocation:
					guard followState?.relation == .owned else {
						return nil
					}
					return .init(icon: .editIcon,
								 title: LocalizableString.deviceinfoStationLocationButtonTitle.localized,
								 buttonStyle: .filled())
				case .rewardSplit:
					return nil
			}
		}
	}

	enum InfoField {

		case name
		case bundleName
		case devEUI
		case gatewayModel
		case hardwareVersion
		case firmwareVersion
		case lastHotspot
		case lastRSSI
		case serialNumber
		case ATECC
		case GPS
		case wifiSignal
		case batteryState
		case lastGatewayActivity
		case claimedAt
		case stationModel
		case lastStationActivity

		static var heliumFields: [InfoField] {
			[.name, .bundleName, .stationModel, .claimedAt, .devEUI, .firmwareVersion, .hardwareVersion, .batteryState, .lastHotspot, .lastRSSI, .lastStationActivity]
		}

		static var wifiFields: [InfoField] {
			[wifiInfoFields,
			 wifiGatewayDetailsInfoFields,
			 wifiStationDetailsInfoFields].flatMap { $0 }
		}

		static var wifiInfoFields: [InfoField] {
			[.name, .bundleName, .claimedAt]
		}

		static var wifiGatewayDetailsInfoFields: [InfoField] {
			[.gatewayModel, .serialNumber, .firmwareVersion, .GPS, .wifiSignal, .lastGatewayActivity]
		}

		static var wifiStationDetailsInfoFields: [InfoField] {
			[.stationModel, .batteryState, .hardwareVersion, .lastStationActivity]
		}

        static func getShareText(for device: DeviceDetails, deviceInfo: NetworkDevicesInfoResponse?, mainVM: MainScreenViewModel, followState: UserDeviceFollowState?) -> String {
            var fields: [InfoField] = []
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

        var title: String {
            switch self {
                case .name:
                    return LocalizableString.deviceInfoStationInfoName.localized
				case .bundleName:
					return LocalizableString.deviceInfoStationInfoBundleName.localized
				case .gatewayModel, .stationModel:
					return LocalizableString.deviceInfoStationInfoModel.localized
                case .devEUI:
                    return LocalizableString.deviceInfoStationInfoDevEUI.localized
                case .hardwareVersion:
                    return LocalizableString.deviceInfoStationInfoHardwareVersion.localized
                case .firmwareVersion:
                    return LocalizableString.deviceInfoStationInfoFirmwareVersion.localized
                case .lastHotspot:
                    return LocalizableString.deviceInfoStationInfoLastHotspot.localized
                case .lastRSSI:
                    return LocalizableString.deviceInfoStationInfoLastRSSI.localized
                case .serialNumber:
                    return LocalizableString.deviceInfoStationInfoSerialNumber.localized
                case .ATECC:
                    return LocalizableString.deviceInfoStationInfoATECC.localized
                case .GPS:
                    return LocalizableString.deviceInfoStationInfoGPS.localized
                case .wifiSignal:
                    return LocalizableString.deviceInfoStationInfoWifiSignal.localized
                case .batteryState:
                    return LocalizableString.deviceInfoStationInfoBattery.localized
                case .claimedAt:
                    return LocalizableString.deviceInfoClaimDate.localized
				case .lastGatewayActivity:
					return LocalizableString.deviceInfoLastGatewayActivity.localized
				case .lastStationActivity:
					return LocalizableString.deviceInfoLastStationActivity.localized
            }
        }

        func value(for device: DeviceDetails, deviceInfo: NetworkDevicesInfoResponse? = nil, mainVM: MainScreenViewModel, followState: UserDeviceFollowState?) -> String? {
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
                    guard let current = device.firmware?.current else {
                        return nil
                    }

                    if device.needsUpdate(mainVM: mainVM, followState: followState) {
                        return device.firmware?.versionUpdateString
                    }
                    return current
                case .lastHotspot:
					let lastHs = deviceInfo?.weatherStation?.lastHs
					let timestamp = deviceInfo?.weatherStation?.lastHsActivity?.getFormattedDate(format: .monthLiteralYearDayTime,
																								 timezone: device.timezone?.toTimezone ?? .current).capitalizedSentence
					let elements = [lastHs, timestamp].compactMap { $0 }
					return elements.isEmpty ? nil : elements.joined(separator: " @ ")
                case .lastRSSI:
					guard var lastTxRssi = deviceInfo?.weatherStation?.lastTxRssi else {
						return nil
					}

					lastTxRssi = "\(lastTxRssi) \(UnitConstants.DBM)"
					let timestamp = deviceInfo?.weatherStation?.lastTxRssiActivity?.getFormattedDate(format: .monthLiteralYearDayTime,
																									 timezone: device.timezone?.toTimezone ?? .current).capitalizedSentence
					let elements = [lastTxRssi, timestamp].compactMap { $0 }
					return elements.joined(separator: " @ ")
                case .serialNumber:
                    return deviceInfo?.gateway?.serialNumber?.convertedDeviceIdentifier  ?? device.convertedLabel
                case .ATECC:
                    return nil
                case .GPS:
					guard var gpsSats = deviceInfo?.gateway?.gpsSats else {
						return nil
					}
					gpsSats = LocalizableString.deviceInfoSatellites(gpsSats).localized
					let timestamp = deviceInfo?.gateway?.gpsSatsLastActivity?.getFormattedDate(format: .monthLiteralYearDayTime,
																							   timezone: device.timezone?.toTimezone ?? .current).capitalizedSentence
					let elements = [gpsSats, timestamp].compactMap { $0 }
					return elements.joined(separator: " @ ")
                case .wifiSignal:
                    guard var rssi = deviceInfo?.gateway?.wifiRssi else {
                        return nil
                    }
					rssi = "\(rssi) \(UnitConstants.DBM)"
					let timestamp = deviceInfo?.gateway?.wifiRssiLastActivity?.getFormattedDate(format: .monthLiteralYearDayTime,
																								timezone: device.timezone?.toTimezone ?? .current).capitalizedSentence
					let elements = [rssi, timestamp].compactMap { $0 }
					return elements.joined(separator: " @ ")
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
            }
        }

        func warning(for device: DeviceDetails, deviceInfo: NetworkDevicesInfoResponse?) -> (String, VoidCallback)? {
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
                    guard let state = deviceInfo?.weatherStation?.batState else {
                        return nil
                    }
                    switch state {
                        case .low:
                            let callback = {
                                WXMAnalytics.shared.trackEvent(.prompt, parameters: [.promptName: .lowBattery,
                                                                               .promptType: .warnPromptType,
                                                                               .action: .viewAction,
                                                                               .itemId: .custom(device.id ?? "")])
                            }
                            return (LocalizableString.deviceInfoLowBatteryWarningMarkdown.localized, callback)
                        case .ok:
                            return nil
                    }
                case .claimedAt:
                    return nil
				case .lastGatewayActivity:
					return nil
				case .stationModel:
					return nil
				case .lastStationActivity:
					return nil
            }
        }

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
            }
        }
    }
}
