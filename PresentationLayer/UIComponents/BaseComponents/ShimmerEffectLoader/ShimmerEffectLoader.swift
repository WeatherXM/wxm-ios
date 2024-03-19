//
//  ShimmerEffectLoader.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 19/6/23.
//

import SwiftUI

struct ShimmerEffectModifier: ViewModifier {
    @Binding var show: Bool
    let position: Position
    let horizontalPadding: CGFloat
    let bottomPadding: CGFloat

    func body(content: Content) -> some View {
        content.overlay {
            if show {
                VStack {
                    if position == .bottom {
                        Spacer()
                    }

                    ShimmerEffectLoaderView()
                        .frame(height: 4.0)
                        .padding(.horizontal, horizontalPadding)
                        .padding(.bottom, bottomPadding)

                    if position == .top {
                        Spacer()
                    }
                }
                .transition(AnyTransition.opacity.animation(.easeIn(duration: 0.2)))
            }
        }
    }
}

extension ShimmerEffectModifier {
    enum Position {
        case top
        case bottom
    }
}

extension View {
    func shimmerLoader(show: Binding<Bool>,
                       position: ShimmerEffectModifier.Position = .top,
                       horizontalPadding: CGFloat = 0.0,
                       bottomPadding: CGFloat = 0.0) -> some View {
        modifier(ShimmerEffectModifier(show: show,
                                       position: position,
                                       horizontalPadding: horizontalPadding,
                                       bottomPadding: bottomPadding))
    }
}

struct Previews_ShimmerEffectLoader_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Color.gray
                .ignoresSafeArea()
        }
        .shimmerLoader(show: .constant(true), horizontalPadding: 10.0)
    }
}
