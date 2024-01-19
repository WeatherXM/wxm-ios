//
//  SuccessfulDeleteView.swift
//  PresentationLayer
//
//  Created by Panagiotis Palamidas on 25/10/22.
//

import SwiftUI

struct SuccessfulDeleteView: View {
    @EnvironmentObject var viewModel: DeleteAccountViewModel
	private let mainScreenViewModel: MainScreenViewModel = .shared

    let userID: String

    var body: some View {
        ZStack {
            VStack {
                Image("DeleteSuccessIcon")
                successInfo
            }
            navigationButtons
        }
        .padding(.horizontal)
        .navigationBarBackButtonHidden(true)
    }

    @ViewBuilder
    var successInfo: some View {
        successTitle
        successText
    }

    var successTitle: some View {
        Text(LocalizableString.DeleteAccount.successfulTitle.localized)
            .font(.system(size: CGFloat(.largeFontSize), weight: .bold))
            .foregroundColor(Color(colorEnum: .text))
            .bold()
            .padding(.top, 20)
    }

    var successText: some View {
        Text(LocalizableString.DeleteAccount.successfulText.localized)
            .foregroundColor(Color(colorEnum: .text))
            .font(.system(size: CGFloat(.normalFontSize)))
            .multilineTextAlignment(.center)
            .padding(.top, 20)
            .padding(.horizontal, 20)
    }

    var navigationButtons: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                goToSignInButton
                Spacer()
                goToSurveyButton
                Spacer()
            }
            .padding(.bottom, 20)
        }
    }

    var goToSignInButton: some View {
		Button {
			mainScreenViewModel.selectedTab = .homeTab
			mainScreenViewModel.isUserLoggedIn = false
			Router.shared.popToRoot()
		} label: {
            goToSignInButtonStyle
        }
        .buttonStyle(WXMButtonStyle())
    }

    var goToSignInButtonStyle: some View {
        Text(LocalizableString.finish.localized)
    }

    var goToSurveyButton: some View {
        Button {
            Router.shared.navigateTo(.survey(userID, viewModel.getClientIndentifier()))
        } label: {
            goToSurveyButtonStyle
        }
        .buttonStyle(WXMButtonStyle.filled())
    }

    var goToSurveyButtonStyle: some View {
        Text(LocalizableString.DeleteAccount.takeSurveyText.localized)
    }
}

struct Previews_SuccessfulDeleteView_Previews: PreviewProvider {
    static var previews: some View {
        SuccessfulDeleteView(userID: "")
            .environmentObject(ViewModelsFactory.getDeleteAccountViewModel(userId: ""))
    }
}
