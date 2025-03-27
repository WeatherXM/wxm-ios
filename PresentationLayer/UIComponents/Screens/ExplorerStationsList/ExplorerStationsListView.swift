//
//  ExplorerStationsListView.swift
//  PresentationLayer
//
//  Created by Lampros Zouloumis on 22/8/22.
//

import SwiftUI
import Toolkit
import MapKit

struct ExplorerStationsListView: View {
	@StateObject var viewModel: ExplorerStationsListViewModel
	@State private var showShareDialog: Bool = false

	var body: some View {
		NavigationContainerView {
			navigationBarRightView
		} content: {
			ContentView(viewModel: viewModel)
		}
	}

	@ViewBuilder
	var navigationBarRightView: some View {
		HStack(spacing: CGFloat(.smallSidePadding)) {
			Button {
				showShareDialog = true
			} label: {
				Text(FontIcon.share.rawValue)
					.font(.fontAwesome(font: .FAProSolid, size: CGFloat(.mediumFontSize)))
					.foregroundColor(Color(colorEnum: .wxmPrimary))
					.frame(width: 30.0, height: 30.0)
			}
			.wxmShareDialog(show: $showShareDialog, text: viewModel.cellShareUrl)
		}
	}
}

private struct ContentView: View {
    @StateObject var viewModel: ExplorerStationsListViewModel
    @EnvironmentObject var navigationObject: NavigationObject
    
    var body: some View {
        ZStack {
            Color(colorEnum: .layer2)
                .ignoresSafeArea()

			VStack(spacing: 0.0) {
				titleView
					.wxmShadow()
					.zIndex(1)


				ScrollView {
					VStack(spacing: 0.0) {
						ProBannerView(description: LocalizableString.Promotional.getHyperlocalForecasts.localized)
							.padding(.top, CGFloat(.defaultSpacing))
							.padding(.horizontal, CGFloat(.defaultSpacing))

						AdaptiveGridContainerView {

							ForEach(viewModel.devices) { device in
								WeatherStationCard(device: device,
												   followState: viewModel.getFollowState(for: device),
												   followAction: { viewModel.followButtonTapped(device: device) })
								.onTapGesture {
									viewModel.navigateToDeviceDetails(device)
								}
							}
						}
						.padding(CGFloat(.defaultSpacing))
					}
                }
				.scrollIndicators(.hidden)
				.zIndex(0)
                .spinningLoader(show: $viewModel.isLoadingDeviceList, hideContent: true)
                .fail(show: $viewModel.isDeviceListFailVisible, obj: viewModel.deviceListFailObject)
                .wxmAlert(show: $viewModel.showLoginAlert) {
                    WXMAlertView(show: $viewModel.showLoginAlert,
                                 configuration: viewModel.alertConfiguration!) {
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
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            navigationObject.navigationBarColor = Color(colorEnum: .top)

            WXMAnalytics.shared.trackScreen(.explorerCell,
                                      parameters: [.itemId: .custom(viewModel.cellIndex)])
        }
		.bottomSheet(show: $viewModel.showInfo) {
			bottomInfoView(info: viewModel.info)
		}
    }
}

private extension ContentView {
	@ViewBuilder var titleView: some View {
		VStack(spacing: CGFloat(.mediumSpacing)) {
			if let address = viewModel.address {
				HStack {
					Text(address)
						.foregroundColor(Color(.text))
						.font(.system(size: CGFloat(.largeTitleFontSize), weight: .bold))

					Spacer()
				}
			}

			HStack(spacing: CGFloat(.minimumSpacing)) {
				if let activeStationsString = viewModel.activeStationsString {
					HStack(spacing: CGFloat(.smallSpacing)) {
						Text(activeStationsString)
							.font(.system(size: CGFloat(.normalFontSize), weight: .medium))
							.foregroundColor(Color(colorEnum: .text))
							.lineLimit(1)
					}
					.WXMCardStyle(backgroundColor: Color(colorEnum: .successTint),
								  insideHorizontalPadding: CGFloat(.smallToMediumSidePadding),
								  insideVerticalPadding: CGFloat(.smallSidePadding),
								  cornerRadius: CGFloat(.buttonCornerRadius))
				}

				HStack(spacing: CGFloat(.smallSpacing)) {
					Text(viewModel.stationsCountString)
						.font(.system(size: CGFloat(.normalFontSize), weight: .medium))
						.foregroundColor(Color(colorEnum: .text))
						.lineLimit(1)

					Button {
						viewModel.handleCellCapacityInfoTap()
					} label: {
						Text(FontIcon.infoCircle.rawValue)
							.font(.fontAwesome(font: .FAPro, size: CGFloat(.mediumFontSize)))
							.foregroundColor(Color(colorEnum: .text))
					}

				}
				.WXMCardStyle(backgroundColor: Color(colorEnum: .blueTint),
							  insideHorizontalPadding: CGFloat(.smallToMediumSidePadding),
							  insideVerticalPadding: CGFloat(.smallSidePadding),
							  cornerRadius: CGFloat(.buttonCornerRadius))

				Spacer()
			}
		}
		.padding(.horizontal, CGFloat(.defaultSidePadding))
		.padding(.bottom, CGFloat(.mediumSidePadding))
		.background(Color(colorEnum: .top))
		.cornerRadius(CGFloat(.cardCornerRadius),
					  corners: [.bottomLeft, .bottomRight])
	}
}

#Preview {
	let vm = ViewModelsFactory.getExplorerStationsListViewModel(cellIndex: "", cellCenter: CLLocationCoordinate2D())
	return ExplorerStationsListView(viewModel: vm)
}
