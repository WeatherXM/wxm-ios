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

	init() {
		surveyPublisher = currentValueSubject.eraseToAnyPublisher()

		RemoteConfigManager.shared.$surveyShow.sink { [weak self] show in
			self?.handleSurveyShow(show)
		}.store(in: &cancellableSet)
	}
}

private extension SurveyRepositoryImpl {
	func handleSurveyShow(_ show: Bool?) {
		guard let show else {
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
