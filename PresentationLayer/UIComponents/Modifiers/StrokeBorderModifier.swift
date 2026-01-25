//
//  StrokeBorderModifier.swift
//  PresentationLayer
//
//  Created by Pantelis Giazitsis on 30/1/23.
//

import SwiftUI

private struct StrokeBorderModifier: ViewModifier {
    let color: Color
    let lineWidth: CGFloat
    let radius: CGFloat
    let isPremium: Bool

    func body(content: Content) -> some View {
        content
            .overlay {
                RoundedRectangle(cornerRadius: radius)
                    .strokeBorder(color, lineWidth: lineWidth)
                    .premiumMask(enabled: isPremium)
            }
    }
}

extension View {
    @ViewBuilder
    func strokeBorder(color: Color, lineWidth: CGFloat, radius: CGFloat, isPremium: Bool = false) -> some View {
        modifier(StrokeBorderModifier(color: color, lineWidth: lineWidth, radius: radius, isPremium: isPremium))
    }
}
