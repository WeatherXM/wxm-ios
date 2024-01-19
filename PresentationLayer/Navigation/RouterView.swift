//
//  RouterView.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 25/7/23.
//

import SwiftUI

struct RouterView<Content: View>: View {
    let content: () -> Content
    @StateObject private var router = Router.shared

    var body: some View {
        if #available(iOS 16.0, *) {
            NavigationStack(path: $router.path) {
                content()
                    .navigationDestination(for: Route.self) { route in
                        route.view
                    }
            }
			.overlay(
				Group {
					/// Disable NavigationStack gesture when there is a popover.
					/// It's a workaround to fix some interaction issues with navigation stack
					/// More info https://stackoverflow.com/questions/71714592/sheet-dismiss-gesture-with-swipe-back-gesture-causes-app-to-freeze
					if router.showDummyOverlay {
						Color.white.opacity(0.01)
							.highPriorityGesture(DragGesture(minimumDistance: 0))
							.ignoresSafeArea()
					}
				}
			)
        } else {
            // Fallback on earlier versions
            RouterViewController(host: router.navigationHost) {
                content()
            }
            .ignoresSafeArea()
        }
    }
}

struct RouterView_Previews: PreviewProvider {
    static var previews: some View {
        RouterView {
            Text(verbatim: "Hellozzz")
        }
    }
}

struct RouterViewController<Content: View>: UIViewControllerRepresentable {
    let host: HostingWrapper
    let content: () -> Content

    func makeUIViewController(context: Context) -> UINavigationController {
        let controller = UINavigationController(rootViewController: UIHostingController(rootView: content()))
        controller.navigationBar.prefersLargeTitles = true
        controller.navigationBar.tintColor = UIColor(colorEnum: .primary)
        host.hostingController = controller
        return controller
    }

    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {
        // Hacky way to refresh state of the first view
        (uiViewController.viewControllers.first as? UIHostingController<Content>)?.rootView = content() // Update content
    }
}
