//
//  AnalyticsConstants+.swift
//  Toolkit
//
//  Created by Pantelis Giazitsis on 10/4/24.
//

import Foundation
import FirebaseAnalytics

extension Event: CustomStringConvertible {
	public var description: String {
		switch self {
			case .userAction, .viewContent, .prompt:
				return rawValue
			case .selectContent:
				return AnalyticsEventSelectContent
		}
	}
}

extension Parameter: CustomStringConvertible {
	public var description: String {
		switch self {
			case .action, .actionName, .contentName, .contentId, .promptName, .promptType,
					.step, .state, .date, .theme, .temperature, .wind, .windDirection, .precipitation, .pressure,
					.sortBy, .filter, .groupBy, .status, .appId, .hasWallet, .stationsOwn:
				return rawValue
			case .contentType:
				return AnalyticsParameterContentType
			case .location:
				return AnalyticsParameterLocation
			case .itemId:
				return AnalyticsParameterItemID
			case .itemListId:
				return AnalyticsParameterItemListID
			case .method:
				return AnalyticsParameterMethod
			case .success:
				return AnalyticsParameterSuccess
			case .index:
				return AnalyticsParameterIndex
			case .source:
				return AnalyticsParameterSource
		}
	}
}

extension ParameterValue: RawRepresentable {
	public typealias RawValue = String

	public init?(rawValue: String) {
		fatalError("Init should not be used")
	}

