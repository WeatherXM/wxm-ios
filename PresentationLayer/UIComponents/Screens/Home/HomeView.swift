//
//  HomeView.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 1/8/25.
//

import SwiftUI

struct HomeView: View {
	@StateObject var viewModel: HomeViewModel

    var body: some View {
		ZStack {
			NavigationContainerView(showBackButton: false, titleImage: .wxmNavigationLogo) {
				navigationBarRightView
			} content: {
				VStack(spacing: 0.0) {
					if viewModel.isFailed {
						infoBannerView
					}
					
					ZStack {
						TrackableScroller(offsetObject: viewModel.scrollOffsetObject) { completion in
							viewModel.refresh(completion: completion)
						} content: {
							VStack(spacing: 0.0) {
								infoBannerView

								VStack(spacing: CGFloat(.mediumSpacing)) {
									if let announcement = viewModel.announcementConfiguration {
										AnnouncementCardView(configuration: announcement)
									}

									currentLocation

									savedLocations
								}
								.padding(CGFloat(.mediumSidePadding))
							}
						}
						.scrollIndicators(.hidden)

						searchButton
					}
					.spinningLoader(show: $viewModel.isLoading, hideContent: true)
					.fail(show: $viewModel.isFailed, obj: viewModel.failObj)
				}
			}

			SearchView(viewModel: viewModel.searchViewModel, showNoActiveView: false)
		}
    }

	@ViewBuilder
	var navigationBarRightView: some View {
		StationRewardsChipView(viewModel: viewModel.stationChipsViewModel)
	}
}

private extension HomeView {
	@ViewBuilder
	var currentLocation: some View {
		VStack(spacing: CGFloat(.mediumSpacing)) {
			HStack(spacing: CGFloat(.smallSpacing)) {
				Text(FontIcon.locationCrosshairs.rawValue)
					.font(.fontAwesome(font: .FAProSolid, size: CGFloat(.largeFontSize)))
					.foregroundStyle(Color(colorEnum: .text))

				Text(LocalizableString.Home.currentLocation.localized)
					.font(.system(size: CGFloat(.largeFontSize), weight: .bold))
					.foregroundStyle(Color(colorEnum: .text))

				Spacer()
			}

			Button {
				viewModel.handleCurrentLocationTap()
			} label: {
				switch viewModel.currentLocationState {
					case .allowLocation:
						HomeLocationPermissionView()
					case .forecast(let forecast):
						HomeForecastView(forecast: forecast)
					case .empty:
						EmptyView()
				}
			}
		}
	}

	@ViewBuilder
	var savedLocations: some View {
		VStack(spacing: CGFloat(.mediumSpacing)) {
			HStack(spacing: CGFloat(.smallSpacing)) {
				Text(FontIcon.locationDot.rawValue)
					.font(.fontAwesome(font: .FAProSolid, size: CGFloat(.largeFontSize)))
					.foregroundStyle(Color(colorEnum: .text))

				Text(LocalizableString.Home.savedLocations.localized)
					.font(.system(size: CGFloat(.largeFontSize), weight: .bold))
					.foregroundStyle(Color(colorEnum: .text))

				Spacer()
			}

			switch viewModel.savedLocationsState {
				case .empty:
					savedLocationsEmpty
				case .forecasts(let forecasts):
					savedLocationsList(forecasts)
			}
		}
	}

	@ViewBuilder
	var savedLocationsEmpty: some View {
		HStack {
			Spacer()

			VStack(spacing: CGFloat(.smallSpacing)) {
				Text(FontIcon.star.rawValue)
					.font(.fontAwesome(font: .FAProSolid, size: CGFloat(.mediumFontSize)))
					.foregroundStyle(Color(colorEnum: .wxmPrimary))

				Text(LocalizableString.Home.savedLocationsEmptyTitle.localized)
					.font(.system(size: CGFloat(.normalFontSize), weight: .bold))
					.foregroundStyle(Color(colorEnum: .text))

				Text(LocalizableString.Home.savedLocationsEmptyDescription.localized)
					.font(.system(size: CGFloat(.caption)))
					.foregroundStyle(Color(colorEnum: .darkGrey))
					.multilineTextAlignment(.center)
			}

			Spacer()
		}
		.padding(.vertical, CGFloat(.mediumSidePadding))
		.padding(.horizontal, CGFloat(.largeSidePadding))
		.overlay {
			RoundedRectangle(cornerRadius: CGFloat(.cardCornerRadius))
				.stroke(Color(colorEnum: .top), style: StrokeStyle(lineWidth: 2, dash: [4, 4]))
		}
	}

	@ViewBuilder
	func savedLocationsList(_ forecasts: [LocationForecast]) -> some View {
		VStack(spacing: CGFloat(.mediumSpacing)) {
			ForEach(forecasts) { forecast in
				Button {
					viewModel.handleTapOn(locationForecast: forecast)
				} label: {
					HomeForecastView(forecast: forecast)
				}
			}
		}
	}

	@ViewBuilder
	var searchButton: some View {
		VStack {
			Spacer()

			HStack {
				Spacer()
				Button {
					viewModel.handleSearchButtonTap()
				} label: {
					Text(FontIcon.magnifyingGlass.rawValue)
						.font(.fontAwesome(font: .FAPro, size: CGFloat(.largeTitleFontSize)))
						.foregroundStyle(Color(colorEnum: .top))
				}
				.frame(width: CGFloat(.fabButtonsDimension), height: CGFloat(.fabButtonsDimension))
				.background(Color(colorEnum: .wxmPrimary))
				.cornerRadius(CGFloat(.cardCornerRadius))
				.shadow(radius: ShadowEnum.addButton.radius, x: ShadowEnum.addButton.xVal, y: ShadowEnum.addButton.yVal)
			}
		}
		.padding(CGFloat(.defaultSidePadding))
		.opacity(viewModel.isSearchButtonVisible ? 1.0 : 0.0)
		.animation(.easeIn(duration: 0.2), value: viewModel.isSearchButtonVisible)
	}

	@ViewBuilder
	var infoBannerView: some View {
		if let infoBanner = viewModel.infoBanner {
			VStack(spacing: 0.0) {
				InfoBannerView(infoBanner: infoBanner) {
					viewModel.handleInfoBannerDismissTap()
				} tapUrlAction: { url in
					viewModel.handleInfoBannerActionTap(url: url)
				}
				.padding(CGFloat(.defaultSidePadding))

				Color(colorEnum: .bg)
					.frame(height: CGFloat(.cardCornerRadius))
					.cornerRadius(CGFloat(.cardCornerRadius),
								  corners: [.topLeft, .topRight])

			}
			.background(Color(colorEnum: .layer1))
		}
	}
}

#Preview {
	ZStack {
		Color(colorEnum: .bg)
		HomeView(viewModel: ViewModelsFactory.getHomeViewModel())
	}
}
