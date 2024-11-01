//
//  BottomSheetModifier.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 29/5/23.
//

import SwiftUI
import Toolkit

struct BottomSheetModifier<V: View>: ViewModifier {
    @Binding var show: Bool
    var fitContent: Bool = false
    var initialDetentId: UISheetPresentationController.Detent.Identifier?
    let content: () -> V
    @State private var hostingWrapper: HostingWrapper = HostingWrapper()
    @State private var contentSize: CGSize = .zero

    func body(content: Content) -> some View {
        content
            .if(fitContent) { view in
                view.customSheet(isPresented: $show) { _ in
                    VStack {
                        Capsule()
                            .foregroundColor(Color(colorEnum: .layer2))
                            .frame(width: 40.0, height: 5.0)
                            .padding(.top)

                        self.content()
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .WXMCardStyle(
                        backgroundColor: Color(colorEnum: .layer1),
                        insideHorizontalPadding: 0,
                        insideVerticalPadding: 0
                    )
                }
            }
            .if(!fitContent) { view in
                view.onChange(of: show) { _ in
                    if show, hostingWrapper.hostingController == nil {
						let containerView = BottomSheetContainerView(contentSize: $contentSize, content: self.content)
                        let controller = BottomSheetHostingController(rootView: containerView)

						let customDetent: UISheetPresentationController.Detent = .custom { context in

							return contentSize.height
						}

						(controller.presentationController as? UISheetPresentationController)?.detents = [customDetent]

						/*
						 For some crazy reason the following line causes a memory leak in versions < iOS 17.
						 So the easiest and cleaner solution is to omit the grabber.
						 https://developer.apple.com/forums/thread/729183
						 */
						if #available(iOS 17.0, *) {
							(controller.presentationController as? UISheetPresentationController)?.prefersGrabberVisible = true
						}
                        
						controller.willDismissCallback = {
                            show = false
                        }
                        UIApplication.shared.topViewController?.present(controller, animated: true)
                        hostingWrapper.hostingController = controller
						controller.sheetPresentationController?.invalidateDetents()
                    } else if !show {
                        hostingWrapper.hostingController?.dismiss(animated: true)
                    }
                }
            }
			.onChange(of: contentSize) { _ in
				invalidateDetents()
			}
    }

    private class BottomSheetHostingController: UIHostingController<BottomSheetContainerView<V>> {

        var willDismissCallback: VoidCallback?

        override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)
            if isBeingDismissed {
                willDismissCallback?()
            }
        }
    }

	private func invalidateDetents() {
		(hostingWrapper.hostingController?.presentationController as? UISheetPresentationController)?.invalidateDetents()
	}
}

private struct BottomSheetContainerView<V: View>: View {
	@Binding var contentSize: CGSize
	let content: () -> V

	var body: some View {
		ZStack {
			Color(colorEnum: .layer1)
				.ignoresSafeArea()

			content()
				.fixedSize(horizontal: false, vertical: true)
				.sizeObserver(size: $contentSize)
		}
	}
}

extension View {

    @ViewBuilder
    func bottomSheet<Content: View>(show: Binding<Bool>,
                                    fitContent: Bool = false,
                                    initialDetentId: UISheetPresentationController.Detent.Identifier? = nil,
                                    content: @escaping () -> Content) -> some View {
        modifier(BottomSheetModifier(show: show, fitContent: fitContent, initialDetentId: initialDetentId, content: content))
    }

	@ViewBuilder
	func bottomInfoView(info: BottomSheetInfo?) -> some View {
		ZStack {
			Color(colorEnum: .bottomSheetBg)
				.ignoresSafeArea()

			VStack(spacing: CGFloat(.mediumSpacing)) {
				if let info = info {
					HStack {
						if let title = info.title {
							Text(title)
								.font(.system(size: CGFloat(.largeFontSize), weight: .bold))
								.foregroundColor(Color(colorEnum: .text))
						}

						Spacer()
					}

					HStack {
						Text(info.description?.attributedMarkdown ?? "")
							.font(.system(size: CGFloat(.mediumFontSize)))
							.foregroundColor(Color(colorEnum: .text))

						Spacer()
					}
					.modify { view in
						if info.scrollable == true {
							ScrollView(showsIndicators: false) {
								view
							}
						} else {
							view
						}
					}

					if let buttonTitle = info.buttonTitle, let buttonAction = info.buttonAction {
						Button(action: buttonAction) {
							Text(buttonTitle)
						}
						.buttonStyle(WXMButtonStyle.transparent(fillColor: .bottomSheetButton))
					}
				}
			}
			.padding(CGFloat(.largeSidePadding))
		}
		.onAppear {
			if let screen = info?.analyticsScreen {
				WXMAnalytics.shared.trackScreen(screen)
			}
		}
	}
}

struct BottomSheetInfo {
	let title: String?
	let description: String?
	var scrollable: Bool = false
	var analyticsScreen: Screen?
	var buttonTitle: String?
	var buttonAction: VoidCallback?
}
