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
			MapBoxMapView(controlsBottomOffset: .constant(0.0))
                .environmentObject(viewModel)
                .edgesIgnoringSafeArea(.all)
            explorerContent
                .zIndex(1)

            if viewModel.showTopOfMapItems {
                SearchView(shouldShowSettingsButton: true,
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
    }

    var explorerContent: some View {
        VStack(spacing: CGFloat(.defaultSidePadding)) {
            if viewModel.showTopOfMapItems {
                Spacer()

                VStack(spacing: CGFloat(.defaultSpacing)) {
                    HStack {
                        Spacer()
                        userLocationButton
                    }

                    HStack {
                        Spacer()
                        netStatsButton
                    }
                }
                .transition(AnyTransition.move(edge: .trailing))

                signInContainer
            }
        }
        .padding(CGFloat(.defaultSidePadding))
		.animation(.easeIn, value: viewModel.showTopOfMapItems)
    }

    var signInContainer: some View {
        VStack(spacing: CGFloat(.defaultSpacing)) {
            signInButton
            signUpTextButton
        }
        .WXMCardStyle()
		.iPadMaxWidth()
        .padding(.bottom, CGFloat(.mediumSidePadding))
        .transition(.move(edge: .bottom))
    }

    var signInButton: some View {
        Button {
            Router.shared.navigateTo(.signIn(ViewModelsFactory.getSignInViewModel()))
        } label: {
            Text(LocalizableString.signIn.localized)
        }
        .buttonStyle(WXMButtonStyle.filled())
    }

    var signUpTextButton: some View {
        Button {
            Router.shared.navigateTo(.register(ViewModelsFactory.getRegisterViewModel()))
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
                .padding(CGFloat(.smallSidePadding))
                .background(Circle().foregroundColor(Color(colorEnum: .top)))
        }
        .wxmShadow()
    }
}

#Preview {
	ExplorerView(viewModel: ViewModelsFactory.getExplorerViewModel())
}