	public var rawValue: String {
		switch self {
			case .selectDevice:
				return "Select Device"
			case .userDeviceList:
				return "User Device List"
			case .transactionOnExplorer:
				return "Transaction on Explorer"
			case .deviceTransactions:
				return "Device Transactions"
			case .shareStationInfo:
				return "Share Station Information"
			case .stationInfo:
				return "Station Information"
			case .myLocation:
				return "My Location"
			case .claiming:
				return "Claiming"
			case .claimingResult:
				return "Claiming Results"
			case .searchLocation:
				return "Search Location"
			case .claimingAddressSearch:
				return "Claiming Address Search"
			case .cancel:
				return "Cancel"
			case .retry:
				return "Retry"
			case .viewStation:
				return "View Station"
			case .updateFirmware:
				return "Update Station"
			case .changeStationNameResult:
				return "Change Station Name Result"
			case .changeStationName:
				return "Change Station Name"
			case .edit:
				return "Edit"
			case .clear:
				return "Clear"
			case .changeFrequencyResult:
				return "Chnage Frequency Result"
			case .changeStationFrequency:
				return "Change Station Frequency"
			case .change:
				return "Change"
			case .changePassword:
				return "Change Password"
			case .announcements:
				return "Announcements"
			case .login:
				return "Login"
			case .email:
				return "Email"
			case .custom(let string):
				return string
			case .heliumBLEPopupError:
				return "Helium BLE Popup Error"
			case .heliumBLEPopup:
				return "Helium BLE Popup"
			case .quit:
				return "Quit"
			case .tryAgain:
				return "Try Again"
			case .signup:
				return "Signup"
			case .sendEmailForgotPassword:
				return "Send Email for Forgot Password"
			case .forgotPasswordEmail:
				return "forgot_password_email"
			case .OTAError:
				return "OTA Error"
			case .failureOTA:
				return "failure_ota"
			case .connect:
				return "connect"
			case .download:
				return "download"
			case .install:
				return "install"
			case .OTAResult:
				return "OTA Result"
			case .walletMissing:
				return "Wallet Missing"
			case .warnPromptType:
				return "warn"
			case .viewAction:
				return "view"
			case .dismissAction:
				return "dismiss"
			case .action:
				return "action"
			case .OTAAvailable:
				return "OTA Available"
			case .lowBattery:
				return "Low Battery"
			case .walletCompatibility:
				return "Wallet Compatibility"
			case .info:
				return "info"
			case .openState:
				return "open"
			case .closeState:
				return "close"
			case .rewardsCard:
				return "Rewards Card"
			case .removeDevice:
				return "Remove Device"
			case .deviceAlertsSource:
				return "device_alerts"
			case .stationOffline:
				return "station_offline"
			case .deviceInfoSource:
				return "device_info"
			case .settingsSource:
				return "settings"
			case .errorSource:
				return "error"
			case .networkStatsSource:
				return "network_stats"
			case .contactSupport:
				return "Contact Support"
			case .historyDay:
				return "History Day"
			case .walletTransactions:
				return "Wallet Transactions"
			case .editWallet:
				return "Edit Wallet"
			case .createMetamask:
				return "Create Metamask"
			case .walletTermsOfService:
				return "Wallet Terms Of Service"
			case .scanQRWallet:
				return "Scan QR Wallet"
			case .logout:
				return "Logout"
			case .documentation:
				return "Documentation"
			case .userResearchPanel:
				return "User Research Panel"
			case .appSurvey:
				return "App Survey"
			case .bleScanAgain:
				return "BLE Scan Again"
			case .frequencyDocumentation:
				return "Frequency Documentation"
			case .failure:
				return "failure"
			case .success:
				return "success"
			case .light:
				return "light"
			case .dark:
				return "dark"
			case .system:
				return "system"
			case .celsius:
				return "c"
			case .fahrenheit:
				return "f"
			case .kmPerHour:
				return "kmph"
			case .milesPerHour:
				return "mph"
			case .metersPerSecond:
				return "mps"
			case .knots:
				return "kn"
			case .beaufort:
				return "bf"
			case .degrees:
				return "deg"
			case .cardinal:
				return "card"
			case .millimeters:
				return "mm"
			case .inches:
				return "in"
			case .hectopascal:
				return "hpa"
			case .inchOfMercury:
				return "inhg"
			case .loginContentId:
				return "login"
			case .signUpContentId:
				return "signup"
			case .forgotPasswordEmailContentId:
				return "forgot_password_email"
			case .failureOtaContentId:
				return "failure_ota"
			case .otaResultContentId:
				return "ota_result"
			case .failureContentId:
				return "failure"
			case .changeStationNameResultContentId:
				return "change_station_name_result"
			case .changeFrequencyResultContentId:
				return "change_frequency_result"
			case .emailMethod:
				return "email"
			case .claimingResultContentId:
				return "claming_result"
			case .openShop:
				return "Open Shop"
			case .openStationShop:
				return "Open Station Shop"
			case .openManufacturerContact:
				return "Open Manufacturer Contact"
			case .total:
				return "total"
			case .claimed:
				return "claimed"
			case .active:
				return "active"
			case .learnMore:
				return "Learn More"
			case .dataDays:
				return "data_days"
			case .allocatedRewards:
				return "allocated_rewards"
			case .totalStations:
				return "total_stations"
			case .claimedStations:
				return "claimed_stations"
			case .activeStations:
				return "active_stations"
			case .buyStation:
				return "buy_station"
			case .explorerSearch:
				return "Explorer Search"
			case .explorerSettings:
				return "Explorer Settings"
			case .explorerPopUp:
				return "Explorer Pop Up"
			case .networkSearch:
				return "Network Search"
			case .recent:
				return "recent"
			case .search:
				return "search"
			case .location:
				return "location"
			case .station:
				return "station"
			case .tokenClaimingResult:
				return "Token Claiming Result"
			case .tokenContract:
				return "token_contract"
			case .rewardContract:
				return "reward_contract"
			case .lastRunHash:
				return "last_run_hash"
			case .totalSupply:
				return "total_supply"
			case .circulatingSupply:
				return "circulating_supply"
			case .deviceDetailsPopUp:
				return "Device Details Pop Up"
			case .deviceDetailsShare:
				return "Device Details Share"
			case .deviceDetailsFollow:
				return "Device Details Follow"
			case .follow:
				return "Follow"
			case .unfollow:
				return "Unfollow"
			case .stationDetailsChip:
				return "Station Details Chip"
			case .warnings:
				return "Warnings"
			case .region:
				return "Region"
			case .otaUpdate:
				return "ota_update"
			case .lowBatteryItem:
				return "low_battery"
			case .stationRegion:
				return "station_region"
			case .devicesListFollow:
				return "Devices List Follow"
			case .explorerDevicesListFollow:
				return "Explorer Devices List Follow"
			case .deviceDetailsSettings:
				return "Device Details Settings"
			case .filters:
				return "Filters"
			case .filtersReset:
				return "Filters Reset"
			case .filtersCancel:
				return "Filters Cancel"
			case .filtersSave:
				return "Filters Save"
			case .dateAdded:
				return "date_added"
			case .name:
				return "name"
			case .lastActive:
				return "last_active"
			case .notifications:
				return "notifications"
			case .on:
				return "on"
			case .off:
				return "off"
			case .all:
				return "all"
			case .owned:
				return "owned"
			case .favorites:
				return "favorites"
			case .noGrouping:
				return "no_grouping"
			case .relationship:
				return "relationship"
			case .status:
				return "status"
			case .sortBy:
				return "sort_by"
			case .filter:
				return "filter"
			case .groupBy:
				return "group_by"
			case .rewardDetailsPopUp:
				return "Reward Details Pop up"
			case .rewardDetailsViewTransaction:
				return "Reward Details View Transaction"
			case .rewardDetailsReadMore:
				return "Reward Details Read More"
			case .rewardsScore:
				return "rewards_score"
			case .maxRewards:
				return "max_rewards"
			case .timeline:
				return "timeline"
			case .rewardIssuesError:
				return "Reward Issues Error"
			case .identifyProblems:
				return "Indentify Problems"
			case .deviceRewards:
				return "Device Rewards"
			case .deviceRewardTransactions:
				return "Device Rewards Transactions"
			case .infoDailyRewards:
				return "info_daily_rewards"
			case .infoQod:
				return "info_qod"
			case .infoPol:
				return "info_pol"
			case .infoCellposition:
				return "info_cell_position"
			case .infoCellCapacity:
				return "info_cell_capacity"
			case .webDocumentation:
				return "Web Documentation"
			case .viewAll:
				return "View all"
			case .multipleIssue:
				return "multipe_issue"
			case .dailyCard:
				return "Daily Card"
			case .dailyForecast:
				return "daily_forecast"
			case .dailyDetails:
				return "daily_details"
			case .hourlyDetailsCard:
				return "Hourly Details Card"
			case .hourlyForecast:
				return "hourly_forecast"
		}
	}
}
