//
//  Combine+.swift
//  Toolkit
//
//  Created by Pantelis Giazitsis on 8/1/24.
//

import Foundation
import Combine

public extension AnyPublisher {
	func toAsync() async throws -> Output {
		try await withCheckedThrowingContinuation { continuation in
			var cancellable: AnyCancellable?
			cancellable = first()
				.sink { result in
					switch result {
						case .finished:
							break
						case let .failure(error):
							continuation.resume(throwing: error)
					}
					cancellable?.cancel()
				} receiveValue: { value in
					continuation.resume(with: .success(value))
				}
		}
	}
}
