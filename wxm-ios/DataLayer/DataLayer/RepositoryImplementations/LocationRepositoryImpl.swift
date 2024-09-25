//
//  DeviceLocationRepositoryImpl.swift
//  DataLayer
//
//  Created by Manolis Katsifarakis on 16/10/22.
//

import Combine
import DomainLayer
import MapboxSearch
import Toolkit

public class DeviceLocationRepositoryImpl: DeviceLocationRepository {
	private static let JSON_COUNTRIES_INFO_FILE_KEY = "countries_information"
	private static let SEARCH_DEBOUNCE: TimeInterval = 500
	private static let SEARCH_LANGUAGES = ["en"]
	private static let SEARCH_LIMIT = 10
	private static let GEOCODING_LIMIT = 1
	private static let SEARCH_TYPES: [SearchQueryType] = [
		.address,
		.neighborhood,
		.district,
		.locality,
		.place,
		.postcode
	]
	private let resultsSubject = CurrentValueSubject<
		[DeviceLocationSearchResult],
		Never
	>([])

	private let locationFromSearchResultSubject = PassthroughSubject<
		DeviceLocation,
		Never
	>()

	private let reverseGeocodedAddressSubject = PassthroughSubject<
		DeviceLocation?,
		Never
	>()

	private let errorSubject = PassthroughSubject<
		DeviceLocationError,
		Never
	>()

	private lazy var mapBoxSearchEngine = {
		let searchEngine = SearchEngine()
		searchEngine.delegate = self

		return searchEngine
	}()

	private let searchOptions: SearchOptions

	private var mapBoxSearchSuggestionCache: [SearchSuggestion] = []

	private let locationManager = WXMLocationManager()

	public let searchResults: AnyPublisher<[DeviceLocationSearchResult], Never>
	public let error: AnyPublisher<DeviceLocationError, Never>

	public init() {
		searchResults = resultsSubject.eraseToAnyPublisher()
		error = errorSubject.eraseToAnyPublisher()
		var searchOptions = SearchOptions(
			languages: Self.SEARCH_LANGUAGES,
			limit: Self.SEARCH_LIMIT,
			filterTypes: Self.SEARCH_TYPES
		)

		searchOptions.defaultDebounce = Self.SEARCH_DEBOUNCE
		self.searchOptions = searchOptions
	}

	public func getCountryInfos() -> [CountryInfo]? {
		guard let path = Bundle(for: type(of: self)).path(forResource: Self.JSON_COUNTRIES_INFO_FILE_KEY, ofType: "json"),
			  let data = try? Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe) else {
			return nil
		}

		return try? JSONDecoder().decode([CountryInfo].self, from: data)
	}

	public func areLocationCoordinatesValid(_ coordinates: LocationCoordinates) -> Bool {
		CLLocationCoordinate2DIsValid(coordinates.toCLLocationCoordinate2D())
	}

	public func searchFor(_ query: String) {
		mapBoxSearchEngine.search(query: query, options: searchOptions)
	}

	public func locationFromSearchResult(_ suggestion: DeviceLocationSearchResult) -> AnyPublisher<DeviceLocation, Never> {
		if let searchSuggestion = mapBoxSearchSuggestionCache.first(where: { $0.id == suggestion.id }) {
			mapBoxSearchEngine.select(suggestion: searchSuggestion)
		}

		return locationFromSearchResultSubject
			.eraseToAnyPublisher()
	}

	public func locationFromCoordinates(_ coordinates: LocationCoordinates) -> AnyPublisher<DeviceLocation?, Never> {
		let options = ReverseGeocodingOptions(
			point: coordinates.toCLLocationCoordinate2D(),
			limit: Self.GEOCODING_LIMIT,
			types: Self.SEARCH_TYPES
		)

		mapBoxSearchEngine.reverseGeocoding(options: options) { result in
			switch result {
				case let .success(addresses):
					guard let actualAddress = addresses.first else {
						self.reverseGeocodedAddressSubject.send(nil)
						return
					}

					self.reverseGeocodedAddressSubject.send(actualAddress.toLocation(with: coordinates.toCLLocationCoordinate2D()))
				case let .failure(error):
					if let locationError = error.toDeviceLocationError() {
						self.errorSubject.send(locationError)
					}
			}
		}

		return reverseGeocodedAddressSubject
			.eraseToAnyPublisher()
	}

	public func getUserLocation() async -> Result<CLLocationCoordinate2D, ExplorerLocationError> {
		let res = await locationManager.getUserLocation()
		switch res {
			case .success(let coordinates):
				return .success(coordinates)
			case .failure(let error):
				return .failure(ExplorerLocationError(locationError: error))
		}
	}
}

