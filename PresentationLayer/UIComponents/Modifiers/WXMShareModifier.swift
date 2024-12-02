//
//  WXMShareModifier.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 13/11/23.
//

import Foundation

import SwiftUI
import Toolkit

private struct WXMShareModifier: ViewModifier {
	@Binding var show: Bool
	let text: String
	@State private var hostingWrapper: HostingWrapper = HostingWrapper()
	@State private var store = Store()

	func body(content: Content) -> some View {
		content
			.background(InternalAnchorView(uiView: store.anchorView))
			.onChange(of: show) { newValue in
				if newValue {
					presentShare(text: text, sourceView: store.anchorView)
				} else {
					hostingWrapper.hostingController?.dismiss(animated: true)
				}
			}
	}

	func presentShare(text: String, sourceView: UIView?) {
		let items = [text]
		let activityController = WXMActivityViewController(activityItems: items, applicationActivities: nil)
		activityController.popoverPresentationController?.sourceView = sourceView
		activityController.willDismissCallback = { show = false }
		hostingWrapper.hostingController = activityController
		UIApplication.shared.rootViewController?.present(activityController, animated: true)
	}
}

private extension WXMShareModifier {
	@MainActor
	struct Store {
		var anchorView = UIView()
	}

	class WXMActivityViewController: UIActivityViewController {
		var willDismissCallback: VoidCallback?

		override func viewWillDisappear(_ animated: Bool) {
			super.viewWillDisappear(animated)
			if isBeingDismissed {
				willDismissCallback?()
			}
		}

		deinit {
			print("deinit \(Self.self)")
		}
	}

	struct InternalAnchorView: UIViewRepresentable {
		typealias UIViewType = UIView
		let uiView: UIView

		func makeUIView(context: Self.Context) -> Self.UIViewType {
			uiView
		}

		func updateUIView(_ uiView: Self.UIViewType, context: Self.Context) { }
	}
}

extension View {
	@ViewBuilder
	func wxmShareDialog(show: Binding<Bool>, text: String) -> some View {
		modifier(WXMShareModifier(show: show, text: text))
	}
}
