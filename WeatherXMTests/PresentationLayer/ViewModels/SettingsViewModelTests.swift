//
//  SettingsViewModelTests.swift
//  WeatherXMTests
//
//  Created by Pantelis Giazitsis on 2/4/25.
//

import Testing
@testable import WeatherXM
import DomainLayer

private class WeatherManager: WeatherUnitsManagerApi {
	var temperatureUnit: TemperatureUnitsEnum = .celsius
	var precipitationUnit: PrecipitationUnitsEnum = .millimeters
	var windSpeedUnit: WindSpeedUnitsEnum = .beaufort
	var windDirectionUnit: WindDirectionUnitsEnum = .cardinal
	var pressureUnit: PressureUnitsEnum = .hectopascal
}

@MainActor
struct SettingsViewModelTests {
	let viewModel: SettingsViewModel
	let settingsUseCase: MockSettingsUseCase
	let authUseCase: MockAuthUseCase
	private let weatherManager: WeatherManager

	init() {
		weatherManager = .init()
		settingsUseCase = .init()
		authUseCase = .init()
		viewModel = .init(userId: "",
						  settingsUseCase: settingsUseCase,
						  authUseCase: authUseCase,
						  unitsManager: weatherManager)
	}

	@Test func logout() async throws {
		try await confirmation { confirm in
			viewModel.logoutUser(showAlert: false) { loggedOut in
				#expect(loggedOut)
				confirm()
			}
			try await Task.sleep(for: .seconds(2))
		}
    }

	@Test func setUnits() {
		#expect(weatherManager.temperatureUnit == .celsius)
		viewModel.setUnits(unitCase: .temperature,
						   chosenOption: TemperatureUnitsEnum.fahrenheit.settingUnitFriendlyName)
		#expect(weatherManager.temperatureUnit == .fahrenheit)
		viewModel.setUnits(unitCase: .temperature,
						   chosenOption: "invalid")
		#expect(weatherManager.temperatureUnit == .fahrenheit)

		#expect(weatherManager.precipitationUnit == .millimeters)
		viewModel.setUnits(unitCase: .precipitation,
						   chosenOption: PrecipitationUnitsEnum.inches.settingUnitFriendlyName)
		#expect(weatherManager.precipitationUnit == .inches)
		viewModel.setUnits(unitCase: .precipitation,
						   chosenOption: "invalid")
		#expect(weatherManager.precipitationUnit == .inches)

		#expect(weatherManager.windSpeedUnit == .beaufort)
		viewModel.setUnits(unitCase: .windSpeed,
						   chosenOption: WindSpeedUnitsEnum.kilometersPerHour.settingUnitFriendlyName)
		#expect(weatherManager.windSpeedUnit == .kilometersPerHour)
		viewModel.setUnits(unitCase: .windSpeed,
						   chosenOption: WindSpeedUnitsEnum.milesPerHour.settingUnitFriendlyName)
		#expect(weatherManager.windSpeedUnit == .milesPerHour)
		viewModel.setUnits(unitCase: .windSpeed,
						   chosenOption: WindSpeedUnitsEnum.metersPerSecond.settingUnitFriendlyName)
		#expect(weatherManager.windSpeedUnit == .metersPerSecond)
		viewModel.setUnits(unitCase: .windSpeed,
						   chosenOption: WindSpeedUnitsEnum.knots.settingUnitFriendlyName)
		#expect(weatherManager.windSpeedUnit == .knots)
		viewModel.setUnits(unitCase: .windSpeed,
						   chosenOption: "invalid")
		#expect(weatherManager.windSpeedUnit == .knots)

		#expect(weatherManager.windDirectionUnit == .cardinal)
		viewModel.setUnits(unitCase: .windDirection,
						   chosenOption: WindDirectionUnitsEnum.degrees.settingUnitFriendlyName)
		#expect(weatherManager.windDirectionUnit == .degrees)
		viewModel.setUnits(unitCase: .windDirection,
						   chosenOption: "invalid")
		#expect(weatherManager.windDirectionUnit == .degrees)

		#expect(weatherManager.pressureUnit == .hectopascal)
		viewModel.setUnits(unitCase: .pressure,
						   chosenOption: PressureUnitsEnum.inchOfMercury.settingUnitFriendlyName)
		#expect(weatherManager.pressureUnit == .inchOfMercury)
		viewModel.setUnits(unitCase: .pressure,
						   chosenOption: "invalid")
		#expect(weatherManager.pressureUnit == .inchOfMercury)
	}
}
