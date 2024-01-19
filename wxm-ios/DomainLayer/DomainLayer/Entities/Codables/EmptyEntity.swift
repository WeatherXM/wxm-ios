//
//  EmptyEntity.swift
//  DomainLayer
//
//  Created by Hristos Condrea on 17/5/22.
//

import Alamofire
import Foundation

public struct EmptyEntity: Codable, EmptyResponse {
    public static func emptyValue() -> EmptyEntity {
        return EmptyEntity()
    }
}
