//
//  MockLinkNavigation.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 31/3/25.
//

@testable import WeatherXM

class MockLinkNavigation: LinkNavigation {
	private(set) var openedUrl: String?
	private(set) var openedContactSupport: Bool = false

	func openUrl(_ urlString: String) {
		openedUrl = urlString
	}
	
	func openContactSupport(successFailureEnum: SuccessFailEnum,
							email: String?,
							serialNumber: String?,
							errorString: String?,
							addtionalInfo: String?,
							trackSelectContentEvent: Bool) {
		openedContactSupport = true
	}
}
