//
//  CallbackTypes.swift
//  Toolkit
//
//  Created by Pantelis Giazitsis on 14/3/23.
//

import Foundation

public typealias VoidCallback = () -> Void
public typealias GenericCallback<T> = (T) -> Void
public typealias GenericValueCallback<T, U> = (T) -> U
public typealias GenericValueWithNoArgumentCallback<T> = () -> T
