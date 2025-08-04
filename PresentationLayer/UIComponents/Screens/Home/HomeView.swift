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
				TrackableScroller { completion in
					viewModel.refresh(completion: completion)
				} content: {
					VStack(spacing: CGFloat(.mediumSpacing)) {
						searchBar

						currentLocation

						savedLocations
					}
					.padding(CGFloat(.mediumSidePadding))
				}
				.scrollIndicators(.hidden)
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
	var searchBar: some View {
		Button {
			viewModel.handleSearchBarTap()
		} label: {
			HStack(spacing: CGFloat(.minimumSpacing)) {
				Text(FontIcon.magnifyingGlass.rawValue)
					.font(.fontAwesome(font: .FAProSolid, size: CGFloat(.mediumFontSize)))
					.foregroundStyle(Color(colorEnum: .darkGrey))

				Text(LocalizableString.Home.searchPlaceholder.localized)
					.font(.system(size: CGFloat(.normalFontSize)))

				Spacer()
			}
			.padding(CGFloat(.smallToMediumSidePadding))
			.background {
				Capsule()
					.fill(Color(colorEnum: .top))
			}
			.overlay {
				Capsule()
					.stroke(Color(colorEnum: .darkGrey), lineWidth: 1.0)
			}
		}
		.buttonStyle(.plain)
	}

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
		}
	}
}

#Preview {
	ZStack {
		Color(colorEnum: .bg)
		HomeView(viewModel: ViewModelsFactory.getHomeViewModel())
	}
}
