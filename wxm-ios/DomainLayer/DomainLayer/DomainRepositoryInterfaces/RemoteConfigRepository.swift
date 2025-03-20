//
//  RemoteConfigRepository.swift
//  DomainLayer
//
//  Created by Pantelis Giazitsis on 26/8/24.
//

import Foundation
import Combine

public protocol RemoteConfigRepository {
	var surveyPublisher: AnyPublisher<Survey?, Never> { get set }
	var infoBannerPublisher: AnyPublisher<InfoBanner?, Never> { get set }
	var announcementPublisher: AnyPublisher<Announcement?, Never> { get set }


	func updateLastSurveyId(_ surveyId: String)
	func updateLastDismissedInfoBannerId(_ infoBannerId: String)
}
