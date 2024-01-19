//
//  ExplorerLocationError+.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 24/5/23.
//

import DomainLayer

extension ExplorerLocationError: CustomStringConvertible {
    public var description: String {
        switch self {
            case .locationNotFound:
                return LocalizableString.explorerLocationNotFound.localized
            case .permissionDenied:
                return ""
        }
    }
}
