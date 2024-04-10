//
//  DeviceDetails+.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 31/7/23.
//

import Foundation
import DomainLayer
import Toolkit

struct FirmwareVersion: Codable {
    let installDate: Date
    let version: String
}

extension DeviceDetails: Identifiable { }

extension DeviceDetails {

    var stationLastActiveConf: StationLastActiveView.Configuration {
        StationLastActiveView.Configuration(lastActiveAt: lastActiveAt,
                                            icon: profile?.icon ?? .wifi,
                                            stateColor: activeStateColor(isActive: isActive),
                                            tintColor: activeStateTintColor(isActive: isActive))
    }

    /// Label without occurences of ":"
    var convertedLabel: String? {
        label?.convertedDeviceIdentifier
    }

    /// The icon color for each state
    var isActiveStateColor: ColorEnum {
        activeStateColor(isActive: isActive)
    }

    /// The tint color for for each state
    var isActiveStateTintColor: ColorEnum {
        activeStateTintColor(isActive: isActive)
    }

    /// The url rouble shooting according to profile type
    var troubleShootingUrl: String? {
        guard let profile else {
            return nil
        }

        switch profile {
            case .m5:
                return DisplayedLinks.m5Troubleshooting.linkURL
            case .helium:
                return DisplayedLinks.heliumTroubleshooting.linkURL
        }
    }

	var explorerUrl: String {
		let name = name.replacingOccurrences(of: " ", with: "-")
		return DisplayedLinks.shareDevice.linkURL + name.lowercased()
	}
}

// MARK: - Issues
extension DeviceDetails {
	private static let firmwareUpdateInterval: TimeInterval = .hour
	
	enum IssueType: Comparable, CustomStringConvertible {
		case offline
		case needsUpdate
		case lowBattery

		var description: String {
			switch self {
				case .offline:
					return LocalizableString.alertsStationOfflineTitle.localized
				case .needsUpdate:
					return LocalizableString.updateRequiredTitle.localized
				case .lowBattery:
					return LocalizableString.lowBatteryWarningTitle.localized
			}
		}
	}

	struct Issue {
		let type: IssueType
		let warningType: CardWarningType
		var analyticsItemId: ParameterValue? {
			switch type {
				case .offline:
					return nil
				case .needsUpdate:
					return .otaUpdate
				case .lowBattery:
					return .lowBatteryItem
			}
		}
	}

	func isBatteryLow(followState: UserDeviceFollowState?) -> Bool {
		guard followState?.relation == .owned else {
			return false
		}
		return batteryState == .low
	}

	func overallWarningType(mainVM: MainScreenViewModel, followState: UserDeviceFollowState?) -> CardWarningType {
		let issues = issues(mainVM: mainVM, followState: followState).sorted(by: { $0.type < $1.type })
		return issues.first?.warningType ?? .info
	}

	func needsUpdate(persistedVersion: FirmwareVersion?) -> Bool {
		guard let version = persistedVersion?.version,
			  let timestamp = persistedVersion?.installDate
		else {
			return checkFirmwareIfNeedsUpdate()
		}

		if version == firmware?.current, Date.now.timeIntervalSince(timestamp) < Self.firmwareUpdateInterval {
			return false
		}

		return checkFirmwareIfNeedsUpdate()
	}

	func checkFirmwareIfNeedsUpdate() -> Bool {
		guard profile == .helium,
			  let current = firmware?.current,
			  let assigned = firmware?.assigned else {
			return false
		}

		return assigned != current
	}

	/// True if the stations current version is different from the assigned
	func needsUpdate(mainVM: MainScreenViewModel, followState: UserDeviceFollowState?) -> Bool {
		guard profile == .helium, followState?.state == .owned else {
			return false
		}
		return needsUpdate(persistedVersion: mainVM.getInstalledFirmwareVersion(for: id ?? ""))
	}

	func issuesCount(mainVM: MainScreenViewModel, followState: UserDeviceFollowState?) -> Int {
		issues(mainVM: mainVM, followState: followState).count
	}

	func hasIssues(mainVM: MainScreenViewModel, followState: UserDeviceFollowState?) -> Bool {
		issuesCount(mainVM: mainVM, followState: followState) > 0
	}

	func issues(mainVM: MainScreenViewModel, followState: UserDeviceFollowState?) -> [Issue] {
		var issues = [Issue]()
		
		if !isActive {
			issues.append(.init(type: .offline, warningType: .error))
		}

		if isBatteryLow(followState: followState) {
			issues.append(.init(type: .lowBattery, warningType: .warning))
		}

		if needsUpdate(mainVM: mainVM, followState: followState) {
			issues.append(.init(type: .needsUpdate, warningType: .warning))
		}

		return issues
	}
}

extension Firmware {
	var versionUpdateString: String? {
		guard let current, let assigned else {
			return nil
		}
		return "\(current) → \(assigned)"
	}
}

// MARK: - Mock

extension DeviceDetails {
    static var mockDevice: DeviceDetails {
        var device = DeviceDetails.emptyDeviceDetails
        device.name = "Test name"
        device.id = "0"
        device.label = "AE:66:F7:21:1F:21:75:11:EC"
        device.address = "This is an address"
        device.profile = .m5
        device.isActive = true
		device.lastActiveAt = Date.now.toTimestamp()
        device.firmware = Firmware(assigned: "1.0.0", current: "1.0.1")
		device.cellCenter = .init(lat: 0.0, long: 0.0)

        let currentWeather = CurrentWeather.mockInstance
        device.weather = currentWeather

        return device
    }
}
