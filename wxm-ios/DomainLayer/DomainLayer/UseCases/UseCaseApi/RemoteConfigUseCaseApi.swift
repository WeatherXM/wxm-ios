//
//  RemoteConfigUseCaseApi.swift
//  DomainLayer
//
//  Created by Pantelis Giazitsis on 1/4/25.
//

import Foundation
import Combine

public protocol RemoteConfigUseCaseApi: Sendable {
	var surveyPublisher: AnyPublisher<Survey?, Never> { get }
	var infoBannerPublisher: AnyPublisher<InfoBanner?, Never> { get }
	var announcementPublisher: AnyPublisher<Announcement?, Never> { get }

	func updateLastDismissedSurvey(surveyId: String)
	func updateLastDismissedInfoBannerId(_ infoBannerId: String)
	func updateLastDismissedAnnouncementId(_ announcementId: String)
}
