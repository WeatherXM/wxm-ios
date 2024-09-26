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

	private let currentValueSubject: CurrentValueSubject<Survey?, Never> = .init(nil)
	private let infoBannerCurrentValueSubject: CurrentValueSubject<InfoBanner?, Never> = .init(nil)
	private var cancellableSet: Set<AnyCancellable> = .init()
	private let userDefaultsService = UserDefaultsService()
	private let lastSurveyKey = UserDefaults.GenericKey.lastSurveyId.rawValue
	private let lastInfoBannerIdKey = UserDefaults.GenericKey.lastInfoBannerId.rawValue

	public init() {
		surveyPublisher = currentValueSubject.eraseToAnyPublisher()
		infoBannerPublisher = infoBannerCurrentValueSubject.eraseToAnyPublisher()

		RemoteConfigManager.shared.$surveyShow.sink { [weak self] show in
			self?.handleSurveyShow(show)
		}.store(in: &cancellableSet)

		observeInfoBanner()
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
									buttonShow: RemoteConfigManager.shared.infoButtonShow,
									actionLabel: RemoteConfigManager.shared.infoBannerActionLabel,
									url: RemoteConfigManager.shared.infoBannerUrl,
									dismissable: RemoteConfigManager.shared.infoBannerDismissable)

		infoBannerCurrentValueSubject.send(infoBanner)
	}

	func canShowInfobanner(bannerId: String) -> Bool {
		let lastInfoBannerId: String? = userDefaultsService.get(key: lastInfoBannerIdKey)

		return lastInfoBannerId != bannerId
	}

}
