//
//  AsyncOperations.swift
//  Toolkit
//
//  Created by Pantelis Giazitsis on 4/8/23.
//

import Foundation

public extension Sequence {

    /// Iterates the sequence with async operations. Similar functionality to `ForEach`
    /// - Parameter operation: The async operation to be performed for each element
    func asyncForEach(_ operation: (Element) async throws -> Void) async rethrows {
        for element in self {
            try await operation(element)
        }
    }

    /// Returns an array containing the results of mapping the given async operation, similar to `map`
    /// - Parameter transform: The async operation to be performed for each element
    /// - Returns: The array with the mapped elements
    func asyncMap<T>(_ transform: (Element) async throws -> T) async rethrows -> [T] {
        var values = [T]()

        for element in self {
            try await values.append(transform(element))
        }

        return values
    }

    /// Returns an array containing the non-nil results of mapping the given async operation, similar to `map`
    /// - Parameter transform: The async operation to be performed for each element
    /// - Returns: The array with the mapped elements
    func asyncCompactMap<T>(_ transform: (Element) async throws -> T?) async rethrows -> [T]  {
        var values = [T]()

        for element in self {
            guard let value = try await transform(element) else {
                continue
            }

            values.append(value)
        }

        return values
    }
}
