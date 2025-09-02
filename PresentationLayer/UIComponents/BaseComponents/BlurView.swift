//
//  BlurView.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 2/9/25.
//

import Foundation
import SwiftUI

private struct BlurView: UIViewRepresentable {

	func makeUIView(context: Context) -> UIVisualEffectView {
		let view = UIVisualEffectView()
		let blur = UIBlurEffect()
		view.effect = blur

		return view
	}

	func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
	}
}

struct BackdropBlurView: View {
	let radius: CGFloat

	@ViewBuilder
	var body: some View {
		BlurView().blur(radius: radius)
	}
}

#Preview {
	ZStack {
		Image(asset: .wrongInstallation0)
		BackdropBlurView(radius: 5)
		Text("Hello, World!")
	}
}
