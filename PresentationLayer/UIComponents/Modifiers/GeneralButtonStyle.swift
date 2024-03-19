//
//  GeneralButtonStyle.swift
//  PresentationLayer
//
//  Created by Hristos Condrea on 23/5/22.
//

import SwiftUI

public struct GeneralButtonStyle: ButtonStyle {
    public func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .opacity(configuration.isPressed ? 0.7 : 1)
    }
}
