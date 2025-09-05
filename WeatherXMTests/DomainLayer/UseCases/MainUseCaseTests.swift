//
//  MainUseCaseTests.swift
//  WeatherXMTests
//
//  Created by Pantelis Giazitsis on 10/3/25.
//

import Testing
@testable import DomainLayer

struct MainUseCaseTests {
	let useCase: MainUseCase
	let mainRepository: MockMainRepositoryImpl = .init()
	let udRepository: MockUserDefaultsRepositoryImpl = .init()
	let keychainRepository: MockKeychainRepositoryImpl = .init()
	let meRepository: MockMeRepositoryImpl = .init()

	init() {
		self.useCase = MainUseCase(mainRepository: mainRepository,
								   userDefaultsRepository: udRepository,
								   keychainRepository: keychainRepository,
								   meRepository: meRepository)
	}

	@Test func initialized() {
		#expect(mainRepository.initialized)
	}

	@Test func saveOrUpdateWeatherMetric() {
		let temp = TemperatureUnitsEnum.celsius
		useCase.saveOrUpdateWeatherMetric(unitProtocol: temp)

		var repositoryValue: TemperatureUnitsEnum? = udRepository.getValue(for: temp.key)
		#expect(repositoryValue == temp)

		repositoryValue = useCase.readOrCreateWeatherMetric(key: temp.key) as? TemperatureUnitsEnum
		#expect(repositoryValue == temp)
	}

	@Test func readOrCreateWeatherMetric() {
		let key: String = TemperatureUnitsEnum.celsius.key
		#expect(udRepository.readWeatherUnit(key: key)?.key == nil)
		let unit = useCase.readOrCreateWeatherMetric(key: key)
		#expect(key == unit?.key)
		#expect(udRepository.readWeatherUnit(key: key)?.key == unit?.key)
	}

	@Test func saveGetValue() {
		let key = "key"
		let value = "test"
		#expect(udRepository.getValue(for: key) == nil)
		useCase.saveValue(key: key, value: value)
		#expect(useCase.getValue(key: key) == value)
		#expect(udRepository.getValue(for: key) == value)
	}

	@Test func shouldShowUpdatePrompt() {
		var currentVersion = "1.0.0"
		var version = "1.1.0"
		var minimumVersion: String = "1.0.1"
		#expect(useCase.shouldShowUpdatePrompt(for: version,
											   minimumVersion: minimumVersion,
											   currentVersion: currentVersion))


		// Update due to min version
		currentVersion = "1.1.0"
		minimumVersion = "1.2.0"
		#expect(useCase.shouldShowUpdatePrompt(for: version,
											   minimumVersion: minimumVersion,
											   currentVersion: currentVersion))

		// No update
		currentVersion = "1.1.0"
		version = "1.1.0"
		minimumVersion = "1.0.0"
		#expect(!useCase.shouldShowUpdatePrompt(for: version,
												minimumVersion: minimumVersion,
												currentVersion: currentVersion))

		// No update, with invalid `version`
		currentVersion = "1.1.0"
		version = "1.0.1"
		minimumVersion = "1.0.0"
		#expect(!useCase.shouldShowUpdatePrompt(for: version,
												minimumVersion: minimumVersion,
												currentVersion: currentVersion))

		// After seen
		currentVersion = "1.1.0"
		version = "1.1.1"
		#expect(useCase.shouldShowUpdatePrompt(for: version,
											   minimumVersion: minimumVersion,
											   currentVersion: currentVersion))

		useCase.updateLastAppVersionPrompt(with: version)
		#expect(!useCase.shouldShowUpdatePrompt(for: version,
												minimumVersion: minimumVersion,
												currentVersion: currentVersion))
	}

	@Test func shouldForceUpdate() {
		var currentVersion = "1.1.0"
		var minimumVersion: String = "1.0.1"
		#expect(!useCase.shouldForceUpdate(minimumVersion: minimumVersion,
										   currentVersion: currentVersion))

		// No update, equals
		minimumVersion = "1.1.0"
		#expect(!useCase.shouldForceUpdate(minimumVersion: minimumVersion,
										   currentVersion: currentVersion))

		// Update
		minimumVersion = "1.1.1"
		#expect(useCase.shouldForceUpdate(minimumVersion: minimumVersion,
										  currentVersion: currentVersion))
	}

	@Test func termsAccepted() {
		#expect(!useCase.areTermsOfUseAccepted())
		useCase.setTermsOfUseAccepted()
		#expect(useCase.areTermsOfUseAccepted())
	}

	@Test func showOnboarding() {
		#expect(useCase.shouldShowOnboarding())
		useCase.markOnboardingAsShown()
		#expect(!useCase.shouldShowOnboarding())
	}
}
