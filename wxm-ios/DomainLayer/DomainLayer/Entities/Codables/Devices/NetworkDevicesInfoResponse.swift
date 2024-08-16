//
//  NetworkDevicesInfoResponse.swift
//  DomainLayer
//
//  Created by Pantelis Giazitsis on 15/3/23.
//

import Foundation

public struct NetworkDevicesInfoResponse: Codable {
    public let name: String?
    public let claimedAt: Date?
    public let gateway: Gateway?
    public let weatherStation: WeatherStation?
	public let rewardSplit: [RewardSplit]?

    enum CodingKeys: String, CodingKey {
        case name
        case claimedAt = "claimed_at"
        case gateway
        case weatherStation = "weather_station"
		case rewardSplit = "reward_split"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decodeIfPresent(String.self, forKey: .name)
        self.claimedAt = try container.decodeIfPresent(Date.self, forKey: .claimedAt)
        self.gateway = try container.decodeIfPresent(Gateway.self, forKey: .gateway)
        self.weatherStation = try container.decodeIfPresent(WeatherStation.self, forKey: .weatherStation)
		self.rewardSplit = try container.decodeIfPresent([RewardSplit].self, forKey: .rewardSplit)
    }
}

public extension NetworkDevicesInfoResponse {
    struct Gateway: Codable {
        public let model: String?
        public let serialNumber: String?
        public let firmware: Firmware?
        public let gpsSats: String?
		public let gpsSatsLastActivity: Date?
        public let wifiRssi: String?
		public let wifiRssiLastActivity: Date?
        public let lastActivity: Date?

        enum CodingKeys: String, CodingKey {
            case model
            case serialNumber = "serial_number"
            case firmware
            case lastActivity = "last_activity"
            case gpsSats = "gps_sats"
			case gpsSatsLastActivity = "gps_sats_last_activity"
            case wifiRssi = "wifi_rssi"
			case wifiRssiLastActivity = "wifi_rssi_last_activity"
        }

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.model = try container.decodeIfPresent(String.self, forKey: .model)
            self.serialNumber = try container.decodeIfPresent(String.self, forKey: .serialNumber)
            self.lastActivity = try container.decodeIfPresent(Date.self, forKey: .lastActivity)
            self.gpsSats = try container.decodeIfPresent(String.self, forKey: .gpsSats)
			self.gpsSatsLastActivity = try container.decodeIfPresent(Date.self, forKey: .gpsSatsLastActivity)
            self.wifiRssi = try container.decodeIfPresent(String.self, forKey: .wifiRssi)
			self.wifiRssiLastActivity = try container.decodeIfPresent(Date.self, forKey: .wifiRssiLastActivity)
            self.firmware = try container.decodeIfPresent(Firmware.self, forKey: .firmware)
        }
    }

    struct WeatherStation: Codable {
        public let model: String?
        public let lastActivity: Date?
        public let batState: BatteryState?
        public let devEui: String?
        public let firmware: Firmware?
        public let hwVersion: String?
        public let lastHs: String?
		public let lastHsActivity: Date?
        public let lastTxRssi: String?
		public let lastTxRssiActivity: Date?

        enum CodingKeys: String, CodingKey {
            case model
            case firmware
            case devEui = "dev_eui"
            case hwVersion = "hw_version"
            case lastHs = "last_hs_name"
			case lastHsActivity = "last_hs_name_last_activity"
            case lastTxRssi = "last_tx_rssi"
			case lastTxRssiActivity = "last_tx_rssi_last_activity"
            case lastActivity = "last_activity"
            case batState = "bat_state"
        }

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.model = try container.decodeIfPresent(String.self, forKey: .model)
            self.devEui = try container.decodeIfPresent(String.self, forKey: .devEui)
            self.hwVersion = try container.decodeIfPresent(String.self, forKey: .hwVersion)
            self.firmware = try container.decodeIfPresent(Firmware.self, forKey: .firmware)
            self.lastHs = try container.decodeIfPresent(String.self, forKey: .lastHs)
			self.lastHsActivity = try container.decodeIfPresent(Date.self, forKey: .lastHsActivity)
            self.lastTxRssi = try container.decodeIfPresent(String.self, forKey: .lastTxRssi)
            self.lastTxRssiActivity = try container.decodeIfPresent(Date.self, forKey: .lastTxRssiActivity)
			self.lastActivity = try container.decodeIfPresent(Date.self, forKey: .lastActivity)
            self.batState = try container.decodeIfPresent(BatteryState.self, forKey: .batState)
        }
    }
}
