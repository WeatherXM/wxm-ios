//
//  AccountConfirmationView.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 14/3/23.
//

import SwiftUI
import Toolkit

struct AccountConfirmationView: View {
    @StateObject var viewModel: AccountConfirmationViewModel

    var body: some View {
        VStack(spacing: CGFloat(.defaultSpacing)) {
            VStack(spacing: CGFloat(.smallSpacing)) {
                HStack {
                    Text(viewModel.title)
                        .font(.system(size: CGFloat(.smallTitleFontSize), weight: .bold))
                        .foregroundColor(Color(colorEnum: .text))

                    Spacer()
                }

                HStack {
                    Text(viewModel.descriptionMarkdown?.attributedMarkdown ?? "")
                        .font(.system(size: CGFloat(.normalFontSize)))
                        .foregroundColor(Color(colorEnum: .text))

                    Spacer()
                }
            }

            BaseTextField(input: $viewModel.password,
                          textFieldStyle: .accountConfirmation,
                          error: viewModel.textFieldError)

            Button {
                viewModel.confirmButtonTapped()
            } label: {
                Text(LocalizableString.confirm.localized)
            }
            .buttonStyle(WXMButtonStyle.filled())
            .disabled(!viewModel.isConfirmButtonEnabled)
        }
        .WXMCardStyle()
        .spinningLoader(show: $viewModel.isLoading)
        .onAppear {
            Logger.shared.trackScreen(.passwordConfirm)
        }
    }
}

struct AccountConfirmationView_Previews: PreviewProvider {
    static var previews: some View {
        let vm = AccountConfirmationViewModel(title: "Confirm Password To Proceed",
        descriptionMarkdown: "In order to remove your station you need to confirm you are the owner of this account.\n**Please type in your password to remove your station.**")
        AccountConfirmationView(viewModel: vm)
    }
}
