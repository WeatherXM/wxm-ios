//
//  CGFloat+.swift
//  PresentationLayer
//
//  Created by Danae Kikue Dimou on 10/5/22.
//

import Foundation
import SwiftUI

extension CGFloat {
    init(_ dimension: Dimension) {
        self.init(dimension.value)
    }

    init(_ fontSizeEnum: FontSizeEnum) {
        self.init(fontSizeEnum.sizeValue)
    }
}
