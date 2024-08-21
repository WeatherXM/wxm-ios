//
//  GifImageView.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 2/5/24.
//

import SwiftUI
import WebKit
import FLAnimatedImage

struct GifImageView: UIViewRepresentable {
	let fileName: String

	func makeUIView(context: Context) -> UIImageView {
		let imageView = FLAnimatedImageView()
		guard let url = Bundle.main.url(forResource: fileName,
										withExtension: "gif"),
			  let data = try? Data(contentsOf: url) else {
			return imageView
		}

		let image = FLAnimatedImage(gifData: data)
		imageView.animatedImage = image
		imageView.contentMode = .scaleAspectFit

		imageView.setContentHuggingPriority(.defaultLow, for: .vertical)
		imageView.setContentHuggingPriority(.defaultLow, for: .horizontal)
		imageView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
		imageView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

		return imageView
	}

	func updateUIView(_ uiView: UIImageView, context: Context) {}
}

#Preview {
	ZStack {
		Color.red
			.ignoresSafeArea()
		GifImageView(fileName: "image_pulse_claiming_key")
			.aspectRatio(1.0, contentMode: .fit)
			.padding(.horizontal)

	}
}
