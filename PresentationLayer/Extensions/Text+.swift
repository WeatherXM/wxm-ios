//
//  Text+.swift
//  PresentationLayer
//
//  Created by Hristos Condrea on 16/5/22.
//

import SwiftUI

extension Text {

    init(_ doubleValue: Double, specifier: String) {
        self.init("\(doubleValue, specifier: specifier)")
    }
}
