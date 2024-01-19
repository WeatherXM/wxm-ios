//
//  SignInView.swift
//  PresentationLayer
//
//  Created by Danae Kikue Dimou on 16/5/22.
//

import SwiftUI
import Toolkit

struct SignInView: View {
	private let mainScreenVM: MainScreenViewModel = .shared
    @StateObject var viewModel: SignInViewModel

    var body: some View {
        VStack {
            loginContainer
        }
        .padding(.top, CGFloat(.largeSidePadding))
        .padding(.bottom, CGFloat(.defaultSidePadding))
        .padding(.horizontal, CGFloat(.defaultSidePadding))
        .onChange(of: viewModel.password, perform: { _ in
            viewModel.checkSignInButtonAvailability()
        })
        .onChange(of: viewModel.email, perform: { _ in
            viewModel.checkSignInButtonAvailability()
        })
        .navigationBarTitle(Text(LocalizableString.signIn.localized), displayMode: .large)
        .onAppear {
            Logger.shared.trackScreen(.login)
        }
    }

    var loginContainer: some View {
        VStack(spacing: CGFloat(.largeSpacing)) {
            containerTitle
            VStack(spacing: CGFloat(.smallSpacing)) {
                signInTextFields
                forgotPasswordButton
            }
            Spacer()
            signInButton
        }
        .WXMCardStyle()
    }

    var containerTitle: some View {
        HStack {
            Text(LocalizableString.signInDescription.localized)
                .foregroundColor(Color(colorEnum: .text))
                .font(.system(size: CGFloat(.normalMediumFontSize)))

            Spacer()
        }
    }

    @ViewBuilder
    var signInTextFields: some View {
		VStack(spacing: CGFloat(.defaultSpacing)) {
			BaseTextField(input: $viewModel.email, textFieldStyle: .user, keyboardType: .emailAddress)

			BaseTextField(input: $viewModel.password, textFieldStyle: .password)
		}
    }

    var forgotPasswordButton: some View {
        HStack {
            Spacer()
            Button {
                Router.shared.navigateTo(.resetPassword(ViewModelsFactory.getResetPasswordViewModel()))
            } label: {
                Text(LocalizableString.forgotPassword.localized)
                    .font(.system(size: CGFloat(.normalFontSize), weight: .bold))
                    .foregroundColor(Color(colorEnum: .primary))
                    .padding(.bottom, CGFloat(.defaultSpacing))
            }
        }
    }

    var signInButton: some View {
        Button {
            viewModel.login { error in
                if error == nil {
                    mainScreenVM.isUserLoggedIn = true
                    Router.shared.pop()
                }
            }
        } label: {
            Text(LocalizableString.signIn.localized)
        }
        .buttonStyle(WXMButtonStyle.filled())
        .disabled(!viewModel.isSignInButtonAvailable)
    }
}
