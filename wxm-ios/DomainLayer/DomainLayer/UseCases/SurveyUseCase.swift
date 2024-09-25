//
//  SurveyUseCase.swift
//  DomainLayer
//
//  Created by Pantelis Giazitsis on 26/8/24.
//

import Foundation
import Combine

public struct SurveyUseCase {
	public var surveyPublisher: AnyPublisher<Survey?, Never>
	private let repository: RemoteConfigRepository

	public init(repository: RemoteConfigRepository) {
		self.repository = repository
		self.surveyPublisher = repository.surveyPublisher
	}

	public func updateLastDismissedSurvey(surveyId: String) {
		repository.updateLastSurveyId(surveyId)
	}
}
