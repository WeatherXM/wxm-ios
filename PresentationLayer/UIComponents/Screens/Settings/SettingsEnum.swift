//
//  SettingsEnum.swift
//  PresentationLayer
//
//  Created by danaekikue on 17/6/22.
//

import Foundation
import SwiftUI

enum SettingsEnum {
	case units, account, display, theme, temperature, precipitation, windSpeed, windDirection, pressure, notifications, announcements, analytics, logout, changePassword,
		 help, legal, termsOfUse, privacyPolicy, about, appVersion(installationId: String?), documentation, contactSupport, deleteAccount, deleteAccountCaption, deleteAccountWarning,
		 deleteAccountGeneralInfo, deleteAccountMoreInfoLink, toDeleteTitle, toDeleteName, toDeleteAddress, toDeletePersonalData,
		 notDeleteTitle, notDeleteWeatherData, notDeleteRewards, noCollectDataTitle, contactForSupport, feedback, joinUserPanel

	var sectionTitle: String {
		switch self {
			case .units:
				return LocalizableString.Settings.weatherUnits.localized
			case .account:
				return LocalizableString.account.localized
			case .help:
				return LocalizableString.Settings.help.localized
			case .display:
				return LocalizableString.display.localized
			case .about:
				return LocalizableString.about.localized
			case .legal:
				return LocalizableString.legal.localized
			case .feedback:
				return LocalizableString.feedback.localized
			default:
				return ""
		}
	}
	
	var settingsTitle: String {
		switch self {
			case .temperature:
				return LocalizableString.temperature.localized
			case .precipitation:
				return LocalizableString.precipitation.localized
			case .windSpeed:
				return LocalizableString.windSpeed.localized
			case .windDirection:
				return LocalizableString.windDirection.localized
			case .pressure:
				return LocalizableString.pressure.localized
			case .analytics:
				return LocalizableString.settingsOptionAnalyticsTitle.localized
			case .announcements:
				return LocalizableString.Settings.announcements.localized
			case .notifications:
				return LocalizableString.Settings.notifications.localized
			case .changePassword:
				return LocalizableString.settingsOptionChangePasswordTitle.localized
			case .logout:
				return LocalizableString.logout.localized
			case .documentation:
				return LocalizableString.Settings.documentation.localized
			case .contactSupport:
				return  LocalizableString.contactSupport.localized
			case .deleteAccount:
				return LocalizableString.Settings.deleteMyAccount.localized
			case .theme:
				return LocalizableString.theme.localized
			case .appVersion:
				return LocalizableString.appVersion.localized
			case .joinUserPanel:
				return LocalizableString.Settings.joinUserPanelTitle.localized
			case .termsOfUse:
				return LocalizableString.Settings.termsOfUse.localized
			case .privacyPolicy:
				return LocalizableString.Settings.privacyPolicy.localized
			default:
				return ""
		}
	}
	
	var settingsDescription: String {
		switch self {
			case .documentation:
				return LocalizableString.Settings.documentationDescription.localized
			case .contactSupport:
				return LocalizableString.Settings.contactSupportDescritpion.localized
			case .deleteAccountCaption:
				return LocalizableString.Settings.deleteAccountCaption.localized
			case .changePassword:
				return LocalizableString.settingsOptionChangePasswordDescription.localized
			case .deleteAccountWarning:
				return LocalizableString.Settings.deleteAccountWarning.localized
			case .appVersion(let installationId):
				let suffix = installationId != nil ? " - \(installationId!)" : ""
				var versionString = "\(Bundle.main.releaseVersionNumberPretty) (\(Bundle.main.buildVersionNumberPretty))\(suffix)"
				if let branchName: String = Bundle.main.getConfiguration(for: .branchName) {
					versionString.append(" - \(branchName)")
				}
				return versionString
			case .notifications:
				return LocalizableString.Settings.notificationsDescription.localized
			case .announcements:
				return LocalizableString.Settings.announcementsDescription.localized
			case .joinUserPanel:
				return LocalizableString.Settings.joinUserPanelDescription.localized
			case .termsOfUse:
				return LocalizableString.Settings.termsOfUseDescription.localized
			case .privacyPolicy:
				return LocalizableString.Settings.privacyPolicyDescription.localized
			default:
				return ""
		}
	}
	
	var settingsDeleteAccountInfo: String {
		switch self {
			case .deleteAccountGeneralInfo:
				return LocalizableString.DeleteAccount.generalInfo.localized
			case .deleteAccountMoreInfoLink:
				return LocalizableString.DeleteAccount.moreInfoLink.localized
			case .toDeleteTitle:
				return LocalizableString.DeleteAccount.toDeleteTitle.localized
			case .toDeleteName:
				return LocalizableString.DeleteAccount.toDeleteName.localized
			case .toDeleteAddress:
				return LocalizableString.DeleteAccount.toDeleteAddress.localized
			case .toDeletePersonalData:
				return LocalizableString.DeleteAccount.toDeletePersonalData.localized
			case .notDeleteTitle:
				return LocalizableString.DeleteAccount.notDeleteTitle.localized
			case .notDeleteWeatherData:
				return LocalizableString.DeleteAccount.notDeleteWeatherData.localized
			case .notDeleteRewards:
				return LocalizableString.DeleteAccount.notDeleteRewards.localized
			case .noCollectDataTitle:
				return LocalizableString.DeleteAccount.noCollectDataTitle.localized
			case .contactForSupport:
				return LocalizableString.DeleteAccount.contactForSupport.localized
			default:
				return ""
		}
	}
}
