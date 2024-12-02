//
//  WXMPopover.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 5/7/23.
//

import SwiftUI
import Toolkit

private struct PopOverModifier<V: View>: ViewModifier {
    @Binding var show: Bool
    let content: () -> V
    @State private var hostingWrapper: HostingWrapper = HostingWrapper()
    @State private var store = Store()

    func body(content: Content) -> some View {
        if #available(iOS 16.4, *) {
            content
                .popover(isPresented: $show) {
                    self.content()
                        .fixedSize()
                        .presentationCompactAdaptation(.popover)
                }
				.onChange(of: show) { value in
					// Add an overlay on top of `NavigationStack` container to fix a SwiftUI issue with gestures
					// More info https://stackoverflow.com/questions/71714592/sheet-dismiss-gesture-with-swipe-back-gesture-causes-app-to-freeze
					Router.shared.showDummyOverlay = value
				}
        } else {
            content
                .background(InternalAnchorView(uiView: store.anchorView))
                .onChange(of: show) { newValue in
                    if newValue {
                        presentPopover()
                    } else {
                        dismissPopover()
                    }
                }
        }
    }

    private func presentPopover() {
        let contentController = PopoverHostingController(rootView: content())
        contentController.modalPresentationStyle = .popover
        contentController.willDismissCallback = {
            show = false
        }

        let view = store.anchorView
        guard let popover = contentController.popoverPresentationController else { return }
        popover.sourceView = view
        popover.sourceRect = view.bounds
        popover.permittedArrowDirections = .up
        popover.delegate = contentController

        hostingWrapper.hostingController = contentController
        UIApplication.shared.topViewController?.present(contentController, animated: true)
    }

    private func dismissPopover() {
        hostingWrapper.hostingController?.dismiss(animated: true)
    }
}

private extension PopOverModifier {

	@MainActor
	struct Store {
        var anchorView = UIView()
    }

    class PopoverHostingController: UIHostingController<V>, UIPopoverPresentationControllerDelegate {
        var willDismissCallback: VoidCallback?

        override func viewDidLoad() {
            super.viewDidLoad()
            let size = sizeThatFits(in: UIView.layoutFittingExpandedSize)
            preferredContentSize = size
        }

        override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)
            if isBeingDismissed {
                willDismissCallback?()
            }
        }

        func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
            .none
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
	func wxmPopOver<Content: View>(show: Binding<Bool>, content: @escaping () -> Content) -> some View {
        modifier(PopOverModifier(show: show, content: content))
    }
}
