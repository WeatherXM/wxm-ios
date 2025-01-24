//
//  RegisterView.swift
//  PresentationLayer
//
//  Created by Danae Kikue Dimou on 17/5/22.
//

import SwiftUI
import Toolkit

struct RegisterView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
	@EnvironmentObject var navigationObject: NavigationObject
    @StateObject var viewModel: RegisterViewModel

    var body: some View {
        ZStack {
			Color(colorEnum: .bg).ignoresSafeArea()

            VStack {
                registerFlow
            }
            .WXMCardStyle()
			.iPadMaxWidth()
            .padding(.top, CGFloat(.largeSidePadding))
            .padding(.bottom, CGFloat(.defaultSidePadding))
            .padding(.horizontal, CGFloat(.defaultSidePadding))
        }
        .navigationBarTitle(Text(LocalizableString.createAccount.localized), displayMode: .large)
        .onChange(of: viewModel.userEmail) { email in
            viewModel.userEmail = email.trimWhiteSpaces()
        }
        .onAppear {
            WXMAnalytics.shared.trackScreen(.signup)
			navigationObject.title = LocalizableString.createAccount.localized
			navigationObject.navigationBarColor = Color(colorEnum: .bg)
        }
    }

    var registerFlow: some View {
        registerContainer
            .fail(show: $viewModel.isFail, obj: viewModel.failSuccessObj)
            .success(show: $viewModel.isSuccess, obj: viewModel.failSuccessObj)
            .spinningLoader(show: $viewModel.isCallInProgress, hideContent: true)
    }

    var registerContainer: some View {
        VStack(spacing: CGFloat(.largeSpacing)) {
            resisterDescription
            textFields
            Spacer()
			VStack(spacing: CGFloat(.defaultSpacing)) {
				acknowledgementView
				signUpButton
			}
        }
    }

    @ViewBuilder
    var resisterDescription: some View {
        Text(LocalizableString.registerDescription.localized)
            .font(.system(size: CGFloat(.normalMediumFontSize)))
            .foregroundColor(Color(colorEnum: .text))
    }

    @ViewBuilder
    var textFields: some View {
        VStack(spacing: CGFloat(.defaultSpacing)) {
			FloatingLabelTextfield(configuration: .init(floatingPlaceholder: true, icon: .envelope),
								   placeholder: LocalizableString.mandatoryEmail.localized,
								   textFieldError: .constant(nil),
								   text: $viewModel.userEmail)

			FloatingLabelTextfield(configuration: .init(floatingPlaceholder: true, icon: .user),
								   placeholder: LocalizableString.firstName.localized,
								   textFieldError: .constant(nil),
								   text: $viewModel.userName)

			FloatingLabelTextfield(configuration: .init(floatingPlaceholder: true, icon: .user),
								   placeholder: LocalizableString.lastName.localized,
								   textFieldError: .constant(nil),
								   text: $viewModel.userSurname)
        }
		.animation(.easeIn(duration: 0.2))
    }

    @ViewBuilder
    var signUpButton: some View {
        Button {
            viewModel.register()
        } label: {
            Text(LocalizableString.signUp.localized)
        }
        .buttonStyle(WXMButtonStyle.filled())
        .disabled(!viewModel.isSignUpButtonAvailable)
    }

	@ViewBuilder
	var acknowledgementView: some View {
		HStack(alignment: .top, spacing: CGFloat(.smallSpacing)) {
			Toggle("",
				   isOn: $viewModel.termsAccepted)
			.labelsHidden()
			.toggleStyle(WXMToggleStyle.Default)

			Text(termsText)
				.foregroundColor(Color(colorEnum: .text))
				.font(.system(size: CGFloat(.normalFontSize)))
				.tint(Color(colorEnum: .wxmPrimary))
				.fixedSize(horizontal: false, vertical: true)
		}
		.environment(\.openURL, OpenURLAction { url in
			Router.shared.showFullScreen(.safariView(url))
			return .handled
		})

	}

	var termsText: AttributedString {
		let terms = LocalizableString.Settings.termsOfUse.localized
		let termsUrl = LocalizableString.url(terms,
											 DisplayedLinks.termsOfUse.linkURL).localized

		let privacy = LocalizableString.Settings.privacyPolicy.localized
		let privacyUrl = LocalizableString.url(privacy,
											   DisplayedLinks.privacyPolicy.linkURL).localized

		var str = LocalizableString.readTermsAndPrivacyPolicy(termsUrl, privacyUrl).localized.attributedMarkdown!

		if let termsRange = str.range(of: terms) {
			str[termsRange].underlineStyle = .single
		}

		if let privacyRange = str.range(of: privacy) {
			str[privacyRange].underlineStyle = .single
		}

		return str
	}
}

struct Previews_RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationContainerView {
            RegisterView(viewModel: ViewModelsFactory.getRegisterViewModel())
        }
    }
}
