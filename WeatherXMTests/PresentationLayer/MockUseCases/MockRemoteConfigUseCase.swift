//
//  MockRemoteConfigUseCase.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 3/4/25.
//

import DomainLayer
@testable import WeatherXM
import Combine

final class MockRemoteConfigUseCase: RemoteConfigUseCaseApi {
	nonisolated(unsafe) var lastDismissedSurveyId: String?
	nonisolated(unsafe) var lastDismissedInfoBannerId: String?
	nonisolated(unsafe) var lastDismissedAnnouncementId: String?

	var surveyPublisher: AnyPublisher<Survey?, Never> {
		Just(nil).eraseToAnyPublisher()
	}

	var infoBannerPublisher: AnyPublisher<InfoBanner?, Never> {
		Just(InfoBanner(id: "124",
						title: nil,
						message: nil,
						buttonShow: nil,
						actionLabel: nil,
						url: nil,
						dismissable: nil)).eraseToAnyPublisher()
	}

	var announcementPublisher: AnyPublisher<Announcement?, Never> {
		Just(nil).eraseToAnyPublisher()
	}

	func updateLastDismissedSurvey(surveyId: String) {
		lastDismissedSurveyId = surveyId
	}
	
	func updateLastDismissedInfoBannerId(_ infoBannerId: String) {
		lastDismissedInfoBannerId = infoBannerId
	}
	
	func updateLastDismissedAnnouncementId(_ announcementId: String) {
		lastDismissedAnnouncementId = announcementId
	}
}
