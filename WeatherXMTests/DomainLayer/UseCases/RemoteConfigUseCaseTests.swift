//
//  RemoteConfigUseCaseTests.swift
//  WeatherXMTests
//
//  Created by Pantelis Giazitsis on 6/3/25.
//

import Testing
@testable import DomainLayer
import Toolkit

struct RemoteConfigUseCaseTests {

	let mockRepository = MockRemoteConfigRepositoryImpl()
	let useCase: RemoteConfigUseCase
	private var cancellableWrapper: CancellableWrapper = .init()
	private var mockSurvey: Survey {
		.init(id: "124",
			  title: "Title",
			  message: "Message",
			  actionLabel: nil,
			  url: nil)
	}
	private var mockInfoBanner: InfoBanner {
		.init(id: "124",
			  title: "Title",
			  message: "Message",
			  buttonShow: nil,
			  actionLabel: nil,
			  url: nil,
			  dismissable: nil)

	}

	init() {
		self.useCase = RemoteConfigUseCase(repository: mockRepository)
	}

	@Test func lastSurveyId() async {
		#expect(mockRepository.lastSurveyId == nil)
		useCase.updateLastDismissedSurvey(surveyId: "123")
		#expect(mockRepository.lastSurveyId == "123")
    }

	@Test func lastSurveyPublisher() async throws {
		try await confirmation { confim in
			useCase.surveyPublisher.dropFirst().sink { survey in
				#expect(survey == mockSurvey)
				confim()
			}.store(in: &cancellableWrapper.cancellableSet)
			mockRepository.receiveSurvey(mockSurvey)
			try await Task.sleep(for: .seconds(1))
		}
	}

	@Test func infoBannerId() async {
		#expect(mockRepository.lastDismissedInfoBannerId == nil)
		useCase.updateLastDismissedInfoBannerId("123")
		#expect(mockRepository.lastDismissedInfoBannerId == "123")
	}

	@Test func infoBannerPublisher() async throws {
		try await confirmation { confim in
			useCase.infoBannerPublisher.dropFirst().sink { infoBanner in
				#expect(infoBanner == mockInfoBanner)
				confim()
			}.store(in: &cancellableWrapper.cancellableSet)
			mockRepository.receiveInfoBanner(mockInfoBanner)
			try await Task.sleep(for: .seconds(1))
		}
	}

}
