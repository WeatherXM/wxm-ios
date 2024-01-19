//
//  ChartModifier.swift
//  PresentationLayer
//
//  Created by Lampros Zouloumis on 6/9/22.
//

import SwiftUI

struct ChartModifier: ViewModifier {
    let height: Double
    let cornerRadius: Double
    let paddingOffset: Double

    func body(content: Content) -> some View {
        content
            .frame(height: height)
            .padding(.vertical, paddingOffset)
            .background(Color(colorEnum: .top))
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .padding(.horizontal, paddingOffset)
    }
}

extension View {
    func chartModifier(
        height: Double = 180,
        cornerRadius: Double = 12,
        paddingOffset: Double = 20
    ) -> some View { modifier(
        ChartModifier(height: height, cornerRadius: cornerRadius, paddingOffset: paddingOffset)
    )
    }
}
