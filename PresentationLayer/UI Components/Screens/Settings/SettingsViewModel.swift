//
//  SettingsViewModel.swift
//  PresentationLayer
//
//  Created by danaekikue on 17/6/22.
//
import Combine
import DomainLayer
import SwiftUI
import Toolkit

final class SettingsViewModel: ObservableObject {
    @Published var isShowingUnitsOverlay: Bool = false
    @Published var totalUnitOptions: Int = 0
    @Published var unitCaption: String = ""
    @Published var unitCaseModal: SettingsEnum = .temperature
    @Published var installationId: String?
    @Published var isLoading: Bool = false
	@Published var areNotificationsEnabled: Bool? = false
    @Published var isAnalyticsCollectionEnabled: Bool? = false {
        didSet {
            guard let isAnalyticsCollectionEnabled else {
                return
            }
            settingsUseCase.optInOutAnalytics(isAnalyticsCollectionEnabled)
        }
    }

    let userID: String
	let unitsManager: WeatherUnitsManager = .default
    private let settingsUseCase: SettingsUseCase
    private var cancellableSet: Set<AnyCancellable> = .init()
	private let mainVM: MainScreenViewModel = .shared

    init(userId: String, settingsUseCase: SettingsUseCase) {
        self.userID = userId
        self.settingsUseCase = settingsUseCase
        self.isAnalyticsCollectionEnabled = settingsUseCase.isAnalyticsEnabled
        setInstallationId()
    }

    @ViewBuilder
    func setDescriptionContent(settingsCase _: SettingsEnum) -> some View {
        Text(unitCaption)
    }

    @ViewBuilder
    func getUnitOptions(mainScreenViewmodel: MainScreenViewModel) -> some View {
        switch unitCaseModal {
            case .temperature:
                ForEach(TemperatureUnitsEnum.allCases, id: \.unit) { option in
					UnitsOptionView(option: option.settingUnitFriendlyName, unitCase: self.unitCaseModal, isOptionActive: option == self.unitsManager.temperatureUnit)
                        .environmentObject(self)
                }
            case .precipitation:
                ForEach(PrecipitationUnitsEnum.allCases, id: \.unit) { option in
					UnitsOptionView(option: option.settingUnitFriendlyName, unitCase: self.unitCaseModal, isOptionActive: option == self.unitsManager.precipitationUnit)
                        .environmentObject(self)
                }
            case .windSpeed:
                ForEach(WindSpeedUnitsEnum.allCases, id: \.unit) { option in
					UnitsOptionView(option: option.settingUnitFriendlyName, unitCase: self.unitCaseModal, isOptionActive: option == self.unitsManager.windSpeedUnit)
                        .environmentObject(self)
                }
            case .windDirection:
                ForEach(WindDirectionUnitsEnum.allCases, id: \.unit) { option in
					UnitsOptionView(option: option.settingUnitFriendlyName, unitCase: self.unitCaseModal, isOptionActive: option == self.unitsManager.windDirectionUnit)
                        .environmentObject(self)
                }
            case .pressure:
                ForEach(PressureUnitsEnum.allCases, id: \.unit) { option in
					UnitsOptionView(option: option.settingUnitFriendlyName, unitCase: self.unitCaseModal, isOptionActive: option == self.unitsManager.pressureUnit)
                        .environmentObject(self)
                }
            case .theme:
                ForEach(Theme.allCases, id: \.self) { option in
					UnitsOptionView(option: option.description, unitCase: self.unitCaseModal, isOptionActive: option == self.mainVM.theme)
                        .environmentObject(self)
                }
            default:
                Text("")
        }
    }

	func setUnits(unitCase: SettingsEnum, chosenOption: String) {
		switch unitCase {
			case .temperature:
				TemperatureUnitsEnum.allCases.forEach {
					if chosenOption == $0.settingUnitFriendlyName {
						unitsManager.temperatureUnit = $0
					}
				}
			case .precipitation:
				PrecipitationUnitsEnum.allCases.forEach {
					if chosenOption == $0.settingUnitFriendlyName {
						unitsManager.precipitationUnit = $0
					}
				}
			case .windSpeed:
				WindSpeedUnitsEnum.allCases.forEach {
					if chosenOption == $0.settingUnitFriendlyName {
						unitsManager.windSpeedUnit = $0
					}
				}
			case .windDirection:
				WindDirectionUnitsEnum.allCases.forEach {
					if chosenOption == $0.settingUnitFriendlyName {
						unitsManager.windDirectionUnit = $0
					}
				}
			case .pressure:
				PressureUnitsEnum.allCases.forEach {
					if chosenOption == $0.settingUnitFriendlyName {
						unitsManager.pressureUnit = $0
					}
				}
			case .theme:
				guard let selectedTheme = Theme(description: chosenOption) else {
					return
				}
					mainVM.setTheme(selectedTheme)
			default:
				break
		}
	}

    func logoutUser(completion: @escaping (Bool) -> Void) {
        let logoutAction: GenericCallback<String?> = { [weak  self] _ in
            guard let self else {
                return
            }

            self.isLoading = true

            do {
                try settingsUseCase.logout().sink { [weak self] response in
                    self?.isLoading = false

                    if let error = response.error {
                        let info = error.uiInfo
                        Toast.shared.show(text: info.description?.attributedMarkdown ?? "")
                        completion(false)
                        return
                    }

                    completion(true)
                }.store(in: &cancellableSet)
            } catch {
                print(error)
                isLoading = false
                completion(false)
            }
        }

        let obj = AlertHelper.AlertObject(title: LocalizableString.logoutAlertTitle.localized,
                                          message: LocalizableString.logoutAlertText.localized,
                                          okAction: (LocalizableString.yes.localized, logoutAction))
        AlertHelper().showAlert(obj)
    }

	func handleNotificationSwitchTap() {
		
	}
}

private extension SettingsViewModel {
    func setInstallationId() {
        Task { @MainActor in
            self.installationId = await FirebaseManager.shared.getInstallationId()
        }
    }
}

extension SettingsViewModel: HashableViewModel {
    func hash(into hasher: inout Hasher) {
        hasher.combine(userID)
    }
}
