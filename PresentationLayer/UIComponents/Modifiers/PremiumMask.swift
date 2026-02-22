//
//  PremiumMask.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 25/1/26.
//

import SwiftUI

private struct PremiumMaskModifier: ViewModifier {
    let enabled: Bool
    let colors: [Color]

    func body(content: Content) -> some View {
        content
            .overlay {
                if enabled {
                    LinearGradient(gradient: Gradient(colors: colors),
                                   startPoint: .leading,
                                   endPoint: .trailing)
                    .mask {
                        content
                    }
                }
            }
    }
}

extension View {
    @ViewBuilder
    func premiumMask(enabled: Bool,
                     colors: [Color] = [Color(colorEnum: .chartPrimary),
                                        Color(colorEnum: .accent)]) -> some View {
        modifier(PremiumMaskModifier(enabled: enabled, colors: colors))
    }
}

