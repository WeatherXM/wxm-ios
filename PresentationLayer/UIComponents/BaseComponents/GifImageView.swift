//
//  GifImageView.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 2/5/24.
//

import SwiftUI
import WebKit

struct GifImageView: UIViewRepresentable {
	let fileName: String

	func makeUIView(context: Context) -> WKWebView {
		let webview = WKWebView()
		webview.isOpaque = false
		webview.backgroundColor = .clear
		if let url = Bundle.main.url(forResource: fileName, withExtension: "gif"),
		   let data = try? Data(contentsOf: url) {
			webview.load(data,
						 mimeType: "image/gif",
						 characterEncodingName: "UTF-8",
						 baseURL: url.deletingLastPathComponent())
		}

		return webview
	}

	func updateUIView(_ uiView: WKWebView, context: Context) {
		uiView.reload()
	}
}

#Preview {
	ZStack {
		Color.red
			.ignoresSafeArea()
		GifImageView(fileName: "image_station_qr")
			.aspectRatio(1.0, contentMode: .fit)

	}
}
