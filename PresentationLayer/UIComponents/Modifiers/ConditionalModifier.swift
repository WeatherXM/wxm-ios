//
//  ConditionalModifier.swift
//  PresentationLayer
//
//  Created by Pantelis Giazitsis on 31/1/23.
//

import SwiftUI

struct ConditionalModifier<V: View>: ViewModifier {
    let condition: Bool

    @ViewBuilder
    let transform: (Content) -> V

    func body(content: Content) -> some View {
        if condition {
            transform(content)
        }
    }
}

extension View {
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool,
                             @ViewBuilder transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

extension View {
    /// A way to apply conditional modifiers in view
    /// - Parameter transform: Apply the needed modifiers
    /// - Returns: The modified view
    @ViewBuilder func modify<Content: View>(@ViewBuilder modify: (Self) -> Content) -> some View {
        modify(self)
    }
}
