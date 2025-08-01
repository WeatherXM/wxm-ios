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
		ScrollView {
			VStack(spacing: CGFloat(.mediumSpacing)) {
				currentLocation

				savedLocations
			}
			.padding(CGFloat(.mediumSidePadding))
		}
		.scrollIndicators(.hidden)
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
		}
	}
}

#Preview {
	ZStack {
		Color(colorEnum: .bg)
		HomeView(viewModel: ViewModelsFactory.getHomeViewModel())
	}
}
