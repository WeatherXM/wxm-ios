//
//  SpinningLoader.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 20/6/23.
//

import SwiftUI

struct SpinningLoaderModifier: ViewModifier {
    @Binding var show: Bool
    let hideContent: Bool

    func body(content: Content) -> some View {
        content
            .opacity((hideContent && show) ? 0.0 : 1.0)
            .overlay {
                if show {
                    VStack {
                        SpinningLoaderView()
                            .if(!hideContent) { view in
                                view.wxmShadow()
                            }
                    }
                }
            }
    }
}

extension View {
    func spinningLoader(show: Binding<Bool>, hideContent: Bool = false) -> some View {
        modifier(SpinningLoaderModifier(show: show, hideContent: hideContent))
    }
}

struct Previews_SpinningLoader_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Color.gray
                .ignoresSafeArea()
        }
        .spinningLoader(show: .constant(true), hideContent: true)
    }
}
