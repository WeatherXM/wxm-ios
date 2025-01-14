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
let networkDomain = "network_domain"
let analyticsScreenView: String = AnalyticsEventScreenView
let analyticsScreenNameKey: String = AnalyticsParameterScreenName

public enum Screen: String {
	case splash = "Splash Screen"
	case analytics = "Analytics Opt-In Prompt"
	case explorerLanding = "Explorer (Landing)"
	case explorer = "Explorer"
	case claimM5 = "Claim M5"
	case claimHelium = "Claim Helium"
	case claimDapp = "Claim Dapp"
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
	case forecastDetails = "Device Forecast Details"
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
	case dailyRewardInfo = "Daily Reward info"
	case dataQualityInfo = "Data Quality info"
	case locationQualityInfo = "Location Quality info"
	case cellRankingInfo = "Cell ranking info"
	case rewardIssues = "Reward Issues"
	case boostDetails = "Boost Detail"
	case cellCapacityInfo = "Cell Capacity info"
	case rewardAnalytics = "Reward Analytics"
	case temperatureBars = "Temperature Bars Explanation"
}

public enum Event: String {
	case userAction = "USER_ACTION"
	case viewContent = "VIEW_CONTENT"
	case prompt = "PROMPT"
	case selectContent = "SELECT_CONTENT"
}

public enum Parameter: String {
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
	case status = "STATUS"
	case appId = "APP_ID"
	case stationsOwn = "STATIONS_OWN"
	case hasWallet = "HAS_WALLET"
	case deviceState = "DEVICE_STATE"
	case userState = "USER_STATE"
}

public enum ParameterValue {
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
	case announcements
	case termsOfUse
	case privacyPolicy
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
	case openState
	case closeState
	case rewardsCard
	case removeDevice
	case deviceAlertsSource
	case stationOffline
	case deviceInfoSource
	case settingsSource
	case claimingSource
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
	case userResearchPanel
	case bleScanAgain
	case frequencyDocumentation
	case failure
	case success
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
	case tokenClaimingResult
	case tokenContract
	case rewardContract
	case lastRunHash
	case totalSupply
	case circulatingSupply
	case deviceDetailsPopUp
	case deviceDetailsShare
	case deviceDetailsFollow
	case follow
	case unfollow
	case stationDetailsChip
	case warnings
	case region
	case otaUpdate
	case lowBatteryItem
	case stationRegion
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
	case notifications
	case on
	case off
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
	case deviceRewardsCard
	case deviceRewardTransactions
	case rewardsScore
	case maxRewards
	case timeline
	case rewardIssuesError
	case infoDailyRewards
	case infoQod
	case infoPol
	case infoCellposition
	case infoCellCapacity
	case webDocumentation
	case viewAll
	case multipleIssue
	case dailyCard
	case dailyForecast
	case dailyDetails
	case hourlyDetailsCard
	case hourlyForecast
	case forecastNextSevenDays
	case rewardSplittingInDailyReward
	case rewardSplittingInDeviceSettings
	case rewardSplitting
	case noRewardSplitting
	case stakeholder
	case nonStakeholder
	case rewardSplitPressed
	case stakeholderContentType
	case tokensEarnedPress
	case addStationPhoto
	case exitPhotoVerification
	case cancelUploadingPhotos
	case retryUploadingPhotos
	case startUploadingPhotos
	case uploadingPhotoSuccess
	case goToPhotoVerification
	case custom(String)
}
