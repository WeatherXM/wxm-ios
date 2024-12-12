//
//  WebContainerView.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 4/12/23.
//

import SwiftUI
import WebKit
import Toolkit

private let disableZoomScript = "var meta = document.createElement('meta');" +
"meta.name = 'viewport';" +
"meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no';" +
"var head = document.getElementsByTagName('head')[0];" +
"head.appendChild(meta);"

struct WebContainerView: View {
	let title: String
	let url: String
	var params: [DisplayLinkParams: String]?
	var appearCallback: VoidCallback?
	var backButtonCallback: VoidCallback?
	var redirectParamsCallback: DeepLinkHandler.QueryParamsCallBack?
	@State private var isLoading: Bool = false

	var body: some View {
		NavigationContainerView {
			WXMWebView(isLoading: $isLoading,
					   title: title,
					   url: url,
					   params: params,
					   backButtonCallback: backButtonCallback,
					   redirectParamsCallback: redirectParamsCallback)
			.spinningLoader(show: $isLoading, hideContent: false)
			.onAppear {
				appearCallback?()
			}
		}
	}
}

extension WebContainerView {
	struct Configuration {
		let title: String
		let url: String
		var params: [DisplayLinkParams: String]?
		var onAppearCallback: VoidCallback?
		var backButtonCallback: VoidCallback?
		var redirectParamsCallback: DeepLinkHandler.QueryParamsCallBack?
	}

	init(configuration: Configuration) {
		self.title = configuration.title
		self.url = configuration.url
		self.params = configuration.params
		self.appearCallback = configuration.onAppearCallback
		self.backButtonCallback = configuration.backButtonCallback
		self.redirectParamsCallback = configuration.redirectParamsCallback
	}
}

private struct WXMWebView: UIViewRepresentable {
	@Binding var isLoading: Bool
	let title: String
	let url: String
	var params: [DisplayLinkParams: String]?
	var backButtonCallback: VoidCallback?
	var redirectParamsCallback: DeepLinkHandler.QueryParamsCallBack?

	@EnvironmentObject var navigationObject: NavigationObject

	func makeCoordinator() -> Coordinator {
		let coordinator = Coordinator(isLoading: $isLoading)
		coordinator.redirectParamsCallback = redirectParamsCallback

		return coordinator
	}

	func makeUIView(context: Context) -> WKWebView {
		var webUrl = URL(string: url)
		params?.forEach { key, value in
			webUrl?.appendQueryItem(name: key.rawValue, value: value)
		}

		let configuration = WKWebViewConfiguration()
		// Disable zoom
		let script: WKUserScript = WKUserScript(source: disableZoomScript, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
		configuration.userContentController.addUserScript(script)

		let webView = WKWebView(frame: .zero, configuration: configuration)
		webView.scrollView.bounces = false
		webView.scrollView.zoomScale = 1.0
		webView.scrollView.minimumZoomScale = 1.0
		webView.scrollView.maximumZoomScale = 1.0

		webView.navigationDelegate = context.coordinator
		if let webUrl {
			print("web url: \(webUrl)")
			webView.load(URLRequest(url: webUrl))
		}

		DispatchQueue.main.async {
			navigationObject.title = title
		}

		navigationObject.shouldDismissAction = {
			backButtonCallback?()
			return true
		}

		return webView
	}

	func updateUIView(_ uiView: WKWebView, context: Context) {
	}

	class Coordinator: NSObject, WKNavigationDelegate, WKURLSchemeHandler {
		@Binding var isLoading: Bool
		var redirectParamsCallback: DeepLinkHandler.QueryParamsCallBack?

		init(isLoading: Binding<Bool>) {
			_isLoading = isLoading
		}

		func webView(_ webView: WKWebView, start urlSchemeTask: WKURLSchemeTask) {
			print(urlSchemeTask)
		}

		func webView(_ webView: WKWebView, stop urlSchemeTask: WKURLSchemeTask) {
			print(urlSchemeTask)
		}

		func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping @MainActor (WKNavigationActionPolicy) -> Void) {
			DispatchQueue.main.async { [weak self] in
				guard let requestUrl = navigationAction.request.url,
					  MainScreenViewModel.shared.deepLinkHandler.handleUrl(requestUrl,
																		   queryParamsCallback: self?.redirectParamsCallback) else {
					decisionHandler(.allow)

					return
				}

				decisionHandler(.cancel)
			}
		}

		func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
			isLoading = true
		}

		func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
			isLoading = false
		}

		func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
			isLoading = false
		}

		func webView(_ webView: WKWebView,
					 didFailProvisionalNavigation navigation: WKNavigation!,
					 withError error: Error) {
			isLoading = false
		}
	}
}

#Preview {
	WebContainerView(title: "Web View", url: "https://google.com", params: [.theme: "dark"])
}
