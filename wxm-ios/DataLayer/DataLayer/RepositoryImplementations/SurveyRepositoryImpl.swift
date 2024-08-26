//
//  SurveyRepositoryImpl.swift
//  DataLayer
//
//  Created by Pantelis Giazitsis on 26/8/24.
//

import Foundation
import DomainLayer
import Combine
import Toolkit

public class SurveyRepositoryImpl: SurveyRepository {
	public var surveyPublisher: AnyPublisher<Survey?, Never>
	
	private let currentValueSubject: CurrentValueSubject<Survey?, Never> = .init(nil)
	private var cancellableSet: Set<AnyCancellable> = .init()
	private let userDefaultsService = UserDefaultsService()
	private let lastSurveyKey = UserDefaults.GenericKey.lastSurveyId.rawValue


	public init() {
		surveyPublisher = currentValueSubject.eraseToAnyPublisher()

		RemoteConfigManager.shared.$surveyShow.sink { [weak self] show in
			self?.handleSurveyShow(show)
		}.store(in: &cancellableSet)
	}

	public func updateLastSurveyId(_ surveyId: String) {
		userDefaultsService.save(value: surveyId, key: lastSurveyKey)
		let show = RemoteConfigManager.shared.surveyShow
		handleSurveyShow(show)
	}
}

private extension SurveyRepositoryImpl {
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
}
