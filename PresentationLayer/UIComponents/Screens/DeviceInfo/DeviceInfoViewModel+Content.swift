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

@MainActor
struct DeviceInfoButtonInfo: Equatable {
	nonisolated static func == (lhs: DeviceInfoButtonInfo, rhs: DeviceInfoButtonInfo) -> Bool {
		MainActor.assumeIsolated {
			lhs.icon == rhs.icon &&
			lhs.title == rhs.title
		}
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
		case stationRssi

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
			[.stationModel, .hardwareVersion, .stationRssi, .batteryState, .lastStationActivity]
		}
	}
}
