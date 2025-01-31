//
//  UserInfoServiceTests.swift
//  WeatherXMTests
//
//  Created by Pantelis Giazitsis on 30/1/25.
//

import Testing
@testable import DataLayer
import DomainLayer
import Toolkit

struct UserInfoServiceTests {
	let service = UserInfoService()
	private let cancellableWrapper: CancellableWrapper = .init()

	@Test func user() async throws {
		let user = try await service.getUser().toAsync().result.get()
		#expect(user.email == "user@example.com")
		#expect(user.name == "TestUser")
    }

	@Test func initialUserFromPubliher() async {
		await confirmation { confirm in
			service.getLatestUserInfoPublisher().sink { user in
				#expect(user == nil)
				confirm()
			}.store(in: &cancellableWrapper.cancellableSet)
		}
	}

	@Test func userFromPubliher() async {
		await confirmation { confirm in
			service.getLatestUserInfoPublisher()
				.dropFirst()
				.sink { user in
				#expect(user?.email == "user@example.com")
				#expect(user?.name == "TestUser")
				confirm()
			}.store(in: &cancellableWrapper.cancellableSet)

			let _ = try? await service.getUser().toAsync()
		}
	}

	@Test func userFromPubliherAfterWalletChange() async {
		await confirmation { confirm in
			service.getLatestUserInfoPublisher()
				.dropFirst()
				.sink { user in
				#expect(user?.email == "user@example.com")
				#expect(user?.name == "TestUser")
				confirm()
			}.store(in: &cancellableWrapper.cancellableSet)

			let _ = try? await service.saveUserWallet(address: "").toAsync()
			try? await Task.sleep(for: .seconds(2))
		}
	}

	@Test func userFromPubliherAfterLogout() async {
		await confirmation { @MainActor confirm in
			service.getLatestUserInfoPublisher()
				.dropFirst()
				.sink { user in
					#expect(user == nil)
					confirm()
				}.store(in: &cancellableWrapper.cancellableSet)

			NotificationCenter.default.post(name: .keychainHelperServiceUserIsLoggedChanged,
											object: false)

			try? await Task.sleep(for: .seconds(2))
		}
	}
}
