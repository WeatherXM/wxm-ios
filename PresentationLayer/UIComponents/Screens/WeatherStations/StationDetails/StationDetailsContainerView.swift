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
		HStack(spacing: CGFloat(.smallSpacing)) {
			if viewModel.device != nil {
				StationStatusButton(followState: viewModel.followState) {
					viewModel.statusButtonTapped()
				}
			}

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
					VStack(alignment:.leading, spacing: CGFloat(.mediumSpacing)) {
						Button { [weak viewModel] in
							showSettingsPopOver = false
							viewModel?.handleShareButtonTap()
						} label: {
							Text(LocalizableString.share.localized)
								.font(.system(size: CGFloat(.mediumFontSize)))
								.foregroundColor(Color(colorEnum: .text))
						}

						if viewModel.followState != nil {
							Button { [weak viewModel] in
								showSettingsPopOver = false
								viewModel?.settingsButtonTapped()
							} label: {
								Text(LocalizableString.DeviceInfo.title.localized)
									.font(.system(size: CGFloat(.mediumFontSize)))
									.foregroundColor(Color(colorEnum: .text))
							}
						}

						if viewModel.followState?.relation == .owned {
							Button { [weak viewModel] in
								showSettingsPopOver = false
								viewModel?.notificationsButtonTapped()
							} label: {
								Text(LocalizableString.StationDetails.notifications.localized)
									.font(.system(size: CGFloat(.mediumFontSize)))
									.foregroundColor(Color(colorEnum: .text))
							}
						}
					}
					.padding()
					.background(Color(colorEnum: .top).scaleEffect(2.0).ignoresSafeArea())
				}
			} else {
				Button { [weak viewModel] in
					viewModel?.handleShareButtonTap()
				} label: {
					Text(FontIcon.share.rawValue)
						.font(.fontAwesome(font: .FAProSolid, size: CGFloat(.mediumFontSize)))
						.foregroundColor(Color(colorEnum: .wxmPrimary))
						.frame(width: 30.0, height: 30.0)
				}
			}
		}
		.wxmShareDialog(show: $viewModel.showShareDialog, text: viewModel.shareDialogText ?? "")
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
								case .overview:
									OverviewView(viewModel: viewModel.overviewVM)
										.tag(index)
										.conditionalOSsafeAreaTopInset(titleViewSize.height)
								case .forecast:
									StationForecastView(viewModel: viewModel.forecastVM)
										.tag(index)
										.conditionalOSsafeAreaTopInset(titleViewSize.height)
										.clipped()
									// Apply this modifier to clip the horizontal scroller (Hourly) of the forecast view.
									// Not the best solution but the cleaner.
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
            navigationObject.navigationBarColor = Color(colorEnum: .top)
			navigationObject.titleFont = .system(size: CGFloat(.smallTitleFontSize), weight: .bold)
			navigationObject.subtitleFont = .system(size: CGFloat(.caption))
			viewModel.viewAppeared()
        }
        .onChange(of: selectedIndex) { index in
            withAnimation {
                isHeaderHidden = false
            }

			viewModel.trackScreenViewEvent(for: index)
        }
        .onChange(of: viewModel.shouldHideHeaderToggle) { _ in
            isHeaderHidden = viewModel.isHeaderHidden
        }
		.onChange(of: viewModel.navigationTitle) { newValue in
			guard let newValue else {
				return
			}
            withAnimation {
				navigationObject.setNavigationTitle(newValue)
            }
        }
		.task {
			viewModel.trackScreenViewEvent(for: selectedIndex)
		}
    }

    @ViewBuilder
    var titleView: some View {
        if let device = viewModel.device {
            VStack {
				StationChipsView(device: device, issues: viewModel.issues,
								 isScrollable: true,
								 warningAction: { viewModel.warningTapped() })
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
