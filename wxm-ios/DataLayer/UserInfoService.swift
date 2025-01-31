//
//  UserInfoService.swift
//  DataLayer
//
//  Created by Pantelis Giazitsis on 5/12/23.
//

import Foundation
@preconcurrency import DomainLayer
import Toolkit
import Combine
import Alamofire

public class UserInfoService: @unchecked Sendable {
	private var cancellableSet: Set<AnyCancellable> = []
	private var userInfoSubject = CurrentValueSubject<NetworkUserInfoResponse?, Never>(nil)

	public init() {
		NotificationCenter.default.addObserver(forName: .keychainHelperServiceUserIsLoggedChanged,
											   object: nil,
											   queue: nil) { [weak self] notification in
			guard notification.object as? Bool == false else {
				return
			}
			self?.userInfoSubject.send(nil)
			WXMAnalytics.shared.removeUserProperty(key: .hasWallet)
			WXMAnalytics.shared.userLoggedOut()
		}
	}

	deinit {
		NotificationCenter.default.removeObserver(self)
	}

	public func getUser() throws -> AnyPublisher<DataResponse<NetworkUserInfoResponse, NetworkErrorResponse>, Never> {
		let builder = MeApiRequestBuilder.getUser
		let urlRequest = try builder.asURLRequest()
		let publisher: AnyPublisher<DataResponse<NetworkUserInfoResponse, NetworkErrorResponse>, Never> = ApiClient.shared.requestCodableAuthorized(urlRequest,
																																					mockFileName: builder.mockFileName).share().eraseToAnyPublisher()
		return publisher.flatMap { [weak self] response in
			let value = response.value

			WXMAnalytics.shared.setUserId(value?.id)

			let hasWallet = value?.wallet?.address?.isEmpty == false
			WXMAnalytics.shared.setUserProperty(key: .hasWallet, value: .custom(String(hasWallet)))

			self?.userInfoSubject.send(value)

			return Just(response)
		}.eraseToAnyPublisher()
	}

	public func saveUserWallet(address: String) throws -> AnyPublisher<DataResponse<EmptyEntity, NetworkErrorResponse>, Never> {
		let builder = MeApiRequestBuilder.saveUserWallet(address: address)
		let urlRequest = try builder.asURLRequest()
		let publisher: AnyPublisher<DataResponse<EmptyEntity, NetworkErrorResponse>, Never> = ApiClient.shared.requestCodableAuthorized(urlRequest, mockFileName: builder.mockFileName)
		return publisher.flatMap { [weak self] response in
			if let self, response.error == nil {
				_ = try? self.getUser().sink { _ in }.store(in: &self.cancellableSet)
			}
			return Just(response)
		}
		.eraseToAnyPublisher()
	}

	public func getLatestUserInfoPublisher() -> AnyPublisher<NetworkUserInfoResponse?, Never> {
		userInfoSubject.eraseToAnyPublisher()
	}
}
