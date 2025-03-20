//
//  RemoteConfigRepositoryImpl.swift
//  DataLayer
//
//  Created by Pantelis Giazitsis on 26/8/24.
//

import Foundation
import DomainLayer
import Combine
import Toolkit

public class RemoteConfigRepositoryImpl: RemoteConfigRepository {
	public var surveyPublisher: AnyPublisher<Survey?, Never>
	public var infoBannerPublisher: AnyPublisher<InfoBanner?, Never>
	public var announcementPublisher: AnyPublisher<Announcement?, Never>

	private let currentValueSubject: CurrentValueSubject<Survey?, Never> = .init(nil)
	private let infoBannerCurrentValueSubject: CurrentValueSubject<InfoBanner?, Never> = .init(nil)
	private let announcementCurrentValueSubject: CurrentValueSubject<Announcement?, Never> = .init(nil)
	private var cancellableSet: Set<AnyCancellable> = .init()
	private let userDefaultsService = UserDefaultsService()
	private let lastSurveyKey = UserDefaults.GenericKey.lastSurveyId.rawValue
	private let lastInfoBannerIdKey = UserDefaults.GenericKey.lastInfoBannerId.rawValue

	public init() {
		surveyPublisher = currentValueSubject.eraseToAnyPublisher()
		infoBannerPublisher = infoBannerCurrentValueSubject.eraseToAnyPublisher()
		announcementPublisher = announcementCurrentValueSubject.eraseToAnyPublisher()

		RemoteConfigManager.shared.$surveyShow.sink { [weak self] show in
			self?.handleSurveyShow(show)
		}.store(in: &cancellableSet)

		observeInfoBanner()
		observeAnnouncement()
	}

	public func updateLastSurveyId(_ surveyId: String) {
		userDefaultsService.save(value: surveyId, key: lastSurveyKey)
		let show = RemoteConfigManager.shared.surveyShow
		handleSurveyShow(show)
	}

	public func updateLastDismissedInfoBannerId(_ infoBannerId: String) {
		userDefaultsService.save(value: infoBannerId, key: lastInfoBannerIdKey)
		let show = RemoteConfigManager.shared.infoBannerShow
		handleInfoBannerUpdate(show: show ?? false)
	}
}

private extension RemoteConfigRepositoryImpl {
	func canShowSurvey(surveyId: String) -> Bool {
		let lastSurveyId: String? = userDefaultsService.get(key: lastSurveyKey)

		return lastSurveyId != surveyId
	}

	func handleSurveyShow(_ show: Bool?) {
		guard show == true,
			  let surveyId = RemoteConfigManager.shared.surveyId,
			  canShowSurvey(surveyId: surveyId) else {
			currentValueSubject.send(nil)
			return
		}

		let survey = Survey(id: RemoteConfigManager.shared.surveyId,
							title: RemoteConfigManager.shared.surveyTitle,
							message: RemoteConfigManager.shared.surveyMessage,
							actionLabel: RemoteConfigManager.shared.surveyActionLabel,
							url: RemoteConfigManager.shared.surveyUrl)

		currentValueSubject.send(survey)
	}

	func observeInfoBanner() {
		let infobannerId = RemoteConfigManager.shared.$infoBannerId
		let infoBannerShow = RemoteConfigManager.shared.$infoBannerShow
		let infoBannerDismissable = RemoteConfigManager.shared.$infoBannerDismissable

		let zip = Publishers.Zip3(infobannerId, infoBannerShow, infoBannerDismissable)
		zip.debounce(for: 1.0, scheduler: DispatchQueue.main).sink { [weak self] _, show, _ in
			self?.handleInfoBannerUpdate(show: show ?? false)
		}.store(in: &cancellableSet)
	}

	func observeAnnouncement() {
		let announcementId = RemoteConfigManager.shared.$announcementId
		let announcementShow = RemoteConfigManager.shared.$announcementShow
		let announcementDismissable = RemoteConfigManager.shared.$announcementDismissable

		let zip = Publishers.Zip3(announcementId, announcementShow, announcementDismissable)
		zip.debounce(for: 1.0, scheduler: DispatchQueue.main).sink { [weak self] _, show, _ in
			self?.handleSurveyShow(show)
		}.store(in: &cancellableSet)
	}

	func handleInfoBannerUpdate(show: Bool) {
		guard let infoBannerId = RemoteConfigManager.shared.infoBannerId,
			  canShowInfobanner(bannerId: infoBannerId),
			  show  else {
			infoBannerCurrentValueSubject.send(nil)
			return
		}

		let infoBanner = InfoBanner(id: infoBannerId,
									title: RemoteConfigManager.shared.infoBannerTitle,
									message: RemoteConfigManager.shared.infoBannerMessage,
									buttonShow: RemoteConfigManager.shared.infoBannerActionShow,
									actionLabel: RemoteConfigManager.shared.infoBannerActionLabel,
									url: RemoteConfigManager.shared.infoBannerActionUrl,
									dismissable: RemoteConfigManager.shared.infoBannerDismissable)

		infoBannerCurrentValueSubject.send(infoBanner)
	}

	func canShowInfobanner(bannerId: String) -> Bool {
		let lastInfoBannerId: String? = userDefaultsService.get(key: lastInfoBannerIdKey)

		return lastInfoBannerId != bannerId
	}

	func handleAnnouncementUpdate(show: Bool) {
		let announcement = Announcement(id: RemoteConfigManager.shared.announcementId,
										title: RemoteConfigManager.shared.announcementTitle,
										message: RemoteConfigManager.shared.announcementMessage,
										actionLabel: RemoteConfigManager.shared.announcementActionLabel,
										actionUrl: RemoteConfigManager.shared.announcementActionUrl,
										actionShow: RemoteConfigManager.shared.announcementActionShow,
										show: RemoteConfigManager.shared.announcementShow, // Remove??
										dismissable: RemoteConfigManager.shared.announcementDismissable)

		announcementCurrentValueSubject.send(announcement)
	}
}
