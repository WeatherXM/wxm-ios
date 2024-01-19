//
//  Network+.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 22/6/23.
//

import DomainLayer

extension Connectivity {
    var icon: AssetEnum {
        switch self {
            case .wifi:
                return .wifi
            case .helium:
                return .helium
            case .cellular:
                return .wifi
        }
    }
}
