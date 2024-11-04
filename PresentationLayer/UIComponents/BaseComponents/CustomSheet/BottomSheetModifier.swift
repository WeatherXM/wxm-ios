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
    let fitContent: Bool
    let content: () -> V
    @State private var hostingWrapper: HostingWrapper = HostingWrapper()
    @State private var contentSize: CGSize = .zero

	func body(content: Content) -> some View {
		content
			.sheet(isPresented: $show) {
				BottomSheetContainerView(contentSize: $contentSize,
										 fitContent: fitContent,
										 content: self.content)
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
	let fitContent: Bool
	let content: () -> V

	var body: some View {
		ZStack {
			Color(colorEnum: .bottomSheetBg)
				.ignoresSafeArea()

			content()
				.if(fitContent) { view in
					ScrollView {
						view
							.fixedSize(horizontal: false, vertical: true)
							.sizeObserver(size: $contentSize)
					}
					.scrollIndicators(.hidden)
					.padding(.top)
				}
		}
		.if(fitContent) { view in
			view
				.presentationDetents([.height(contentSize.height)])
		}
		.presentationDragIndicator(.visible)
	}
}

extension View {

    @ViewBuilder
    func bottomSheet<Content: View>(show: Binding<Bool>,
                                    fitContent: Bool = true,
                                    content: @escaping () -> Content) -> some View {
		modifier(BottomSheetModifier(show: show, fitContent: fitContent, content: content))
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
