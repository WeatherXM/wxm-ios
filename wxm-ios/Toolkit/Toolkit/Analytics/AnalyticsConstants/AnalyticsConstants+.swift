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

extension Parameter: RawRepresentable, Hashable, CustomStringConvertible {

	public init?(rawValue: String) {
		switch rawValue {
			case "ACTION": self = .action
			case "ACTION_NAME": self = .actionName
			case "APP_ID": self = .appId
			case "CONTENT_NAME": self = .contentName
			case "CONTENT_TYPE": self = .contentType
			case "DATE": self = .date
			case "DEVICE_STATE": self = .deviceState
			case "FILTER": self = .filter
			case "GROUP_BY": self = .groupBy
			case "HAS_WALLET": self = .hasWallet
			case "INDEX": self = .index
			case "ITEM_ID": self = .itemId
			case "ITEM_LIST_ID": self = .itemListId
			case "LOCATION": self = .location
			case "METHOD": self = .method
			case "PROMPT_NAME": self = .promptName
			case "PROMPT_TYPE": self = .promptType
			case "SORT_BY": self = .sortBy
			case "SOURCE": self = .source
			case "STATE": self = .state
			case "STATIONS_OWN": self = .stationsOwn
			case "STATIONS_FAVORITE": self = .stationsFavorite
			case "STATUS": self = .status
			case "STEP": self = .step
			case "SUCCESS": self = .success
			case "UNIT_TEMPERATURE": self = .temperature
			case "THEME": self = .theme
			case "USER_STATE": self = .userState
			case "UNIT_WIND": self = .wind
			case "UNIT_WIND_DIRECTION": self = .windDirection
			case "UNIT_PRECIPITATION": self = .precipitation
			case "UNIT_PRESSURE": self = .pressure
			default:
				if rawValue.starts(with: "STATIONS_OWN_") {
					let stationType = rawValue.replacingOccurrences(of: "STATIONS_OWN_", with: "").lowercased()
					self = .stationsOwnCount(stationType: stationType)
				} else {
					return nil
				}
		}
	}

	public var rawValue: String {
		switch self {
			case .action: return "ACTION"
			case .actionName: return "ACTION_NAME"
			case .appId: return "APP_ID"
			case .contentName: return "CONTENT_NAME"
			case .contentType: return "CONTENT_TYPE"
			case .date: return "DATE"
			case .deviceState: return "DEVICE_STATE"
			case .filter: return "FILTER"
			case .groupBy: return "GROUP_BY"
			case .hasWallet: return "HAS_WALLET"
			case .index: return "INDEX"
			case .itemId: return "ITEM_ID"
			case .itemListId: return "ITEM_LIST_ID"
			case .location: return "LOCATION"
			case .method: return "METHOD"
			case .promptName: return "PROMPT_NAME"
			case .promptType: return "PROMPT_TYPE"
			case .sortBy: return "SORT_BY"
			case .source: return "SOURCE"
			case .state: return "STATE"
			case .stationsOwn: return "STATIONS_OWN"
			case .stationsOwnCount(let stationType): return "STATIONS_OWN_\(stationType.uppercased())"
			case .stationsFavorite: return "STATIONS_FAVORITE"
			case .status: return "STATUS"
			case .step: return "STEP"
			case .success: return "SUCCESS"
			case .temperature: return "UNIT_TEMPERATURE"
			case .theme: return "THEME"
			case .userState: return "USER_STATE"
			case .wind: return "UNIT_WIND"
			case .windDirection: return "UNIT_WIND_DIRECTION"
			case .precipitation: return "UNIT_PRECIPITATION"
			case .pressure: return "UNIT_PRESSURE"
		}
	}

