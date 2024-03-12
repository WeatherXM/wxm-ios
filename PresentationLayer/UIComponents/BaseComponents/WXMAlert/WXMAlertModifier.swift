//
//  WXMAlertModifier.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 23/8/23.
//

import SwiftUI
import Toolkit

private struct WXMAlertModifier<V: View>: ViewModifier {

    @Binding var show: Bool
    let content: () -> V

    @State private var opacity = 0.0
    @State private var hostingWrapper: HostingWrapper = .init()
    @State private var animator: OverlayAnimator?

    func body(content: Content) -> some View {
        content
            .onChange(of: show) { newValue in
                if newValue, hostingWrapper.hostingController == nil {
                    present()
                } else if !show {
                    dismiss()
                }
            }
    }
}

private extension WXMAlertModifier {

    struct AlertWrapper: View {
        let content: () -> V

        private let animationDuration = 0.2
        @State private var opacity = 0.0
        @State private var scale: CGSize = .zero

        var body: some View {
            ZStack {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .opacity(opacity)

                content()
                    .scaleEffect(scale)
                    .onAppear {
                        withAnimation(.easeIn(duration: animationDuration)) {
                            opacity = 1.0
                            scale = CGSize(width: 1.0, height: 1.0)
                        }
                    }
            }
        }
    }

    class HostingController: UIHostingController<AlertWrapper> {

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

    func present() {

        let controller = HostingController(rootView: AlertWrapper(content: content))
        controller.view.backgroundColor = .clear
        controller.modalPresentationStyle = .custom
        animator = OverlayAnimator()
        controller.transitioningDelegate = animator
        UIApplication.shared.topViewController?.present(controller, animated: true)
        controller.willDismissCallback = {
            show = false
        }
        hostingWrapper.hostingController = controller
    }

    func dismiss() {
        hostingWrapper.hostingController?.dismiss(animated: true)
    }
}

extension View {
    @ViewBuilder
    func wxmAlert<Content: View>(show: Binding<Bool>,
                                 content: @escaping () -> Content) -> some View {
        modifier(WXMAlertModifier(show: show, content: content))
    }
}

struct Previews_WXMAlert_Previews: PreviewProvider {
    struct TestView: View {
        @State private var show: Bool = false

        var body: some View {
            Button {
                show.toggle()
            } label: {
                Text(verbatim: "Hello")
            }
            .wxmAlert(show: $show) {
                Text(verbatim: "Hellozz")
            }
        }
    }

    static var previews: some View {
        TestView()
    }
}

struct Previews_WXMAlertWrapper_Previews: PreviewProvider {
    struct TestView: View {

        var body: some View {
            WXMAlertModifier.AlertWrapper {
                WXMAlertView(show: .constant(true),
                             configuration: .init(
                                title: "Add to favorites",
                                text: "Login to add **Perky Magenta Clothes** to your favorites and see historical & forecast data.".attributedMarkdown!,
                                secondaryButtons: [.init(title: "Cancel", action: {})],
                                primaryButtons: [.init(title: "Sign In", action: {})])) {
                                    HStack {
                                        Text(verbatim: "Don’t have an account? SIGN UP")
                                    }
                                }
            }
        }
    }

    static var previews: some View {
        TestView()
    }
}
