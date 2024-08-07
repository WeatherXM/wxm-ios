//
//  StationDetailsContainerView.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 2/3/23.
//

import SwiftUI
import DomainLayer
import Toolkit

struct StationDetailsContainerView: View {
    @StateObject var viewModel: StationDetailsViewModel
    @State private var showSettingsPopOver: Bool = false

    var body: some View {
        NavigationContainerView {
            navigationBarRightView
        } content: {
            StationDetailsView(viewModel: viewModel)
        }
    }

    @ViewBuilder
    var navigationBarRightView: some View {
        HStack(spacing: CGFloat(.smallSidePadding)) {
            Button { [weak viewModel] in
                viewModel?.handleShareButtonTap()
            } label: {
                Text(FontIcon.share.rawValue)
                    .font(.fontAwesome(font: .FAProSolid, size: CGFloat(.mediumFontSize)))
                    .foregroundColor(Color(colorEnum: .wxmPrimary))
                    .frame(width: 30.0, height: 30.0)
            }
			.wxmShareDialog(show: $viewModel.showShareDialog, text: viewModel.shareDialogText ?? "")

            if viewModel.followState != nil {
                Button {
                    WXMAnalytics.shared.trackEvent(.userAction, parameters: [.actionName: .deviceDetailsPopUp])
                    showSettingsPopOver = true
                } label: {
                    Text(FontIcon.threeDots.rawValue)
                        .font(.fontAwesome(font: .FAProSolid, size: CGFloat(.mediumFontSize)))
                        .foregroundColor(Color(colorEnum: .wxmPrimary))
                        .frame(width: 30.0, height: 30.0)
                }
                .wxmPopOver(show: $showSettingsPopOver) {
					VStack {
						Button { [weak viewModel] in
							showSettingsPopOver = false
							viewModel?.settingsButtonTapped()
						} label: {
							Text(LocalizableString.settings.localized)
								.font(.system(size: CGFloat(.mediumFontSize)))
								.foregroundColor(Color(colorEnum: .text))
						}
					}
					.padding()
					.background(Color(colorEnum: .top).scaleEffect(2.0).ignoresSafeArea())
                }
            }
        }
    }

}

private struct StationDetailsView: View {
    @EnvironmentObject var navigationObject: NavigationObject
    @StateObject var viewModel: StationDetailsViewModel
    @State private var selectedIndex = 0
    @State private var titleViewSize: CGSize = .zero
    @State private var titleViewAddressSize: CGSize = .zero
    @State private var isHeaderHidden: Bool = false
	private let mainVM: MainScreenViewModel = .shared

    var body: some View {
        content
    }

