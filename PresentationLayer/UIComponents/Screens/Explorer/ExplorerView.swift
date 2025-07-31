//
//  ExplorerView.swift
//  PresentationLayer
//
//  Created by Danae Kikue Dimou on 12/5/22.
//

import SwiftUI
import Toolkit

struct ExplorerView: View {
    @StateObject var viewModel: ExplorerViewModel

    let settingsDotsDimensions: CGFloat = 60

    var body: some View {
        ZStack {
			MapBoxMapView()
                .environmentObject(viewModel)
                .edgesIgnoringSafeArea(.all)
            explorerContent
                .zIndex(1)

            if viewModel.showTopOfMapItems {
				SearchView(shouldShowSettingsButton: !MainScreenViewModel.shared.isUserLoggedIn,
                           viewModel: viewModel.searchViewModel)
                .transition(AnyTransition.opacity.animation(.easeIn))
                .zIndex(2)
            }

        }
        .navigationTitle(Text(LocalizableString.explorerViewTitle.localized))
        .navigationBarHidden(true)
        .onAppear {
            WXMAnalytics.shared.trackScreen(.explorerLanding)
            viewModel.showTopOfMapItems = true
        }
		.shimmerLoader(show: $viewModel.isLoading, horizontalPadding: CGFloat(.defaultSidePadding))
		.bottomSheet(show: $viewModel.showLayerPicker, bgColor: .top) {
			ExplorerLayerPickerView(show: $viewModel.showLayerPicker,
									selectedOption: $viewModel.layerOption)
			.padding(.top, CGFloat(.XLSidePadding))
			.padding(.horizontal, CGFloat((.mediumSidePadding)))
		}
    }

    var explorerContent: some View {
        VStack(spacing: CGFloat(.defaultSidePadding)) {
            if viewModel.showTopOfMapItems {
                Spacer()

                VStack(spacing: CGFloat(.defaultSpacing)) {
					HStack {
						Spacer()
						layersButton
					}

                    HStack {
                        Spacer()
                        userLocationButton
                    }
                }
                .transition(AnyTransition.move(edge: .trailing))
            }
        }
        .padding(CGFloat(.defaultSidePadding))
		.animation(.easeIn, value: viewModel.showTopOfMapItems)
    }

    @ViewBuilder
    var netStatsButton: some View {
        Button {
            Router.shared.navigateTo(.netStats(ViewModelsFactory.getNetworkStatsViewModel()))
        } label: {
            Image(asset: .networkStatsIcon)
                .renderingMode(.template)
                .foregroundColor(Color(colorEnum: .netStatsFabTextColor))
                .padding(CGFloat(.smallSidePadding))
                .background(Color(colorEnum: .netStatsFabColor))
                .cornerRadius(CGFloat(.cardCornerRadius))
        }
        .wxmShadow()
    }

    @ViewBuilder
    var userLocationButton: some View {
        Button {
            viewModel.userLocationButtonTapped()
        } label: {
            Image(asset: .detectLocation)
                .renderingMode(.template)
                .foregroundColor(Color(colorEnum: .text))
				.frame(width: CGFloat(.fabButtonsDimension), height: CGFloat(.fabButtonsDimension))
				.background(Circle().foregroundColor(Color(colorEnum: .top)))
        }
        .wxmShadow()
    }

	@ViewBuilder
	var layersButton: some View {
		Button {
			viewModel.layersButtonTapped()
		} label: {
			Image(asset: .iconLayers)
				.renderingMode(.template)
				.foregroundStyle(Color(colorEnum: .layer1))
				.frame(width: CGFloat(.fabButtonsDimension), height: CGFloat(.fabButtonsDimension))
				.background(Color(colorEnum: .wxmPrimary))
				.cornerRadius(CGFloat(.cardCornerRadius))
		}
		.wxmShadow()
	}
}

#Preview {
	ExplorerView(viewModel: ViewModelsFactory.getExplorerViewModel())
}
