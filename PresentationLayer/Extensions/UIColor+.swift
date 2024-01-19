//
//  UIColor+.swift
//  PresentationLayer
//
//  Created by Hristos Condrea on 13/5/22.
//

import Foundation
import SwiftUI

extension UIColor {
    convenience init(colorEnum: ColorEnum) {
        self.init(Color(colorEnum: colorEnum))
    }
}
