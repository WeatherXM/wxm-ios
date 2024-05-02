//
//  ParameterConstants.swift
//  DataLayer
//
//  Created by Hristos Condrea on 17/5/22.
//

import Foundation

struct ParameterConstants {
    enum Auth {
        static let username = "username"
        static let password = "password"
        static let email = "email"
        static let firstName = "firstName"
        static let lastName = "lastName"
        static let refreshToken = "refreshToken"
        static let accessToken = "accessToken"
    }

    enum Me {
        static let address = "address"
        static let serialNumber = "serialNumber"
        static let location = "location"
        static let testSearch = "testSearch"
        static let deviceId = "deviceId"
        static let fromDate = "fromDate"
        static let toDate = "toDate"
        static let exclude = "exclude"
        static let friendlyName = "friendlyName"
		static let lat = "lat"
		static let lon = "lon"
    }

	enum Devices {
		static let date = "date"
		static let timezone = "timezone"
		static let page = "page"
		static let pageSize = "pageSize"
		static let fromDate = "fromDate"
		static let toDate = "toDate"
	}
}
