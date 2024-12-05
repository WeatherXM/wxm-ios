//
//  Combine+.swift
//  Toolkit
//
//  Created by Pantelis Giazitsis on 8/1/24.
//

import Foundation
@preconcurrency import Combine

public extension AnyPublisher {
	nonisolated func toAsync() async throws -> Output {
		try await withUnsafeThrowingContinuation { continuation in
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
					nonisolated(unsafe) let receivedValue = value
					continuation.resume(returning: receivedValue)
				}
		}
	}
}
