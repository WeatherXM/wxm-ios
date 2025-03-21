//
//  RemoteConfigUseCase.swift
//  DomainLayer
//
//  Created by Pantelis Giazitsis on 26/8/24.
//

import Foundation
import Combine

public struct RemoteConfigUseCase {
	public var surveyPublisher: AnyPublisher<Survey?, Never>
	public var infoBannerPublisher: AnyPublisher<InfoBanner?, Never>
	public var announcementPublisher: AnyPublisher<Announcement?, Never>
	private let repository: RemoteConfigRepository

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
