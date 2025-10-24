//
//  Constants.swift
//  DataLayer
//
//  Created by Hristos Condrea on 17/5/22.
//

import Foundation
import Toolkit

struct NetworkConstants {
	static var baseUrl: String {
		guard let url: String = Bundle.main.getConfiguration(for: .apiUrl) else {
			fatalError("Could not retrieve API url from Configuration file")
		}

		return url
	}

    enum ContentType: String {
        case json = "application/json"
        case octetStream = "application/octet-stream"
    }

    enum HttpHeaderField: String {
        case authentication = "Authentication"
        case authorization = "Authorization"
        case contentType = "Content-Type"
        case acceptType = "Accept"
        case acceptEncoding = "Accept-Encoding"
        case clientIdentifier = "X-WXM-Client"
    }
}
