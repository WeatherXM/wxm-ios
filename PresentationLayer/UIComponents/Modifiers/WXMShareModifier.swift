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
	let files: [URL]
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
		items.append(contentsOf: files.map { getItemSource(file: $0) })
		let activityController = WXMActivityViewController(activityItems: items, applicationActivities: nil)
		activityController.popoverPresentationController?.sourceView = sourceView
		activityController.willDismissCallback = { show = false }
		hostingWrapper.hostingController = activityController
		UIApplication.shared.rootViewController?.present(activityController, animated: true)
	}

	func getItemSource(file: URL) -> ShareFileItemSource? {
		ShareFileItemSource(fileUrl: file)
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
		let fileUrl: URL

		init(fileUrl: URL) {
			self.fileUrl = fileUrl
		}

		func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
			UIImage()
		}
		
		func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
			fileUrl
		}

		func activityViewControllerLinkMetadata(_ activityViewController: UIActivityViewController) -> LPLinkMetadata? {
			guard let image = UIImage(contentsOfFile: fileUrl.path()) else {
				return nil
			}
			let imageProvider = NSItemProvider(object: image)
			let metadata = LPLinkMetadata()
			metadata.imageProvider = imageProvider
			return metadata
		}
	}
}

extension View {
	@ViewBuilder
	func wxmShareDialog(show: Binding<Bool>, text: String, files: [URL] = []) -> some View {
		modifier(WXMShareModifier(show: show, text: text, files: files))
	}
}
