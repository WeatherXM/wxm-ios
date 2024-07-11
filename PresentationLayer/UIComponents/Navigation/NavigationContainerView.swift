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
    @Published var subtitle: String?
    @Published var titleColor = Color(colorEnum: .text)
    @Published var navigationBarColor: Color? = Color(colorEnum: .top)
    var shouldDismissAction: (() -> Bool)?
}

struct NavigationContainerView<Content: View, RightView: View>: View {
    @Environment(\.dismiss) private var dismiss
    private let content: Content
    private let rightView: RightView
    @StateObject private var navigationObject = NavigationObject()

    private let showBackButton: Bool

    init(showBackButton: Bool = true,
         @ViewBuilder rightView: () -> RightView = { EmptyView() },
         @ViewBuilder content: () -> Content) {
        self.showBackButton = showBackButton
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
                            Text(navigationObject.title)
                                .font(.system(size: CGFloat(.largeTitleFontSize)))
                                .lineLimit(1)
                                .truncationMode(.middle)
                                .foregroundColor(navigationObject.titleColor)

                            Spacer()
                        }

                        if let subtitle = navigationObject.subtitle {
                            HStack {
                                Text(subtitle)
                                    .font(.system(size: CGFloat(.largeFontSize)))
                                    .foregroundColor(navigationObject.titleColor)

                                Spacer()
                            }
                        }
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
        NavigationContainerView {
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
