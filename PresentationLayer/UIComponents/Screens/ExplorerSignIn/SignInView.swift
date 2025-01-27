//
//  SignInView.swift
//  PresentationLayer
//
//  Created by Danae Kikue Dimou on 16/5/22.
//

import SwiftUI
import Toolkit

struct SignInView: View {
	@EnvironmentObject var navigationObject: NavigationObject
	private let mainScreenVM: MainScreenViewModel = .shared
    @StateObject var viewModel: SignInViewModel

    var body: some View {
		ZStack {
			Color(colorEnum: .bg)
				.ignoresSafeArea()
			
			VStack {
				loginContainer
					.iPadMaxWidth()
			}
			.padding(.top, CGFloat(.largeSidePadding))
			.padding(.bottom, CGFloat(.defaultSidePadding))
			.padding(.horizontal, CGFloat(.defaultSidePadding))
		}
        .onChange(of: viewModel.password, perform: { _ in
            viewModel.checkSignInButtonAvailability()
        })
        .onChange(of: viewModel.email, perform: { _ in
            viewModel.checkSignInButtonAvailability()
        })
        .onAppear {
            WXMAnalytics.shared.trackScreen(.login)
			navigationObject.title = LocalizableString.signIn.localized
			navigationObject.navigationBarColor = Color(colorEnum: .bg)
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
			FloatingLabelTextfield(configuration: .init(floatingPlaceholder: true,
														icon: .envelope,
														keyboardType: .emailAddress),
								   placeholder: LocalizableString.email.localized,
								   textFieldError: .constant(nil),
								   text: $viewModel.email)

			FloatingLabelTextfield(configuration: .init(floatingPlaceholder: true,
														isPassword: true,
														icon: .lock),
								   placeholder: LocalizableString.password.localized,
								   textFieldError: .constant(nil),
								   text: $viewModel.password)
		}
		.animation(.easeIn(duration: 0.2))
    }

    var forgotPasswordButton: some View {
        HStack {
            Spacer()
            Button {
                Router.shared.navigateTo(.resetPassword(ViewModelsFactory.getResetPasswordViewModel()))
            } label: {
                Text(LocalizableString.forgotPassword.localized)
                    .font(.system(size: CGFloat(.normalFontSize), weight: .bold))
                    .foregroundColor(Color(colorEnum: .wxmPrimary))
                    .padding(.bottom, CGFloat(.defaultSpacing))
            }
        }
    }

    var signInButton: some View {
        Button {
            viewModel.login { error in
                if error == nil {
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

#Preview {
	NavigationContainerView {
		SignInView(viewModel: ViewModelsFactory.getSignInViewModel())
	}
}
