//
//  CustomColorButtonStyle.swift
//  PresentationLayer
//
//  Created by Manolis Katsifarakis on 6/12/22.
//

import SwiftUI

struct CustomColorButtonStyle: ButtonStyle {
    var textColor: Color = .init(colorEnum: .text)
    var pressedTextColor: Color = .init(colorEnum: .darkGrey)
    var backgroundColor: Color = .init(colorEnum: .top)
    var pressedBackgroundColor: Color = .init(colorEnum: .midGrey)
    public func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .opacity(1)
            .foregroundColor(configuration.isPressed ? pressedTextColor : textColor)
            .background(configuration.isPressed ? pressedBackgroundColor : backgroundColor)
    }
}
