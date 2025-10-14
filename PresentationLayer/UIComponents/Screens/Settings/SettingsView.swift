//
//  SettingsScreenView.swift
//  PresentationLayer
//
//  Created by Danae Kikue Dimou on 27/5/22.
//

import SwiftUI
import Toolkit

struct SettingsView: View {
	@EnvironmentObject var navigationObject: NavigationObject
	@StateObject var settingsViewModel: SettingsViewModel
	@ObservedObject private var mainScreenViewModel: MainScreenViewModel = .shared

	var body: some View {
		ZStack {
			Color(colorEnum: .bg)
				.ignoresSafeArea()

			settingsContainer
			UnitsOptionsModalView(settingsViewModel: settingsViewModel)
		}
		.spinningLoader(show: $settingsViewModel.isLoading)
		.navigationBarBackButtonHidden(settingsViewModel.isShowingUnitsOverlay)
		.navigationBarTitleDisplayMode(.inline)
		.onAppear {
			WXMAnalytics.shared.trackScreen(.settings)
			navigationObject.title = LocalizableString.settings.localized
			navigationObject.navigationBarColor = Color(colorEnum: .bg)
		}
	}

	var settingsContainer: some View {
		ScrollView(showsIndicators: false) {
			VStack(alignment: .leading, spacing: CGFloat(.defaultSpacing)) {
				unitsContainer
				WXMDivider()
				displayContainer
				accountContainer
				feedbackContainer
				helpContainer
				WXMDivider()
				legalContainer
				aboutContainer
				WXMDivider()
				Spacer()
			}
			.padding(CGFloat(.defaultSidePadding))
		}
	}
}

private extension SettingsView {
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
	var notificationsSwitch: some View {
		SettingsButtonView(settingsCase: .notifications,
						   settingCaption: SettingsEnum.notifications.settingsDescription,
						   isToggleInteractionEnabled: true,
						   switchValue: Binding(get: {
			settingsViewModel.areNotificationsEnabled
		},
												set: { _ in
			settingsViewModel.handleNotificationSwitchTap()
		}))
	}

	@ViewBuilder
	var announcementsButton: some View {
		SettingsButtonView(settingsCase: .announcements,
						   settingCaption: SettingsEnum.announcements.settingsDescription) {
			settingsViewModel.handleAnnouncementsTap()
		}
	}

    @ViewBuilder
    var accountContainer: some View {
		accountSectionTitle
		
		notificationsSwitch

		if mainScreenViewModel.isUserLoggedIn {
            Group {
                analyticsSwitch
				changePasswordButton
                logoutButton
                deleteAccountButton
            }
        }

		WXMDivider()
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

	var changePasswordButton: some View {
		SettingsButtonView(
			settingsCase: .changePassword,
			settingCaption: LocalizableString.settingsOptionChangePasswordDescription.localized,
			action: {
				WXMAnalytics.shared.trackEvent(.selectContent, parameters: [.contentType: .changePassword])
				Router.shared.navigateTo(.resetPassword(ViewModelsFactory.getResetPasswordViewModel()))
			}
		)
	}

    var logoutButton: some View {
        SettingsButtonView(
            settingsCase: .logout,
            settingCaption: "",
            action: {
                WXMAnalytics.shared.trackEvent(.selectContent, parameters: [.contentType: .logout])
                settingsViewModel.logoutUser { completed in
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
	var feedbackContainer: some View {
		Group {
			SettingsSectionTitle(title: .feedback)
			SettingsButtonView(
				settingsCase: .joinUserPanel,
				settingCaption: SettingsEnum.joinUserPanel.settingsDescription,
				action: {
					WXMAnalytics.shared.trackEvent(.selectContent, parameters: [.contentType: .userResearchPanel])
					if let url = URL(string: DisplayedLinks.feedbackForm.linkURL) {
						UIApplication.shared.open(url)
					}
				}
			)
		}
		WXMDivider()
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
		announcementsButton
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
                WXMAnalytics.shared.trackEvent(.selectContent, parameters: [.contentType: .documentation])
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
                WXMAnalytics.shared.trackEvent(.selectContent, parameters: [.contentType: .contactSupport,
                                                                      .source: .settingsSource])

				LinkNavigationHelper().openContactSupport(successFailureEnum: .settings,
														  email: mainScreenViewModel.userInfo?.email ?? "",
														  serialNumber: nil,
														  trackSelectContentEvent: false)
			}
        )
    }

	@ViewBuilder
	var legalContainer: some View {
		if mainScreenViewModel.isUserLoggedIn {
			SettingsSectionTitle(title: .legal)
			
			SettingsButtonView(
				settingsCase: .termsOfUse,
				settingCaption: SettingsEnum.termsOfUse.settingsDescription,
				action: {
					settingsViewModel.handleTermsOfUseTap()
				}
			)
			
			SettingsButtonView(
				settingsCase: .privacyPolicy,
				settingCaption: SettingsEnum.privacyPolicy.settingsDescription,
				action: {
					settingsViewModel.handlePrivacyPolicyTap()
				}
			)

			WXMDivider()
		}
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
		NavigationContainerView {
			SettingsView(settingsViewModel: ViewModelsFactory.getSettingsViewModel(userId: ""))
		}
    }
}
