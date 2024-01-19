//
//  FailedDeleteView.swift
//  PresentationLayer
//
//  Created by Panagiotis Palamidas on 25/10/22.
//

import SwiftUI

struct FailedDeleteView: View {
    @EnvironmentObject var viewModel: DeleteAccountViewModel
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        ZStack {
            VStack {
                Image("DeleteFailureIcon")
                failureInfo
                constactSupport
            }
            .navigationBarBackButtonHidden(true)
            navigationButtons
        }
        .padding(.horizontal)
    }

    @ViewBuilder
    var failureInfo: some View {
        failureTitle
        failureText
    }

    var failureTitle: some View {
        Text(LocalizableString.DeleteAccount.failureTitle.localized)
            .font(.system(size: CGFloat(.largeTitleFontSize)))
            .foregroundColor(Color(colorEnum: .text))
            .bold()
            .padding(.top, CGFloat(.defaultSidePadding))
    }

    var failureText: some View {
        Text(LocalizableString.DeleteAccount.failedDescription.localized)
            .font(.system(size: CGFloat(.normalFontSize)))
            .foregroundColor(Color(colorEnum: .text))
            .multilineTextAlignment(.center)
            .padding(.top, CGFloat(.defaultSidePadding))
            .padding(.horizontal, CGFloat(.XLSidePadding))
    }

    @ViewBuilder
    var constactSupport: some View {
        contactSupportText
        contactSupportButton
    }

    var contactSupportText: some View {
        Text(LocalizableString.DeleteAccount.failedContactSupport(viewModel.deleteFailureErrorMessage).localized)
            .font(.system(size: CGFloat(.normalFontSize)))
            .foregroundColor(Color(colorEnum: .text))
            .multilineTextAlignment(.center)
            .padding(.top, CGFloat(.defaultSidePadding))
            .padding(.horizontal, CGFloat(.XLSidePadding))
    }

    var contactSupportButton: some View {
        Button {
            viewModel.contactSupport()
		} label: {
            Text(LocalizableString.contactSupport.localized)
        }
        .buttonStyle(WXMButtonStyle())
        .padding(.top, CGFloat(.defaultSidePadding))
    }

    var navigationButtons: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                cancelDeletionButton
                Spacer()
                retryDeletionButton
                Spacer()
            }
            .padding(.bottom, CGFloat(.defaultSidePadding))
        }
    }

    var cancelDeletionButton: some View {
        Button {
            presentationMode.wrappedValue.dismiss()
		} label: {
            cancelDeletionButtonStyle
        }
        .buttonStyle(WXMButtonStyle())
    }

    var cancelDeletionButtonStyle: some View {
        Text(LocalizableString.DeleteAccount.cancelDeletion.localized)
    }

    var retryDeletionButton: some View {
        Button {
            viewModel.tryDeleteAccount()
		} label: {
            retryDeletionButtonStyle
        }
        .buttonStyle(WXMButtonStyle.filled())
    }

    var retryDeletionButtonStyle: some View {
        Text(LocalizableString.DeleteAccount.retryDeletion.localized)
    }
}

struct FailedDeleteView_Previews: PreviewProvider {
    static var previews: some View {
        FailedDeleteView()
            .environmentObject(SwinjectHelper.shared.getContainerForSwinject().resolve(DeleteAccountViewModel.self)!)

    }
}
