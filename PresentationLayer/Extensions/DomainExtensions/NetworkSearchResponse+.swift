//
//  NetworkSearchResponse+.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 29/6/23.
//

import DomainLayer

protocol NetworkSearchModel {
    var lat: Double? { get }
    var lon: Double? { get }
    var deviceId: String? { get }
    var cellIndex: String? { get }
}

extension NetworkSearchDevice: NetworkSearchModel {

    var lat: Double? {
        cellCenter?.lat
    }

    var lon: Double? {
        cellCenter?.lon
    }

    var deviceId: String? {
        id
    }
}

extension NetworkSearchAddress: NetworkSearchModel {
    var lat: Double? {
        center?.lat
    }

    var lon: Double? {
        center?.lon
    }

    var deviceId: String? {
        nil
    }

    var cellIndex: String? {
        nil
    }
}
