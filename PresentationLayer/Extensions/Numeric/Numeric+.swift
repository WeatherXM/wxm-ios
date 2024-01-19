//
//  Numeric+.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 29/6/23.
//

import Foundation
import Toolkit

extension Numeric {
    var toCompactDecimaFormat: String? {
        let statsFormatter = CompactNumberFormatter()
        return statsFormatter.string(for: self)
    }
}
