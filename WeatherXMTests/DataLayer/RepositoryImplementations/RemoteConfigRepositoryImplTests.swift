//
//  RemoteConfigRepositoryImplTests.swift
//  WeatherXMTests
//
//  Created by Pantelis Giazitsis on 7/2/25.
//

import Testing
@testable import DataLayer
import Toolkit

@Suite(.serialized)
struct RemoteConfigRepositoryImplTests {
	private let repositoryImpl: RemoteConfigRepositoryImpl = .init()
	private let cancellableWrapper: CancellableWrapper = .init()

	init() {
		UserDefaultsService().clearUserSensitiveData()
	}

    @Test func survey() async throws {
		var count = 3
		try await confirmation(expectedCount: count) { confirm in
			repositoryImpl.surveyPublisher.sink { survey in
				print(count)
				if count == 2 {
					#expect(survey?.id == "Dummy Text")
				} else {
					#expect(survey == nil)
				}
				count -= 1

				confirm()
			}.store(in: &cancellableWrapper.cancellableSet)
			try await Task.sleep(for: .seconds(2))
			repositoryImpl.updateLastSurveyId("Dummy Text")
			try await Task.sleep(for: .seconds(1))
		}
    }

	@Test func infoBanner() async throws {
		var count = 3
		try await confirmation(expectedCount: count) { confirm in
			repositoryImpl.infoBannerPublisher.sink { infoBanner in
				print(count)
				if count == 2 {
					#expect(infoBanner?.id == "Dummy Text")
				} else {
					#expect(infoBanner == nil)
				}
				count -= 1

				confirm()
			}.store(in: &cancellableWrapper.cancellableSet)
			try await Task.sleep(for: .seconds(2))
			repositoryImpl.updateLastDismissedInfoBannerId("Dummy Text")
			try await Task.sleep(for: .seconds(1))
		}
	}

	@Test func announcement() async throws {
		var count = 3
		try await confirmation(expectedCount: count) { confirm in
			repositoryImpl.announcementPublisher.sink { announcement in
				print(count)
				if count == 2 {
					#expect(announcement?.id == "Dummy Text")
				} else {
					#expect(announcement == nil)
				}
				count -= 1

				confirm()
			}.store(in: &cancellableWrapper.cancellableSet)
			try await Task.sleep(for: .seconds(2))
			repositoryImpl.updateLastDismissedAnnouncementId("Dummy Text")
			try await Task.sleep(for: .seconds(1))
		}
	}

}
