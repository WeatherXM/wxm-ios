//
//  CustomSheet.swift
//  PresentationLayer
//
//  Created by Manolis Katsifarakis on 24/9/22.
//

import SwiftUI

public class SheetController {
    let dismiss: () -> Void
    init(dismiss: @escaping () -> Void) {
        self.dismiss = dismiss
    }
}

public extension View {
    /// Presents any content similarly to a
    /// [SwiftUI sheet](https://developer.apple.com/documentation/swiftui/button/sheet(ispresented:ondismiss:content:))
    /// but enables 100% custom styling as well as dynamic height.
    /// > Uses UIKit and UIHostingController under the hood to make sure the content is always presented on top of everything else.
    /// The presented content is completely responsible for its own presentation.
    /// No sheet background or styling is provided, besides a semi-transparent black overlay.
    func customSheet<Content: View>(
        isPresented: Binding<Bool>,
        allowSwipeAndTapToDismiss: Binding<Bool> = .constant(true),
        shouldBeCentered: Bool = false,
        onDismiss: (() -> Void)? = nil,
        @ViewBuilder content: @escaping (SheetController) -> Content
    ) -> some View {
        return modifier(
            CustomSheetModifier(
                customSheet: CustomSheet(
                    isPresented: isPresented,
                    allowSwipeAndTapToDismiss: allowSwipeAndTapToDismiss,
                    shouldBeCentered: shouldBeCentered,
                    onDismiss: onDismiss,
                    content: content
                )
            )
        )
    }
}

private struct CustomSheet<Content: View>: View {
    @Binding var isPresented: Bool
    @Binding var allowSwipeAndTapToDismiss: Bool
    var shouldBeCentered: Bool

    let onDismiss: (() -> Void)?
    var content: (SheetController) -> Content

    @State private var dragState = DragState.inactive

    @State private var containerHeight: CGFloat = 0
    @State private var safeAreaInsets: EdgeInsets = .init()
    @State private var contentHeight: CGFloat = 0
    @State private var isAdded = false

    private let animation = Animation.interpolatingSpring(stiffness: 300.0, damping: 30.0, initialVelocity: 10.0)

    var body: some View {
        let drag = DragGesture()
            .onChanged { value in
                dragState = .dragging(translation: value.translation)
            }
            .onEnded(onDragEnded)

        GeometryReader { containerGeometry in
            let maxHeight = containerGeometry.size.height - containerGeometry.safeAreaInsets.top - containerGeometry.safeAreaInsets.bottom

            ZStack {
                backgroundOverlay()
                VStack {
                    if !shouldBeCentered {
                        Spacer()
                    }

                    content(
                        SheetController(dismiss: {
                            dismiss()
                        })
                    )
                    .anchorPreference(key: ViewAnchorKey.self, value: .bounds) {
                        ViewAnchorData(size: containerGeometry[$0].size)
                    }
                    .frame(maxHeight: maxHeight, alignment: .bottom)
                    .offset(y: currentVerticalOffset())
                }
                .onPreferenceChange(ViewAnchorKey.self) { value in
                    containerHeight = containerGeometry.size.height
                    safeAreaInsets = containerGeometry.safeAreaInsets
                    contentHeight = value.size.height + safeAreaInsets.bottom
                }
                .gesture(drag)
            }
            .onAppear {
                withAnimation(animation) {
                    isAdded = true
                }
            }
        }
    }

    struct ViewAnchorKey: PreferenceKey {
        static var defaultValue: CustomSheet<Content>.ViewAnchorData {
            return ViewAnchorData(size: CGSize.zero)
        }

        static func reduce(value: inout ViewAnchorData, nextValue: () -> ViewAnchorData) {
            value.size = nextValue().size
        }
    }

    struct ViewAnchorData: Equatable {
        var size: CGSize
        static func == (_: ViewAnchorData, _: ViewAnchorData) -> Bool {
            return false
        }
    }

    enum DragState: Equatable {
        case inactive
        case dragging(translation: CGSize)

        var translation: CGSize {
            switch self {
                case .inactive:
                    return .zero
                case let .dragging(translation):
                    return translation
            }
        }
        
        var isDragging: Bool {
            switch self {
                case .inactive:
                    return false
                case .dragging:
                    return true
            }
        }
    }
}

private extension CustomSheet {
    func backgroundOverlay() -> some View {
        Spacer()
            .background(currentBackgroundColor())
            .edgesIgnoringSafeArea(.all)
            .onTapGesture {
                if !allowSwipeAndTapToDismiss {
                    return
                }
                dismiss()
            }
    }

    func currentBackgroundColor() -> Color {
        if !isAdded {
            return Color.clear
        }

        let progress = 1 - dragState.translation.height / min(contentHeight, containerHeight)
        return Color.black.opacity(
            0.6 * min(max(0, progress), 1)
        )
    }

    func currentVerticalOffset() -> CGFloat {
        if !isAdded {
            return contentHeight
        }

        let offsetDueToOverflow = max(0, contentHeight - containerHeight)
        return max(offsetDueToOverflow, dragState.translation.height + offsetDueToOverflow)
    }

    func onDragEnded(drag: DragGesture.Value) {
        let contentHeight = min(containerHeight, contentHeight)
        let dragThreshold = abs(contentHeight * 0.5)
        if
            allowSwipeAndTapToDismiss,
            drag.predictedEndTranslation.height > dragThreshold || drag.translation.height > dragThreshold
        {
            dismiss()
        } else {
            withAnimation(animation) {
                dragState = .inactive
            }
        }
    }

    func dismiss() {
        withAnimation(animation) {
            isAdded = false
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            isPresented = false
            onDismiss?()
        }
    }
}

private struct CustomSheetModifier<SheetContent: View>: ViewModifier {
    let customSheet: CustomSheet<SheetContent>
    let manager = CustomSheetManager.default

    func body(content: Content) -> some View {
        return content
            .onChange(of: customSheet.isPresented) { isPresented in
                var host = manager.customSheetHostController

                if isPresented {

                    if host == nil {
                        let hc = UIHostingController(rootView: AnyView(customSheet))
                        let animator = OverlayAnimator()
                        hc.modalPresentationStyle = .custom
                        hc.transitioningDelegate = animator

                        if let rootVC = UIApplication.shared.currentKeyWindow?.rootViewController {
                            manager.customSheetHostController = hc
                            hc.view.backgroundColor = UIColor.clear
                            rootVC.present(hc, animated: true)
                        }
                    }
                } else {
                    cleanUp()
                }
            }
    }

    func cleanUp() {
        let host = manager.customSheetHostController
        host?.dismiss(animated: false)
        manager.customSheetHostController = nil
    }
}

private class CustomSheetManager {
    private init() {}

    var customSheetHostController: UIHostingController<AnyView>?
    var animator: OverlayAnimator?

    static let `default` = CustomSheetManager()
}