    @ViewBuilder
    var content: some View {
        ZStack {
            Color(colorEnum: .bg)
                .ignoresSafeArea()

			ConditionalOSContainer {
				Group {
					titleView
						.padding(.horizontal, CGFloat(.mediumSidePadding))
						.background {
							Color(colorEnum: .top)
						}
						.cornerRadius(CGFloat(.cardCornerRadius),
									  corners: [.bottomLeft, .bottomRight])
						.background {
							// The following "hack" is to drop shadow only at the bottom of the view
							VStack {
								Spacer()
								Color(colorEnum: .top)
									.frame(height: 30.0)
									.cornerRadius(CGFloat(.cardCornerRadius),
												  corners: [.bottomLeft, .bottomRight])
									.wxmShadow()
							}
						}.zIndex(1)
						.offset(x: 0.0, y: isHeaderHidden ? -titleViewAddressSize.height : 0.0)
						.animation(.easeIn(duration: 0.15), value: isHeaderHidden)
						.sizeObserver(size: $titleViewSize)

					TabViewWrapper(selection: $selectedIndex) { [unowned viewModel] in
						ForEach(0..<StationDetailsViewModel.Tab.allCases.count, id: \.self) { [unowned viewModel] index in
							let tab = StationDetailsViewModel.Tab.allCases[index]
							switch tab {
								case .observations:
									ObservationsView(viewModel: viewModel.observationsVM)
										.tag(index)
										.conditionalOSsafeAreaTopInset(titleViewSize.height)
								case .forecast:
									StationForecastView(viewModel: viewModel.forecastVM)
										.tag(index)
										.conditionalOSsafeAreaTopInset(titleViewSize.height)
								case .rewards:
									StationRewardsView(viewModel: viewModel.rewardsVM)
										.tag(index)
										.conditionalOSsafeAreaTopInset(titleViewSize.height)
							}
						}
					}
					.tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
					.indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .never))
					.zIndex(0)
					.animation(.easeOut(duration: 0.3), value: selectedIndex)
				}
			}
        }
        .wxmAlert(show: $viewModel.showLoginAlert) {
            WXMAlertView(show: $viewModel.showLoginAlert,
                         configuration: viewModel.loginAlertConfiguration!) {
                Button {
                    viewModel.signupButtonTapped()
                } label: {
                    HStack {
                        Text(LocalizableString.dontHaveAccount.localized)
                            .font(.system(size: CGFloat(.normalFontSize), weight: .bold))
                            .foregroundColor(Color(colorEnum: .text))

                        Text(LocalizableString.signUp.localized.uppercased())
                            .font(.system(size: CGFloat(.normalFontSize)))
                            .foregroundColor(Color(colorEnum: .wxmPrimary))
                    }
                }
            }
        }
        .onAppear {
            navigationObject.titleColor = Color(colorEnum: .wxmPrimary)
            navigationObject.navigationBarColor = Color(colorEnum: .top)
        }
        .onChange(of: selectedIndex) { _ in
            withAnimation {
                isHeaderHidden = false
            }
        }
        .onChange(of: viewModel.shouldHideHeaderToggle) { _ in
            isHeaderHidden = viewModel.isHeaderHidden
        }
        .onChange(of: isHeaderHidden) { newValue in
            withAnimation {
                navigationObject.title = newValue ? viewModel.device?.displayName ?? "" : ""
            }
        }
    }

    @ViewBuilder
    var titleView: some View {
        if let device = viewModel.device {
            VStack {
                StationAddressTitleView(device: device,
                                        followState: viewModel.followState,
										issues: viewModel.issues,
                                        showStateIcon: true,
                                        tapStateIconAction: { viewModel.followButtonTapped()},
                                        tapAddressAction: { viewModel.addressTapped() },
										tapWarningAction: { viewModel.warningTapped() },
										tapStatusAction: { viewModel.statusTapped() })
                .sizeObserver(size: $titleViewAddressSize)

                CustomSegmentView(options: StationDetailsViewModel.Tab.allCases.map { $0.description },
                                  selectedIndex: $selectedIndex,
                                  style: .plain)
				.iPadMaxWidth()
            }
        } else {
            EmptyView()
        }
    }
}

/// Container for different layout according to iOS version
private struct ConditionalOSContainer<Content: View>: View {
	let content: () -> Content

	var body: some View {
		if #available(iOS 16.0, *) {
			ZStack(alignment: .top) {
				content()
			}
		} else {
			VStack(spacing: CGFloat(.smallSidePadding)) {
				content()
			}
		}
	}
}

/// Modify safe area inset according to iOS version
private struct SafeAreaInsetModifier: ViewModifier {
	let inset: CGFloat

	func body(content: Content) -> some View {
		if #available(iOS 16.0, *) {
			content
				.safeAreaInset(edge: .top) {
					Spacer()
						.frame(height: inset)
				}
		} else {
			content
		}
	}
}

private extension View {
	func conditionalOSsafeAreaTopInset(_ inset: CGFloat) -> some View {
		modifier(SafeAreaInsetModifier(inset: inset))
	}
}

struct StationDetailsContainerView_Previews: PreviewProvider {
    static var previews: some View {
        return StationDetailsContainerView(viewModel: StationDetailsViewModel.mockInstance)
    }
}
