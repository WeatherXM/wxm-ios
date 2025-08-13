//
//  LocationForecastsUseCaseTests.swift
//  WeatherXMTests
//
//  Created by Pantelis Giazitsis on 12/8/25.
//

import Testing
@testable import DomainLayer
import CoreLocation
import Toolkit

struct LocationForecastsUseCaseTests {
	let useCase: LocationForecastsUseCase
	private let explorerRepository: ExplorerRepository = MockExplorerRepositoryImpl()
	private let userDefaultsRepository: UserDefaultsRepository = MockUserDefaultsRepositoryImpl()
	private let keycacheRepository: KeychainRepository = MockKeychainRepositoryImpl()
	private let cacheManager: MockCacheManager = .init()
	let cancellableWrapper: CancellableWrapper = .init()


	init() {
		useCase = .init(explorerRepository: explorerRepository,
						userDefaultsRepository: userDefaultsRepository,
						keychainRepository: keycacheRepository,
						cacheManager: cacheManager)
	}

    @Test
	func getUserLocation() async throws {
		let userLocation = try await useCase.getUserLocation().get()
		#expect(userLocation.latitude == 0.0)
		#expect(userLocation.longitude == 0.0)
    }

	@Test
	func getForecast() async throws {
		let forecast = try await useCase.getForecast(for: .init()).toAsync().result.get()
		#expect(forecast.isEmpty)
	}

	@Test
	func getCachedForecast() async throws {
		let cachedforecast = NetworkDeviceForecastResponse(tz: "123",
														   date: "",
														   hourly: [],
														   address: "Address")
		let location = CLLocationCoordinate2D()
		useCase.cache.insertValue([cachedforecast],
								  expire: 60,
								  for: location.cacheKey)

		let forecast = try await useCase.getForecast(for: .init()).toAsync().result.get()
		#expect(forecast.count == 1)
		#expect(forecast.first?.tz == "123")
		#expect(forecast.first?.address == "Address")
	}

	@Test
	func savedLocations() async throws {
		var savedLocations = useCase.getSavedLocations()
		#expect(savedLocations.isEmpty)

		useCase.saveLocation(.init())
		savedLocations = useCase.getSavedLocations()
		#expect(savedLocations.count == 1)

		useCase.removeLocation(.init())
		savedLocations = useCase.getSavedLocations()
		#expect(savedLocations.isEmpty)
	}

	@Test
	func savedNotifications() async throws {
		let savedLocations = useCase.getSavedLocations()
		#expect(savedLocations.isEmpty)

		await confirmation { confirm in
			useCase.savedLocationsPublisher.prefix(1).sink { _ in
				let savedLocations = useCase.getSavedLocations()
				#expect(!savedLocations.isEmpty)

				confirm()
			}.store(in: &cancellableWrapper.cancellableSet)
			useCase.saveLocation(.init())
		}
	}
}
