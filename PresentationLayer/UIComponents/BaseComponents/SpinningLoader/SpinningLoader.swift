//
//  SpinningLoader.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 20/6/23.
//

import SwiftUI

struct SpinningLoaderModifier: ViewModifier {
    @Binding var show: Bool
	let title: String?
	let subtitle: String?
	let lottieLoader: Bool
	let showLoaderBg: Bool
    let hideContent: Bool

	func body(content: Content) -> some View {
		content
			.opacity((hideContent && show) ? 0.0 : 1.0)
			.overlay {
				if show {
					VStack(spacing: CGFloat(.defaultSpacing)) {
						Group {
							if lottieLoader {
								SpinningLoaderView()
							} else {
								ProgressView()
							}
						}
						.background {
							if showLoaderBg {
								Circle().foregroundStyle(Color(colorEnum: .bg))
							}
						}
						.if(!hideContent) { view in
							view.wxmShadow()
						}

						VStack(spacing: CGFloat(.largeSpacing)) {
							if let title {
								Text(title)
									.font(.system(size: CGFloat(.largeTitleFontSize), weight: .bold))
									.foregroundStyle(Color(colorEnum: .text))
							}

							if let subtitle {
								Text(subtitle)
									.font(.system(size: CGFloat(.normalFontSize)))
									.foregroundStyle(Color(colorEnum: .text))
							}
						}
						.multilineTextAlignment(.center)
					}
					.padding(CGFloat(.defaultSidePadding))
				}
			}
	}
}

extension View {
    func spinningLoader(show: Binding<Bool>,
						title: String? = nil,
						subtitle: String? = nil,
						lottieLoader: Bool = true,
						showLoaderBg: Bool = false,
						hideContent: Bool = false) -> some View {
        modifier(SpinningLoaderModifier(show: show,
										title: title,
										subtitle: subtitle,
										lottieLoader: lottieLoader,
										showLoaderBg: showLoaderBg,
										hideContent: hideContent))
    }
}

struct Previews_SpinningLoader_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Color.white
                .ignoresSafeArea()
        }
		.spinningLoader(show: .constant(true),
						title: "title",
						subtitle: "subtitle",
						lottieLoader: true,
						showLoaderBg: true,
						hideContent: true)
    }
}
