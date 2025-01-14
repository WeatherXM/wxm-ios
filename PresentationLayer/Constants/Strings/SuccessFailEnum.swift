//
//  SuccessFailEnum.swift
//  PresentationLayer
//
//  Created by Hristos Condrea on 8/6/22.
//

import Foundation

enum SuccessFailEnum: CustomStringConvertible {
	case settings
	case register
	case weatherStations
	case claimDeviceFlow
	case otaFlow
	case resetPassword
	case noView
	case noTransactions
	case rebootStation
	case changeFrequency
	case stationOffline
	case explorerDeviceList
	case explorerDeviceDetail
	case networkStats
	case myWallet
	case overview
	case stationForecast
	case stationRewards
	case stationRewardsIssue
	case deviceInfo
	case history
	case profile
	case deleteAccount
	case editLocation
	case rewardDetails
	case rewardAnalytics
	case gallery

	var description: String {
		switch self {
			case .settings:
				return ""
			case .register:
				return Constants.noActivationEmailTitle
			case .weatherStations:
				return ""
			case .claimDeviceFlow:
				return Constants.cannotClaimDeviceTitleEmail
			case .otaFlow:
				return Constants.cannotCompleteOTATitleEmail
			case .resetPassword:
				return ""
			case .noView:
				return ""
			case .noTransactions:
				return ""
			case .rebootStation:
				return Constants.cannotRebootTitleEmail
			case .changeFrequency:
				return Constants.cannotChangeFrequencyTitleEmail
			case .stationOffline:
				return Constants.weatherStationOffline
			case .explorerDeviceList:
				return Constants.explorerDeviceList
			case .explorerDeviceDetail:
				return Constants.explorerDeviceDetails
			case .networkStats:
				return Constants.networkStats
			case .myWallet:
				return Constants.myWallet
			case .overview:
				return Constants.overview
			case .stationForecast:
				return Constants.stationForecast
			case .stationRewards:
				return Constants.stationRewards
			case .deviceInfo:
				return Constants.deviceInfo
			case .history:
				return Constants.history
			case .stationRewardsIssue:
				return Constants.stationRewardsIssue
			case .profile:
				return Constants.profile
			case .deleteAccount:
				return ""
			case .editLocation:
				return ""
			case .rewardDetails:
				return ""
			case .rewardAnalytics:
				return ""
			case .gallery:
				return ""
		}
	}
}

private extension SuccessFailEnum {
	enum Constants {
		static let weatherStationOffline = "Weather Station Offline"
		static let cannotClaimDeviceTitleEmail = "Cannot claim device"
		static let cannotCompleteOTATitleEmail = "Cannot complete OTA update"
		static let cannotRebootTitleEmail = "Cannot reboot station"
		static let cannotChangeFrequencyTitleEmail = "Cannot chage station frequency"
		static let explorerDeviceList = "Explorer Device List"
		static let explorerDeviceDetails = "Explorer Device Details"
		static let networkStats = "Network Stats"
		static let myWallet = "My Wallet"
		static let overview = "Overview"
		static let stationForecast = "Station Forecast"
		static let stationRewards = "Station Rewards"
		static let deviceInfo = "Device Info"
		static let history = "History"
		static let noActivationEmailTitle = "No activation email"
		static let stationRewardsIssue = "Station Rewards Issue"
		static let profile = "Profile"
	}
}
