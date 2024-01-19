//
//  Geocoder.swift
//  DomainLayer
//
//  Created by Pantelis Giazitsis on 2/8/23.
//

import Foundation
import CoreLocation
import Toolkit

struct Geocoder {
    func resolveAddressLocation(_ location: CLLocationCoordinate2D, completion: @escaping GenericCallback<String>) {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(CLLocation(latitude: location.latitude, longitude: location.longitude)) { placemarks, error in
            guard let placemark = placemarks?.first else {
                completion("")
                return

            }

            let address = self.resolveAddressFromPlacemark(placemark: placemark)
            completion(address)
        }
    }

    func resolveAddressLocation(_ location: CLLocationCoordinate2D) async throws -> String {
        let geocoder = CLGeocoder()
        guard let placemark = try await geocoder.reverseGeocodeLocation(CLLocation(latitude: location.latitude, longitude: location.longitude)).first else {
            return ""
        }

        return resolveAddressFromPlacemark(placemark: placemark)
    }
    
    private func resolveAddressFromPlacemark(placemark: CLPlacemark) -> String {
        var address = ""
        if let locality = placemark.locality, let countryCode = placemark.isoCountryCode {
            address = "\(locality), \(countryCode)"
        } else if let subAdminArea = placemark.subAdministrativeArea, let countryCode = placemark.isoCountryCode {
            address = "\(subAdminArea), \(countryCode)"
        } else if let adminArea = placemark.administrativeArea, let countryCode = placemark.isoCountryCode {
            address = "\(adminArea), \(countryCode)"
        } else if let country = placemark.country {
            address = country
        }
        return address
    }
}
