//
//  AnalyticsConstants.swift
//  Toolkit
//
//  Created by Pantelis Giazitsis on 18/5/23.
//

import Foundation
import FirebaseAnalytics
import Firebase

let installationIdKey: String = "installation_id"

public enum Screen: String {
    case splash = "Splash Screen"
    case analytics = "Analytics Opt-In Prompt"
    case explorerLanding = "Explorer (Landing)"
    case explorer = "Explorer"
    case claimM5 = "Claim M5"
    case claimHelium = "Claim Helium"
    case wallet = "Wallet"
    case deleteAccount = "Delete Account"
    case deviceAlerts = "Device Alerts"
    case heliumOTA = "OTA Update"
    case history = "Device History"
    case deviceList = "Device List"
    case settings = "App Settings"
    case login = "Login"
    case signup = "Sign Up"
    case passwordReset = "Password Reset"
    case profile = "Account"
    case currentWeather = "Device Current Weather"
    case forecast = "Device Forecast"
    case rewards = "Device Rewards"
    case stationSettings = "Device Settings"
    case rewardTransactions = "Device Reward Transactions"
    case appUpdatePrompt = "App Update Prompt"
    case widgetSelectStation = "Widget Station Selection"
    case passwordConfirm = "Password Confirm"
    case claimDeviceTypeSelection = "Claim device type selection"
    case changeStationName = "Change Station Name"
    case changeFrequency = "Change Frequency"
    case rebootStation = "Reboot Station"
    case explorerCellScreen = "Explorer Cell Screen"
    case networkStats = "Network Stats"
    case explorerSearch = "Explorer Search"
    case sortFilter = "Sort Filter"
	case deviceRewardsDetails = "Device Rewards Details"
}

public enum Event: String, CustomStringConvertible {
    case userAction = "USER_ACTION"
    case viewContent = "VIEW_CONTENT"
    case prompt = "PROMPT"
    case selectContent = "SELECT_CONTENT"

    public var description: String {
        switch self {
            case .userAction, .viewContent, .prompt:
                return rawValue
            case .selectContent:
                return AnalyticsEventSelectContent
        }
    }
}

public enum Parameter: String, CustomStringConvertible {
    case action = "ACTION"
    case actionName = "ACTION_NAME"
    case contentType = "CONTENT_TYPE"
    case contentName = "CONTENT_NAME"
    case contentId = "CONTENT_ID"
    case itemId = "ITEM_ID"
    case location = "LOCATION"
    case itemListId = "ITEM_LIST_ID"
    case method = "METHOD"
    case success = "SUCCESS"
    case promptName = "PROMPT_NAME"
    case promptType = "PROMPT_TYPE"
    case step = "STEP"
    case state = "STATE"
    case index = "INDEX"
    case source = "SOURCE"
    case date = "DATE"
    case theme = "THEME"
    case temperature = "UNIT_TEMPERATURE"
    case wind = "UNIT_WIND"
    case windDirection = "UNIT_WIND_DIRECTION"
    case precipitation = "UNIT_PRECIPITATION"
    case pressure = "UNIT_PRESSURE"
    case sortBy = "SORT_BY"
    case filter = "FILTER"
    case groupBy = "GROUP_BY"

    public var description: String {
        switch self {
            case .action, .actionName, .contentName, .contentId, .promptName, .promptType, 
                    .step, .state, .date, .theme, .temperature, .wind, .windDirection, .precipitation, .pressure,
                    .sortBy, .filter, .groupBy:
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

public enum ParameterValue: RawRepresentable {
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
            case .forecastDay:
                return "Forecast Day"
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
            case .bleScanAgain:
                return "BLE Scan Again"
            case .frequencyDocumentation:
                return "Frequency Documentation"
            case .failure:
                return "Failure"
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
            case .tokenomics:
                return "Tokenomics"
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
            case .deviceDetailsAddress:
                return "Device Details Address"
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
			case .rewardDetailsError:
				return "Reward Details Error"
			case .identifyProblems:
				return "Indentify Problems"
			case .deviceRewards:
				return "Device Rewards"
			case .deviceRewardTransactions:
				return "Device Rewards Transactions"
		}
    }

    case selectDevice
    case userDeviceList
    case transactionOnExplorer
    case deviceTransactions
    case shareStationInfo
    case stationInfo
    case myLocation
    case claiming
    case claimingResult
    case cancel
    case retry
    case viewStation
    case updateFirmware
    case changeStationNameResult
    case changeStationName
    case edit
    case clear
    case changeFrequencyResult
    case changeStationFrequency
    case change
	case changePassword
    case heliumBLEPopupError
    case heliumBLEPopup
    case searchLocation
    case claimingAddressSearch
    case quit
    case tryAgain
    case login
    case signup
    case email
    case sendEmailForgotPassword
    case forgotPasswordEmail
    case OTAError
    case failureOTA
    case connect
    case download
    case install
    case OTAResult
    case walletMissing
    case warnPromptType
    case viewAction
    case dismissAction
    case action
    case OTAAvailable
    case lowBattery
    case walletCompatibility
    case info
    case forecastDay
    case openState
    case closeState
    case rewardsCard
    case removeDevice
    case deviceAlertsSource
    case deviceInfoSource
    case settingsSource
    case errorSource
    case networkStatsSource
    case contactSupport
    case historyDay
    case walletTransactions
    case editWallet
    case createMetamask
    case walletTermsOfService
    case scanQRWallet
    case logout
    case documentation
    case bleScanAgain
    case frequencyDocumentation
    case failure
    case light
    case dark
    case system
    case celsius
    case fahrenheit
    case kmPerHour
    case milesPerHour
    case metersPerSecond
    case knots
    case beaufort
    case degrees
    case cardinal
    case millimeters
    case inches
    case hectopascal
    case inchOfMercury
    case loginContentId
    case emailMethod
    case signUpContentId
    case forgotPasswordEmailContentId
    case failureOtaContentId
    case otaResultContentId
    case failureContentId
    case claimingResultContentId
    case changeStationNameResultContentId
    case changeFrequencyResultContentId
    case openShop
    case openStationShop
    case openManufacturerContact
    case total
    case claimed
    case active
    case learnMore
    case dataDays
    case allocatedRewards
    case totalStations
    case claimedStations
    case activeStations
    case buyStation
    case explorerSearch
    case explorerSettings
    case explorerPopUp
    case networkSearch
    case recent
    case search
    case location
    case station
    case tokenomics
    case deviceDetailsPopUp
    case deviceDetailsShare
    case deviceDetailsFollow
    case follow
    case unfollow
    case deviceDetailsAddress
    case devicesListFollow
    case explorerDevicesListFollow
    case deviceDetailsSettings
    case filters
    case filtersReset
    case filtersCancel
    case filtersSave
    case dateAdded
    case name
    case lastActive
    case all
    case owned
    case favorites
    case noGrouping
    case relationship
    case status
    case sortBy
    case filter
    case groupBy
	case rewardDetailsPopUp
	case rewardDetailsViewTransaction
	case rewardDetailsReadMore
	case identifyProblems
	case deviceRewards
	case deviceRewardTransactions
	case rewardsScore
	case maxRewards
	case timeline
	case rewardDetailsError
    case custom(String)
}