extension DeviceLocationRepositoryImpl: SearchEngineDelegate {
	public func suggestionsUpdated(suggestions: [MapboxSearch.SearchSuggestion], searchEngine _: MapboxSearch.SearchEngine) {
		mapBoxSearchSuggestionCache = suggestions
		resultsSubject.send(suggestions.toLocationSearchResults())
	}

	public func resultResolved(result: MapboxSearch.SearchResult, searchEngine _: MapboxSearch.SearchEngine) {
		locationFromSearchResultSubject.send(result.toLocation())
	}

	public func searchErrorHappened(searchError: MapboxSearch.SearchError, searchEngine _: MapboxSearch.SearchEngine) {
		guard let error = searchError.toDeviceLocationError() else { return }
		errorSubject.send(error)
	}
}

extension [SearchSuggestion] {
	func toLocationSearchResults() -> [DeviceLocationSearchResult] {
		map { $0.toLocationSearchResult() }
	}
}

extension SearchSuggestion {
	func toLocationSearchResult() -> DeviceLocationSearchResult {
		var parsedAddress = name
		if let street = address?.street {
			parsedAddress += ", \(street)"
		}

		if let place = address?.place {
			parsedAddress += ", \(place)"
		}

		if let region = address?.region {
			parsedAddress += ", \(region)"
		}

		if let country = address?.country {
			parsedAddress += ", \(country)"
		}

		if let postcode = address?.postcode {
			parsedAddress += ", \(postcode)"
		}

		return DeviceLocationSearchResult(
			id: id,
			description: parsedAddress
		)
	}
}

extension SearchResult {
	func toLocation(with locationCoordinate: CLLocationCoordinate2D? = nil) -> DeviceLocation {
		let parsedAddress = isAccurate ? address?.formattedAddress(style: .medium) : nil

		return DeviceLocation(
			id: id,
			name: parsedAddress,
			country: address?.country,
			countryCode: metadata?["iso_3166_1"],
			coordinates: LocationCoordinates.fromCLLocationCoordinate2D(locationCoordinate ?? coordinate)
		)
	}

	var isAccurate: Bool {
		switch accuracy {
			case .point, .rooftop, .street:
				true
			default:
				false
		}
	}
}

public extension LocationCoordinates {
	static func fromCLLocationCoordinate2D(_ coordinate: CLLocationCoordinate2D) -> LocationCoordinates {
		LocationCoordinates(lat: coordinate.latitude, long: coordinate.longitude)
	}

	func toCLLocationCoordinate2D() -> CLLocationCoordinate2D {
		CLLocationCoordinate2D(latitude: lat, longitude: lon)
	}
}

extension SearchError {
	func toDeviceLocationError() -> DeviceLocationError? {
		switch self {
			case .searchRequestCancelled:
				return nil
			case let .generic(code: code, domain: domain, message: message):
				return DeviceLocationError.generic(code: code, domain: domain, message: message)
			case .searchRequestFailed(reason: _):
				return .searchError
			case .reverseGeocodingFailed(reason: _, options: _):
				return .reverseGeocodingError
			case .incorrectEventTemplate, .incorrectSearchResultForFeedback, .categorySearchRequestFailed(reason: _),
					.failedToRegisterDataProvider(reason: _, dataProvider: _), .internalSearchRequestError(message: _), .dataResolverNotFound:
				return .implementationError
			case .responseProcessingFailed, .resultResolutionFailed:
				return .dependencyError
		}
	}
}
