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
		NotificationCenter.default.addObserver(forName: .keychainHelperServiceUserIsLoggedOut,
											   object: nil,
											   queue: nil) { [weak self] _ in
			self?.userInfoSubject.send(nil)
		}
	}

	deinit {
		NotificationCenter.default.removeObserver(self)
	}

	public func getUser() throws -> AnyPublisher<DataResponse<NetworkUserInfoResponse, NetworkErrorResponse>, Never> {
		let urlRequest = try MeApiRequestBuilder.getUser.asURLRequest()
		let publisher: AnyPublisher<DataResponse<NetworkUserInfoResponse, NetworkErrorResponse>, Never> = ApiClient.shared.requestCodableAuthorized(urlRequest).share().eraseToAnyPublisher()
		publisher.sink { [weak self] response in
			guard let value = response.value else {
				return
			}
			Logger.shared.setUserId(value.id)
			self?.userInfoSubject.send(value)
		}
		.store(in: &cancellableSet)
		
		return publisher
	}

	public func getLatestUserInfoPublisher() -> AnyPublisher<NetworkUserInfoResponse?, Never> {
		userInfoSubject.eraseToAnyPublisher()
	}
}
