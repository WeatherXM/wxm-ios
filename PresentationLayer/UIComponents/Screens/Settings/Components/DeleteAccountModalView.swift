//
//  DeleteAccountModalView.swift
//  PresentationLayer
//
//  Created by Panagiotis Palamidas on 21/10/22.
//

import SwiftUI

struct DeleteAccountModalView: View {
    @EnvironmentObject var viewModel: DeleteAccountViewModel

    var body: some View {
        ZStack {
            VStack {
                passwordInput
                installLaterToggle
                deleteButton
            }
            .padding()
            .fixedSize(horizontal: false, vertical: true)
        }
        .background {
            RoundedRectangle(cornerRadius: CGFloat(.buttonCornerRadius))
                .foregroundColor(Color(colorEnum: .top))
                .ignoresSafeArea()
                .wxmShadow()
        }

    }

    var passwordInput: some View {
        VStack {
			FloatingLabelTextfield(configuration: .init(isPassword: true),
								   placeholder: LocalizableString.typeYourPassword.localized,
								   textFieldError: .constant(viewModel.passwordHasError ? TextFieldError.invalidPassword : nil),
								   text: $viewModel.password)
                .padding(.bottom, CGFloat(.defaultSidePadding))
        }
    }

    var installLaterToggle: some View {
        HStack(alignment: .top) {
            Toggle(
                LocalizableString.DeleteAccount.understandDeletionTerms.localized,
                isOn: $viewModel.isToggleOn
            )
            .labelsHidden()
            .toggleStyle(
                WXMToggleStyle.Default
            )
            termsText
            Spacer()
        }
        .padding(.bottom, 10)
    }

    var termsText: some View {
        VStack(alignment: .leading) {
            Text(LocalizableString.DeleteAccount.understandDeletionTerms.localized)
                .font(.system(size: CGFloat(.normalFontSize)))
                .foregroundColor(Color(colorEnum: .text))
        }
    }

    var deleteButton: some View {
        Button {
            viewModel.tryLoginAndDeleteAccount()
        } label: {
            Text(LocalizableString.DeleteAccount.deleteAccount.localized)
        }
        .buttonStyle(WXMButtonStyle(textColor: .top,
                                              textColorDisabled: .midGrey,
                                              fillColor: .error,
                                              fillColorDisabled: .errorTint,
                                              strokeColor: .error,
                                              strokeColorDisabled: .errorTint))
        .disabled(!viewModel.isToggleOn ||
                  viewModel.password.isEmpty ||
                  viewModel.isValidatingPassword)

    }
}

#Preview {
	DeleteAccountModalView()
		.environmentObject(ViewModelsFactory.getDeleteAccountViewModel(userId: ""))
}
