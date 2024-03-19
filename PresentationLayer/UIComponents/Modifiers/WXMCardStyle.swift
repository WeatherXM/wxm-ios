//
//  WXMCardStyle.swift
//  PresentationLayer
//
//  Created by Danae Kikue Dimou on 10/5/22.
//

import SwiftUI

struct WXMCardModifier: ViewModifier {
    let backgroundColor: Color
    let foregroundColor: Color
    let insideHorizontalPadding: CGFloat
    let insideVerticalPadding: CGFloat
    let cornerRadius: CGFloat

    func body(content: Content) -> some View {
        content
            .padding(.horizontal, insideHorizontalPadding)
            .padding(.vertical, insideVerticalPadding)
            .background(backgroundColor)
            .foregroundColor(foregroundColor)
            .cornerRadius(cornerRadius)
    }
}

extension View {
    func WXMCardStyle(
        backgroundColor: Color = Color(colorEnum: .top),
        foregroundColor: Color = Color(colorEnum: .text),
        insideHorizontalPadding: CGFloat = CGFloat(.defaultSidePadding),
        insideVerticalPadding: CGFloat = CGFloat(.defaultSidePadding),
        cornerRadius: CGFloat = CGFloat(.cardCornerRadius)

    ) -> some View { modifier(
        WXMCardModifier(
            backgroundColor: backgroundColor,
            foregroundColor: foregroundColor,
            insideHorizontalPadding: insideHorizontalPadding,
            insideVerticalPadding: insideVerticalPadding,
            cornerRadius: cornerRadius
        ))
    }
}
