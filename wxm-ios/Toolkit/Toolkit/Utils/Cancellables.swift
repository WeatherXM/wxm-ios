//
//  Cancellables.swift
//  DomainLayer
//
//  Created by Pantelis Giazitsis on 31/7/23.
//

import Foundation
import Combine

/// A wrapper to keep the cancellables for sturcts
public class CancellableWrapper {
    public var cancellableSet: Set<AnyCancellable> = []

    public init() {}
}


public extension AnyCancellable {
	@MainActor func storeThreadSafe(in set: inout Set<AnyCancellable>) {
		store(in: &set)
	}
}
