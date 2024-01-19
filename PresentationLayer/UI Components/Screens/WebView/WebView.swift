//
//  WebView.swift
//  PresentationLayer
//
//  Created by Hristos Condrea on 31/10/22.
//

import SwiftUI
import WebKit

struct WebView: View {
    let userID: String
    let appID: String

    public init(userID: String, appID: String) {
        self.userID = userID
        self.appID = appID
    }

    var body: some View {
        VStack {
            WebViewRepresentable(userID: userID, appID: appID)
        }
    }
}

private struct WebViewRepresentable: UIViewRepresentable {
    let userID: String
    let appID: String

    public init(userID: String, appID: String) {
        self.userID = userID
        self.appID = appID
    }

    func makeUIView(context _: UIViewRepresentableContext<WebViewRepresentable>) -> WKWebView {
        let javaScript = "javascript:(function() { " +
            "document.getElementsByClassName('Dq4amc')[0].style.display='none'; " +
            "document.getElementsByClassName('Qr7Oae')[2].style.display='none'; " +
            "document.getElementsByClassName('Qr7Oae')[3].style.display='none'; " +
            "})()"
        // let javaScript = ""
        let userScript = WKUserScript(source: javaScript,
                                      injectionTime: .atDocumentEnd,
                                      forMainFrameOnly: true)
        let userContentController = WKUserContentController()
        userContentController.addUserScript(userScript)
        let configuration = WKWebViewConfiguration()
        configuration.userContentController = userContentController
        let webView = WKWebView(frame: CGRect.zero, configuration: configuration)
        let urlString: String
        if userID.isEmpty {
            urlString = "\(Constants.googleForm)&\(Constants.APP_ID_ENTRY)=\(appID)"
        } else {
            urlString = "\(Constants.googleForm)&\(Constants.APP_ID_ENTRY)=\(appID)&\(Constants.USER_ID_ENTRY)=\(userID)"
        }
        print(urlString)

        guard let url = URL(string: urlString) else {
            return webView
        }
        let urlRequest = URLRequest(url: url)
        webView.load(urlRequest)

        return webView
    }

    func makeCoordinator() -> WebViewNavigation {
        WebViewNavigation(self)
    }

    func updateUIView(_: WKWebView, context _: Context) {}

    class WebViewNavigation: NSObject, WKNavigationDelegate {
        let parent: WebViewRepresentable

        init(_ parent: WebViewRepresentable) {
            self.parent = parent
        }
    }
}

private extension WebViewRepresentable {
    enum Constants {
        static let googleForm = "https://docs.google.com/forms/d/e/1FAIpQLSdWPLpyUx2fNIiohQ-XaskbkZuoUSqYhwIkGGjupJ7IDEX_aA/viewform?usp=pp_url"
        static let USER_ID_ENTRY = "entry.695293761"
        static let APP_ID_ENTRY = "entry.2052436656"
    }
}
