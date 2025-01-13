//
//  WXMShareModifier.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 13/11/23.
//

import Foundation

import SwiftUI
import Toolkit
import LinkPresentation

private struct WXMShareModifier: ViewModifier {
	@Binding var show: Bool
	let text: String
	let images: [UIImage]
	@State private var hostingWrapper: HostingWrapper = HostingWrapper()
	@State private var store = Store()

	func body(content: Content) -> some View {
		content
			.background(InternalAnchorView(uiView: store.anchorView))
			.onChange(of: show) { newValue in
				if newValue {
					presentShare(sourceView: store.anchorView)
				} else {
					hostingWrapper.hostingController?.dismiss(animated: true)
				}
			}
	}

	func presentShare(sourceView: UIView?) {
		var items: [Any] = [text]
		items.append(contentsOf: images.map { getItemSource(image: $0) })
		let activityController = WXMActivityViewController(activityItems: items, applicationActivities: nil)
		activityController.popoverPresentationController?.sourceView = sourceView
		activityController.willDismissCallback = { show = false }
		hostingWrapper.hostingController = activityController
		UIApplication.shared.rootViewController?.present(activityController, animated: true)
	}

	func getItemSource(image: UIImage) -> ShareFileItemSource? {
		ShareFileItemSource(image: image)
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

	class ShareFileItemSource: NSObject, UIActivityItemSource {
		let image: UIImage

		init(image: UIImage) {
			self.image = image
		}

		func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
			UIImage()
		}
		
		func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
			image
		}

		func activityViewControllerLinkMetadata(_ activityViewController: UIActivityViewController) -> LPLinkMetadata? {
			let imageProvider = NSItemProvider(object: image)
			let metadata = LPLinkMetadata()
			metadata.imageProvider = imageProvider
			return metadata
		}
	}
}

extension View {
	@ViewBuilder
	func wxmShareDialog(show: Binding<Bool>, text: String, images: [UIImage] = []) -> some View {
		modifier(WXMShareModifier(show: show, text: text, images: images))
	}
}
