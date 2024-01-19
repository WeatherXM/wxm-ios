//
//  StorageWrapper.swift
//  Toolkit
//
//  Created by Pantelis Giazitsis on 16/10/23.
//

import Foundation

public class StorageWrapper<T> {

	@ThreadSafe(value: nil) public var data: T?

	public init() {}
}
