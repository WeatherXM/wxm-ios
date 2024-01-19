//
//  AuthInterceptor.swift
//  DataLayer
//
//  Created by Hristos Condrea on 8/8/22.
//

import Alamofire
import Combine
import DomainLayer
import Toolkit
import UIKit

class AuthInterceptor: RequestInterceptor {
    let retryLimit = 4
    let retryDelay: TimeInterval = 1
    let keychainHelperService = KeychainHelperService()
    private var cancellableSet: Set<AnyCancellable> = []

    func adapt(_ urlRequest: URLRequest, for _: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        var urlRequest = urlRequest

        let networkTokenResponse = keychainHelperService.getNetworkTokenResponse()
        if let accessToken = networkTokenResponse?.token {
            urlRequest.setValue("Bearer \(accessToken)", forHTTPHeaderField: NetworkConstants.HttpHeaderField.authorization.rawValue)
        }

        completion(.success(urlRequest))
    }

    func retry(_ request: Request, for _: Session, dueTo _: Error, completion: @escaping (RetryResult) -> Void) {
        let networkTokenResponse = keychainHelperService.getNetworkTokenResponse()
        guard let refreshToken = networkTokenResponse?.refreshToken, let statusCode = request.response?.statusCode else {
            completion(.doNotRetry)
            return
        }
        switch statusCode {
            case 200 ... 299:
                completion(.doNotRetry)
            case 401:
                let keychainRepositoryImpl = KeychainRepositoryImpl()
                refreshTokenResponse(refreshToken: refreshToken) { networkTokenCompletion in
                    if let networkTokenCompletion = networkTokenCompletion {
                        keychainRepositoryImpl.saveNetworkTokenResponseToKeychain(item: networkTokenCompletion)
                        completion(.retryWithDelay(self.retryDelay))
                    } else {
                        keychainRepositoryImpl.deleteNetworkTokenResponseFromKeychain()
                        keychainRepositoryImpl.deleteEmailAndPasswordFromKeychain()
                        completion(.doNotRetry)
                    }
                }
            default:
                completion(.doNotRetry)
        }
    }

    private func refreshTokenResponse(refreshToken: String, completion: @escaping (NetworkTokenResponse?) -> Void) {
        do {
            try AuthRepositoryImpl().refresh(refreshToken: refreshToken)
                .sink { response in
                    if response.error != nil {
                        self.retryLogin(completion: completion)
                    } else {
                        completion(response.value!)
                    }
                }.store(in: &cancellableSet)
        } catch {}
    }

    private func retryLogin(completion: @escaping (NetworkTokenResponse?) -> Void) {
        if let accountInfo = keychainHelperService.getUsersAccountInfo() {
            do {
                try AuthRepositoryImpl().login(username: accountInfo.email, password: accountInfo.password)
                    .sink { response in
                        if response.error != nil {
                            completion(nil)
                        } else {
                            completion(response.value!)
                        }
                    }.store(in: &cancellableSet)
            } catch {}
        }
    }
}
