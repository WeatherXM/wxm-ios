//
//  Color+.swift
//  PresentationLayer
//
//  Created by Danae Kikue Dimou on 10/5/22.
//

import Foundation
import SwiftUI

extension Color {
    init(colorEnum: ColorEnum) {
        self.init(colorEnum.rawValue)
    }
}
