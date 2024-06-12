//
//  SpinningLoader.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 20/6/23.
//

import SwiftUI

struct SpinningLoaderModifier: ViewModifier {
    @Binding var show: Bool
	let lottieLoader: Bool
    let hideContent: Bool

	func body(content: Content) -> some View {
		content
			.opacity((hideContent && show) ? 0.0 : 1.0)
			.overlay {
				if show {
					VStack {
						Group {
							if lottieLoader {
								SpinningLoaderView()
							} else {
								ProgressView()
							}
						}
						.if(!hideContent) { view in
							view.wxmShadow()
						}
					}
				}
			}
	}
}

extension View {
    func spinningLoader(show: Binding<Bool>, 
						lottieLoader: Bool = true,
						hideContent: Bool = false) -> some View {
        modifier(SpinningLoaderModifier(show: show,
										lottieLoader: lottieLoader,
										hideContent: hideContent))
    }
}

struct Previews_SpinningLoader_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Color.white
                .ignoresSafeArea()
        }
        .spinningLoader(show: .constant(true), lottieLoader: false, hideContent: true)
    }
}
