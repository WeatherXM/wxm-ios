//
//  ResetPasswordView.swift
//  PresentationLayer
//
//  Created by Danae Kikue Dimou on 17/5/22.
//

import SwiftUI
import Toolkit

struct ResetPasswordView: View {
    @StateObject var viewModel: ResetPasswordViewModel

    var body: some View {
        ZStack {
            VStack {
                resetPasswordFlow
            }
            .WXMCardStyle()
			.iPadMaxWidth()
            .padding(.top, CGFloat(.largeSidePadding))
            .padding(.bottom, CGFloat(.defaultSidePadding))
            .padding(.horizontal, CGFloat(.defaultSidePadding))
        }
        .navigationBarTitle(Text(LocalizableString.resetPasswordTitle.localized),
                            displayMode: .large)
        .onChange(of: viewModel.userEmail, perform: { text in
            viewModel.userEmail = text.trimWhiteSpaces()
            viewModel.isResetPasswordButtonAvailable()
        })
        .onAppear {
            Logger.shared.trackScreen(.passwordReset)
        }
    }

    private var resetPasswordFlow: some View {
        resetPasswordContainer
            .fail(show: $viewModel.isFail, obj: viewModel.failSuccessObj)
            .success(show: $viewModel.isSuccess, obj: viewModel.failSuccessObj)
            .spinningLoader(show: $viewModel.isCallInProgress, hideContent: true)
    }

    var resetPasswordContainer: some View {
        VStack(spacing: CGFloat(.defaultSpacing)) {
            containerDescription
            emailTextField
            Spacer()
            sendEmailButton
        }
    }

    var containerDescription: some View {
        Text(LocalizableString.resetPassword.localized)
            .foregroundColor(Color(colorEnum: .text))
            .multilineTextAlignment(.leading)
            .font(.system(size: CGFloat(.normalMediumFontSize)))
    }

    var emailTextField: some View {
        BaseTextField(input: $viewModel.userEmail, textFieldStyle: .email)
    }

    var sendEmailButton: some View {
        Button {
            viewModel.resetPassword()
        } label: {
            Text(LocalizableString.sendEmail.localized)
        }
        .buttonStyle(WXMButtonStyle.filled())
        .disabled(!viewModel.isSendResetPasswordButtonAvailable)
    }
}

struct Previews_ResetPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.gray.ignoresSafeArea()
            ResetPasswordView(viewModel: ViewModelsFactory.getResetPasswordViewModel())
        }
    }
}
