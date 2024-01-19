//
//  ThreadSafe.swift
//  Toolkit
//
//  Created by Pantelis Giazitsis on 6/11/23.
//

import Foundation

@propertyWrapper public struct ThreadSafe<T> {
	private var value: T
	private let queue: DispatchQueue = DispatchQueue(label: "ThreadSafe_\(T.self)")

	public var wrappedValue: T {
		get {
			value
		}

		set {
			queue.sync {
				self.value = newValue
			}
		}
	}

	public init(value: T) {
		self.value = value
	}
}
