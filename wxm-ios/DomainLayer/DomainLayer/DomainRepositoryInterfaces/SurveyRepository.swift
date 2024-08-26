//
//  SurveyRepository.swift
//  DomainLayer
//
//  Created by Pantelis Giazitsis on 26/8/24.
//

import Foundation
import Combine

public protocol SurveyRepository {
	var surveyPublisher: AnyPublisher<Survey?, Never> { get set}
}
