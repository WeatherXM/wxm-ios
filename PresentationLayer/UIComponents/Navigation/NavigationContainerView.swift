//
//  NavigatationContainerView.swift
//  PresentationLayer
//
//  Created by Pantelis Giazitsis on 14/2/23.
//

import SwiftUI
import Toolkit

class NavigationObject: ObservableObject {
    @Published var title = ""
	var areTitlesCopyable: Bool = false
    @Published var subtitle: String?
    @Published var titleColor = Color(colorEnum: .text)
	@Published var titleFont = Font.system(size: CGFloat(.largeTitleFontSize))
	@Published var subtitleColor = Color(colorEnum: .darkGrey)
	@Published var subtitleFont = Font.system(size: CGFloat(.largeFontSize))
    @Published var navigationBarColor: Color? = Color(colorEnum: .top)
    var shouldDismissAction: (() -> Bool)?

	func setNavigationTitle(_ navigationTitle: NavigationTitle) {
		self.title = navigationTitle.title ?? ""
		self.subtitle = navigationTitle.subtitle
	}
}

extension NavigationObject {
	struct NavigationTitle: Equatable {
		let title: String?
		let subtitle: String?
	}
}

struct NavigationContainerView<Content: View, RightView: View>: View {
    @Environment(\.dismiss) private var dismiss
    private let content: Content
    private let rightView: RightView
    @StateObject private var navigationObject = NavigationObject()

    private let showBackButton: Bool
	private let titleImage: AssetEnum?

    init(showBackButton: Bool = true,
		 titleImage: AssetEnum? = nil,
         @ViewBuilder rightView: () -> RightView = { EmptyView() },
         @ViewBuilder content: () -> Content) {
        self.showBackButton = showBackButton
		self.titleImage = titleImage
        self.content = content()
        self.rightView = rightView()
    }

    var body: some View {
        VStack(spacing: 0.0) {
            navbar
                .zIndex(100)

            content
                .environmentObject(navigationObject)
        }
        .navigationBarHidden(true)
    }
}

private extension NavigationContainerView {
    @ViewBuilder
    var navbar: some View {
        ZStack {
            HStack(spacing: CGFloat(.mediumSpacing)) {
                if showBackButton {
					Button {
						if navigationObject.shouldDismissAction?() ?? true {
							dismiss()
						}
                    } label: {
                        Image(asset: .backArrow)
                            .renderingMode(.template)
                            .foregroundColor(Color(colorEnum: .wxmPrimary))
                    }
                }

                HStack(spacing: CGFloat(.minimumSpacing)) {

                    VStack {
                        HStack {
							if let titleImage {
								Image(asset: titleImage)
							}
							
                            Text(navigationObject.title)
								.font(navigationObject.titleFont)
                                .lineLimit(1)
                                .truncationMode(.middle)
                                .foregroundColor(navigationObject.titleColor)

                            Spacer()
                        }

                        if let subtitle = navigationObject.subtitle {
                            HStack {
                                Text(subtitle)
									.font(navigationObject.subtitleFont)
                                    .foregroundColor(navigationObject.subtitleColor)

                                Spacer()
                            }
                        }
                    }
					.if(navigationObject.areTitlesCopyable) { view in
						view
							.textSelection(.enabled)
							.allowsHitTesting(true)
					}

                    Spacer()

                    rightView
                }
            }
            .padding(CGFloat(.mediumSidePadding))
        }
        .background {
            if let color = navigationObject.navigationBarColor {
                color
                    .ignoresSafeArea()
            }
        }
    }
}

struct NavigationContainerView_Previews: PreviewProvider {
    static var previews: some View {
		NavigationContainerView(titleImage: .wxmNavigationLogo) {
            Button {
            } label: {
                Text(FontIcon.calendar.rawValue)
                    .font(.fontAwesome(font: .FAProSolid, size: CGFloat(.mediumFontSize)))
                    .foregroundColor(Color(colorEnum: .wxmPrimary))
                    .frame(width: 30.0, height: 30.0)
            }

        } content: {
            TestView()
        }
    }

    struct TestView: View {
        @EnvironmentObject var navigationObject: NavigationObject

        var body: some View {
            Text(verbatim: "hellozzz")
                .onAppear {
                    navigationObject.title = "Test title here! Long long text"
                }
        }
    }
}
