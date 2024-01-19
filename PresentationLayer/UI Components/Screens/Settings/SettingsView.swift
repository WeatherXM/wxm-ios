//
//  SettingsScreenView.swift
//  PresentationLayer
//
//  Created by Danae Kikue Dimou on 27/5/22.
//

import SwiftUI
import Toolkit

struct SettingsView: View {
    @StateObject var settingsViewModel: SettingsViewModel
	private let mainScreenViewModel: MainScreenViewModel = .shared

    var body: some View {
        ZStack {
            settingsContainer
            UnitsOptionsModalView(settingsViewModel: settingsViewModel)
        }
        .spinningLoader(show: $settingsViewModel.isLoading)
        .navigationBarBackButtonHidden(settingsViewModel.isShowingUnitsOverlay)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            Logger.shared.trackScreen(.settings)
        }
    }

    var settingsContainer: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: CGFloat(.defaultSpacing)) {
                unitsContainer
                WXMDivider()
                displayContainer
                accountContainer
                helpContainer
                WXMDivider()
                aboutContainer
                WXMDivider()
                Spacer()
            }
            .padding(CGFloat(.defaultSidePadding))
        }
    }

    @ViewBuilder
    var unitsContainer: some View {
        unitsSectionTitle
        temperature
        precipitation
        windSpeed
        windDirection
        pressure
    }

    var unitsSectionTitle: some View {
        SettingsSectionTitle(title: .units)
    }

    var temperature: some View {
        SettingsButtonView(
            settingsCase: .temperature,
            settingCaption: settingsViewModel.unitsManager.temperatureUnit.settingUnitFriendlyName,
            unitCaseModal: $settingsViewModel.unitCaseModal,
            isShowingUnitsOverlay: $settingsViewModel.isShowingUnitsOverlay,
            action: {}
        )
    }

    var precipitation: some View {
        SettingsButtonView(
            settingsCase: .precipitation,
            settingCaption: settingsViewModel.unitsManager.precipitationUnit.settingUnitFriendlyName,
            unitCaseModal: $settingsViewModel.unitCaseModal,
            isShowingUnitsOverlay: $settingsViewModel.isShowingUnitsOverlay,
            action: {}
        )
    }

    var windSpeed: some View {
        SettingsButtonView(
            settingsCase: .windSpeed,
            settingCaption: settingsViewModel.unitsManager.windSpeedUnit.settingUnitFriendlyName,
            unitCaseModal: $settingsViewModel.unitCaseModal,
            isShowingUnitsOverlay: $settingsViewModel.isShowingUnitsOverlay,
            action: {}
        )
    }

    var windDirection: some View {
        SettingsButtonView(
            settingsCase: .windDirection,
            settingCaption: settingsViewModel.unitsManager.windDirectionUnit.settingUnitFriendlyName,
            unitCaseModal: $settingsViewModel.unitCaseModal,
            isShowingUnitsOverlay: $settingsViewModel.isShowingUnitsOverlay,
            action: {}
        )
    }

    var pressure: some View {
        SettingsButtonView(
            settingsCase: .pressure,
			settingCaption: settingsViewModel.unitsManager.pressureUnit.settingUnitFriendlyName,
            unitCaseModal: $settingsViewModel.unitCaseModal,
            isShowingUnitsOverlay: $settingsViewModel.isShowingUnitsOverlay,
            action: {}
        )
    }

    @ViewBuilder
    var accountContainer: some View {
        if mainScreenViewModel.isUserLoggedIn {
            Group {
                accountSectionTitle
                analyticsSwitch
                logoutButton
                deleteAccountButton
            }
            WXMDivider()
        }
    }

    var accountSectionTitle: some View {
        SettingsSectionTitle(title: .account)
    }

    var analyticsSwitch: some View {
        SettingsButtonView(settingsCase: .analytics,
                           settingCaption: LocalizableString.settingsOptionAnalyticsDescription.localized,
                           switchValue: $settingsViewModel.isAnalyticsCollectionEnabled) {
            settingsViewModel.isAnalyticsCollectionEnabled?.toggle()
        }
    }

    var logoutButton: some View {
        SettingsButtonView(
            settingsCase: .logout,
            settingCaption: "",
            action: {
                Logger.shared.trackEvent(.selectContent, parameters: [.contentType: .logout])
                settingsViewModel.logoutUser { completion in
                    if completion {
                        mainScreenViewModel.selectedTab = .homeTab
                        mainScreenViewModel.isUserLoggedIn = false
                        Router.shared.popToRoot()
                    }
                }
            }
        )
    }

    var deleteAccountButton: some View {
        Button {
            Router.shared.navigateTo(.deleteAccount(ViewModelsFactory.getDeleteAccountViewModel(userId: settingsViewModel.userID)))
        } label: {
            deleteAccountStyle
        }
    }

    var deleteAccountStyle: some View {
        HStack {
            VStack(alignment: .leading) {
                deleteAccountTitle
                deleteAccountCaption
                deleteAccountWarning
            }
            Spacer()
        }
        .contentShape(Rectangle())
    }

    var deleteAccountTitle: some View {
        Text(SettingsEnum.deleteAccount.settingsTitle)
            .font(.system(size: CGFloat(.largeTitleFontSize)))
            .foregroundColor(Color(colorEnum: .text))
    }

    var deleteAccountCaption: some View {
        Text(SettingsEnum.deleteAccountCaption.settingsDescription)
            .font(.system(size: CGFloat(.normalFontSize)))
            .foregroundColor(Color(colorEnum: .darkGrey))
    }

    var deleteAccountWarning: some View {
        Text(SettingsEnum.deleteAccountWarning.settingsDescription)
            .font(.system(size: CGFloat(.normalFontSize)))
            .foregroundColor(Color(colorEnum: .text))
    }

    @ViewBuilder
    var displayContainer: some View {
        Group {
            SettingsSectionTitle(title: .display)
            changeThemeButton
        }
        WXMDivider()
    }

    @ViewBuilder
    var changeThemeButton: some View {
        SettingsButtonView(settingsCase: .theme,
                           settingCaption: mainScreenViewModel.theme.description,
                           unitCaseModal: $settingsViewModel.unitCaseModal,
                           isShowingUnitsOverlay: $settingsViewModel.isShowingUnitsOverlay)
    }

    @ViewBuilder
    var helpContainer: some View {
        helpSectionTitle
        documentationButton
        contactUsButton
    }

    var helpSectionTitle: some View {
        SettingsSectionTitle(title: .help)
    }

    var documentationButton: some View {
        SettingsButtonView(
            settingsCase: .documentation,
            settingCaption: SettingsEnum.documentation.settingsDescription,
            action: {
                Logger.shared.trackEvent(.selectContent, parameters: [.contentType: .documentation])
                if let url = URL(string: DisplayedLinks.documentationLink.linkURL) {
                    UIApplication.shared.open(url)
                }
            }
        )
    }

    var contactUsButton: some View {
        SettingsButtonView(
            settingsCase: .contactSupport,
            settingCaption: SettingsEnum.contactSupport.settingsDescription,
            action: {
                Logger.shared.trackEvent(.selectContent, parameters: [.contentType: .contactSupport,
                                                                      .source: .settingsSource])

				HelperFunctions().openContactSupport(successFailureEnum: .settings,
													 email: mainScreenViewModel.userInfo?.email ?? "",
													 serialNumber: nil,
													 trackSelectContentEvent: false)
			}
        )
    }

    @ViewBuilder
    var aboutContainer: some View {
        SettingsSectionTitle(title: .about)
        SettingsButtonView(
            settingsCase: .appVersion(installationId: settingsViewModel.installationId),
            settingCaption: SettingsEnum.appVersion(installationId: settingsViewModel.installationId).settingsDescription,
            action: {
            }
        )
    }
}

struct Previews_SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(settingsViewModel: ViewModelsFactory.getSettingsViewModel(userId: ""))
    }
}
