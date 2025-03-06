//
//  MockRemoteConfigRepositoryImpl.swift
//  WeatherXMTests
//
//  Created by Pantelis Giazitsis on 6/3/25.
//

import Foundation
@testable import DomainLayer
import Combine

class MockRemoteConfigRepositoryImpl: RemoteConfigRepository {

	var surveyPublisher: AnyPublisher<Survey?, Never>
	var infoBannerPublisher: AnyPublisher<InfoBanner?, Never>

	private(set) var lastSurveyId: String?
	private(set) var lastDismissedInfoBannerId: String?
	private let surveyValueSubject: CurrentValueSubject<Survey?, Never> = .init(nil)
	private let infoBannerCurrentValueSubject: CurrentValueSubject<InfoBanner?, Never> = .init(nil)

	init() {
		surveyPublisher = surveyValueSubject.eraseToAnyPublisher()
		infoBannerPublisher = infoBannerCurrentValueSubject.eraseToAnyPublisher()
	}

	func updateLastSurveyId(_ surveyId: String) {
		self.lastSurveyId = surveyId
	}
	
	func updateLastDismissedInfoBannerId(_ infoBannerId: String) {
		self.lastDismissedInfoBannerId = infoBannerId
	}
}

// Test functionality
extension MockRemoteConfigRepositoryImpl {
	func receiveSurvey(_ survey: Survey) {
		surveyValueSubject.send(survey)
	}

	func receiveInfoBanner(_ infoBanner: InfoBanner) {
		infoBannerCurrentValueSubject.send(infoBanner)
	}
}
