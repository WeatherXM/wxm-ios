//
//  RemoteConfigUseCase.swift
//  DomainLayer
//
//  Created by Pantelis Giazitsis on 26/8/24.
//

import Foundation
import Combine

public struct RemoteConfigUseCase: RemoteConfigUseCaseApi {
	nonisolated(unsafe) public var surveyPublisher: AnyPublisher<Survey?, Never>
	nonisolated(unsafe) public var infoBannerPublisher: AnyPublisher<InfoBanner?, Never>
	nonisolated(unsafe) public var announcementPublisher: AnyPublisher<Announcement?, Never>
	nonisolated(unsafe) private let repository: RemoteConfigRepository

	public init(repository: RemoteConfigRepository) {
		self.repository = repository
		self.surveyPublisher = repository.surveyPublisher
		self.infoBannerPublisher = repository.infoBannerPublisher
		self.announcementPublisher = repository.announcementPublisher
	}

	public func updateLastDismissedSurvey(surveyId: String) {
		repository.updateLastSurveyId(surveyId)
	}

	public func updateLastDismissedInfoBannerId(_ infoBannerId: String) {
		repository.updateLastDismissedInfoBannerId(infoBannerId)
	}

	public func updateLastDismissedAnnouncementId(_ announcementId: String) {
		repository.updateLastDismissedAnnouncementId(announcementId)
	}
}
