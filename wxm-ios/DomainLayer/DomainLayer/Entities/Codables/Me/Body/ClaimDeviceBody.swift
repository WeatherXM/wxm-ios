//
//  ClaimDeviceBody.swift
//  DomainLayer
//
//  Created by Hristos Condrea on 17/5/22.
//

import CoreLocation
import Foundation

public struct ClaimDeviceBody {
    public var serialNumber: String
    public var location: CLLocationCoordinate2D
    public var secret: String?

    public init(serialNumber: String, location: CLLocationCoordinate2D, secret: String? = nil) {
        self.serialNumber = serialNumber
        self.location = location
        self.secret = secret
    }

    public var dictionaryRepresentation: [String: Any] {
        var dict: [String: Any] = [
            "serialNumber": serialNumber as String,
            "location": [
                "lat": location.latitude as Double?,
                "lon": location.longitude as Double?,
            ],
        ]

        if secret != nil {
            dict["secret"] = secret
        }

        return dict
    }
}
