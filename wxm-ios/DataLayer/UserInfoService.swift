//
//  UserInfoService.swift
//  DataLayer
//
//  Created by Pantelis Giazitsis on 5/12/23.
//

import Foundation
import DomainLayer
import Toolkit
import Combine
import Alamofire

public class UserInfoService {
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
		publisher.sink { [weak self] response in
			guard let value = response.value else {
				return
			}
			WXMAnalytics.shared.setUserId(value.id)
			
			let hasWallet = value.wallet?.address?.isEmpty == false
			WXMAnalytics.shared.setUserProperty(key: .hasWallet, value: .custom(String(hasWallet)))

			self?.userInfoSubject.send(value)
		}
		.store(in: &cancellableSet)
		
		return publisher
	}

	public func saveUserWallet(address: String) throws -> AnyPublisher<DataResponse<EmptyEntity, NetworkErrorResponse>, Never> {
		let urlRequest = try MeApiRequestBuilder.saveUserWallet(address: address).asURLRequest()
		let publisher: AnyPublisher<DataResponse<EmptyEntity, NetworkErrorResponse>, Never> = ApiClient.shared.requestCodableAuthorized(urlRequest)
		return publisher.flatMap { [weak self] response in
			if response.error == nil {
				_ = try? self?.getUser()
			}
			return Just(response)
		}
		.eraseToAnyPublisher()
	}

	public func getLatestUserInfoPublisher() -> AnyPublisher<NetworkUserInfoResponse?, Never> {
		userInfoSubject.eraseToAnyPublisher()
	}
}
