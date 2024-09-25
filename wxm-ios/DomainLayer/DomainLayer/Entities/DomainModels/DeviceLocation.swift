//
//  DeviceLocation.swift
//  DomainLayer
//
//  Created by Manolis Katsifarakis on 17/10/22.
//

public enum DeviceLocationError: Error {
    /// Error while searching via `suggestionsForQuery`.
    case searchError
    /// Error while reverse geocoding via `locationFromCoordinates`.
    case reverseGeocodingError
    /// Generic error, that maps to NSError.
    case generic(code: Int, domain: String, message: String)
    /// Probably an issue with the dependency that the repository implementation uses (currently MapBox).
    case dependencyError
    /// An error reported by the dependency but not handled by our own repository implementation (e.g. we haven't thought of something...).
    case implementationError
}

public struct DeviceLocationSearchResult: Identifiable, Equatable, Hashable {
    public let id: String
    public let description: String

    public init(id: String, description: String) {
        self.id = id
        self.description = description
    }
}

public struct DeviceLocation: Identifiable, Equatable {
    public let id: String
    public let name: String?
    public let country: String?
    public let countryCode: String?
    public let coordinates: LocationCoordinates

    public init(id: String, name: String?, country: String?, countryCode: String?, coordinates: LocationCoordinates) {
        self.id = id
        self.name = name
        self.country = country
        self.countryCode = countryCode
        self.coordinates = coordinates
    }
}