	public var description: String {
		switch self {
			case .action, .actionName, .contentName, .promptName, .promptType,
					.step, .state, .date, .theme, .temperature, .wind, .windDirection, .precipitation, .pressure,
					.sortBy, .filter, .groupBy, .status, .appId, .hasWallet, .stationsOwn, .stationsOwnCount(_), .stationsFavorite, .userState, .deviceState:
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
			case .appUpdatePrompt:
				return "App Update Prompt"
			case .appUpdatePromptResult:
				return "App Update Prompt Result"
			case .camera:
				return "camera"
			case .gallery:
				return "gallery"
			case .selectDevice:
				return "Select Device"
			case .userDeviceList:
				return "User Device List"
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
				return "Claiming Result"
			case .searchLocation:
				return "Search Location"
			case .claimingAddressSearch:
				return "Claiming Address Search"
			case .cancel:
				return "Cancel"
			case .retry:
				return "Retry"
			case .discard:
				return "Discard"
			case .update:
				return "Update"
			case .viewStation:
				return "View Station"
			case .updateStation:
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
				return "Change Frequency Result"
			case .changeStationFrequency:
				return "Change Station Frequency"
			case .change:
				return "Change"
			case .changePassword:
				return "Change Password"
			case .announcements:
				return "Announcements"
			case .termsOfUse:
				return "Terms of Use"
			case .privacyPolicy:
				return "Privacy Policy"
			case .announcementButton:
				return "Announcement Button"
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
			case .removeStationPhoto:
				return "Remove Station Photo"
			case .deviceAlertsSource:
				return "device_alerts"
			case .stationOffline:
				return "station_offline"
			case .deviceInfoSource:
				return "device_info"
			case .settingsSource:
				return "settings"
			case .claimingSource:
				return "claiming"
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
			case .bleScanAgain:
				return "BLE Scan Again"
			case .frequencyDocumentation:
				return "Frequency Documentation"
			case .failure:
				return "Failure"
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
			case .failureOtaContentId:
				return "failure_ota"
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
				return "follow"
			case .unfollow:
				return "unfollow"
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
			case .deviceRewardsCard:
				return "Device Rewards Card"
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
			case .forecastNextSevenDays:
				return "forecast_next_7_days"
			case .rewardSplittingInDailyReward:
				return "Reward Splitting In Daily Reward"
			case .rewardSplittingInDeviceSettings:
				return "Reward Splitting In Device Settings"
			case .rewardSplitting:
				return "reward_splitting"
			case .noRewardSplitting:
				return "no_reward_splitting"
			case .stakeholder:
				return "stakeholder"
			case .nonStakeholder:
				return "non_stakeholder"
			case .rewardSplitPressed:
				return "Reward Split pressed"
			case .stakeholderContentType:
				return "Stakeholder"
			case .tokensEarnedPress:
				return "Tokens Earned pressed"
			case .addStationPhoto:
				return "Add Station Photo"
			case .exitPhotoVerification:
				return "Exit Photo Verification"
			case .cancelUploadingPhotos:
				return "Cancel Uploading Photos"
			case .retryUploadingPhotos:
				return "Retry Uploading Photos"
			case .startUploadingPhotos:
				return "Start Uploading Photos"
			case .uploadingPhotosSuccess:
				return "Uploading Photos Success"
			case .goToPhotoVerification:
				return "Go To Photo Verification"
			case .started:
				return "started"
			case .completed:
				return "completed"
			case .proPromotionCTA:
				return "Pro Promotion CTA"
			case .remote:
				return "remote"
			case .remoteDevicesList:
				return "remote_devices_list"
			case .local:
				return "local"
			case .localForecast:
				return "local_forecast"
			case .localForecastDetails:
				return "local_forecast_details"
			case .localHistory:
				return "local_history"
			case .localCell:
				return "local_cell"
			case .localProfile:
				return "local_profile"
			case .localNetworkStats:
				return "local_network_stats"
			case .proPromotion:
				return "pro_promotion"
			case .infoCellDataQuality:
				return "info_cell_data_quality"
			case .selectMapLayer:
				return "Select Map Layer"
			case .default:
				return "default"
			case .dataQuality:
				return "data_quality"
		}
	}
}
