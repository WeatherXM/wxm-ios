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

extension ExplorerStationsListView {
	enum Pill: Hashable {
		case activeStations(String, ColorEnum)
		case stationsCount(String)
		case dataQualityScore(String, ColorEnum)
	}
}

private struct ContentView: View {
    @StateObject var viewModel: ExplorerStationsListViewModel
    @EnvironmentObject var navigationObject: NavigationObject
	@State private var titleViewSize: CGSize = .zero

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
						ProBannerView(description: LocalizableString.Promotional.getHyperlocalForecasts.localized,
									  analyticsSource: .localCell)
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
		GeometryReader { proxy in
			VStack(spacing: CGFloat(.mediumSpacing)) {
				if let address = viewModel.address {
					HStack {
						Text(address)
							.foregroundColor(Color(.text))
							.font(.system(size: CGFloat(.largeTitleFontSize), weight: .bold))

						Spacer()
					}
				}

				PillsView(items: viewModel.pills,
						  containerWidth: proxy.size.width) { pill in
					viewFor(pill: pill)
				}
				.id(viewModel.pills)
			}
			.sizeObserver(size: $titleViewSize)
		}
		.frame(height: titleViewSize.height)
		.padding(.horizontal, CGFloat(.defaultSidePadding))
		.padding(.bottom, CGFloat(.mediumSidePadding))
		.background(Color(colorEnum: .top))
		.cornerRadius(CGFloat(.cardCornerRadius),
					  corners: [.bottomLeft, .bottomRight])
	}

	@ViewBuilder
	func viewFor(pill: ExplorerStationsListView.Pill) -> some View {
		switch pill {
			case .activeStations(let text, let color):
				Text(text)
					.font(.system(size: CGFloat(.normalFontSize), weight: .medium))
					.foregroundColor(Color(colorEnum: .text))
					.lineLimit(1)
					.WXMCardStyle(backgroundColor: Color(colorEnum: color),
								  insideHorizontalPadding: CGFloat(.smallToMediumSidePadding),
								  insideVerticalPadding: CGFloat(.smallSidePadding),
								  cornerRadius: CGFloat(.buttonCornerRadius))
			case .stationsCount(let text):
				HStack(spacing: CGFloat(.smallSpacing)) {
					Text(text)
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
			case .dataQualityScore(let text, let color):
				HStack(spacing: CGFloat(.smallSpacing)) {
					Text(FontIcon.chartSimple.rawValue)
						.font(.fontAwesome(font: .FAProSolid, size: CGFloat(.mediumFontSize)))
						.foregroundStyle(Color(colorEnum: color))

					Text(text)
						.font(.system(size: CGFloat(.caption)))
						.foregroundStyle(Color(colorEnum: .text))
						.lineLimit(1)

					Button {
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
		}
	}
}

#Preview {
	let vm = ViewModelsFactory.getExplorerStationsListViewModel(cellIndex: "", cellCenter: CLLocationCoordinate2D())
	return ExplorerStationsListView(viewModel: vm)
}
