//
//  StaticButtonStyle.swift
//  PresentationLayer
//
//  Created by Manolis Katsifarakis on 19/11/22.
//

import SwiftUI

struct StaticButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
    }
}
