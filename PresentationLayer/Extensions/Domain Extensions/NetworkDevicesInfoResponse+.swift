//
//  NetworkDevicesInfoResponse+.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 28/3/23.
//

import Foundation
import DomainLayer

extension NetworkDevicesInfoResponse.BatState: CustomStringConvertible {
    public var description: String {
        switch self {
            case .low:
                return LocalizableString.low.localized
            case .ok:
                return LocalizableString.good.localized
        }
    }
}
