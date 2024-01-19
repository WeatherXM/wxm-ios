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
    @StateObject var viewModel: RegisterViewModel

    var body: some View {
        ZStack {
            VStack {
                registerFlow
            }
            .WXMCardStyle()
            .padding(.top, CGFloat(.largeSidePadding))
            .padding(.bottom, CGFloat(.defaultSidePadding))
            .padding(.horizontal, CGFloat(.defaultSidePadding))
        }
        .navigationBarTitle(Text(LocalizableString.createAccount.localized), displayMode: .large)
        .onChange(of: viewModel.userEmail) { email in
            viewModel.userEmail = email.trimWhiteSpaces()
            viewModel.checkSignUpButtonAvailability()
        }
        .onAppear {
            Logger.shared.trackScreen(.signup)
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
            signUpButton
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
            BaseTextField(input: $viewModel.userEmail, textFieldStyle: .mandatoryEmail)

            BaseTextField(input: $viewModel.userName, textFieldStyle: .name)

            BaseTextField(input: $viewModel.userSurname, textFieldStyle: .surname)
        }
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
}

struct Previews_RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.gray.ignoresSafeArea()
            RegisterView(viewModel: ViewModelsFactory.getRegisterViewModel())
        }
    }
}
