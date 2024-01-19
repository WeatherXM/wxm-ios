//
//  Badge.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 19/9/23.
//

import SwiftUI

private struct BadgeModifier: ViewModifier {

    let show: Bool
    @State private var size: CGSize = .zero

    func body(content: Content) -> some View {
        content
            .overlay {
                if show {
                    VStack {
                        HStack {
                            Spacer()
                            Circle()
                                .foregroundColor(Color(colorEnum: .favoriteHeart))
                                .frame(height: size.height * 0.35)
                                .offset(x: (size.height * 0.35) / 2.0, y: -(size.height * 0.35) / 4.0)
                        }

                        Spacer()
                    }
                }
            }
            .sizeObserver(size: $size)
    }
}

extension View {
    func badge(show: Bool) -> some View {
        modifier(BadgeModifier(show: show))
    }
}

#Preview {
    Text(verbatim: "geroger")
        .badge(show: true)
}
