//
//  DeleteAccountView.swift
//  PresentationLayer
//
//  Created by Panagiotis Palamidas on 21/10/22.
//

import SwiftUI
import Toolkit

struct DeleteAccountView: View {
	@EnvironmentObject var navigationObject: NavigationObject
    @StateObject var viewModel: DeleteAccountViewModel

    var body: some View {
        Group {
            switch viewModel.currentScreen {
                case .info: mainInfoBody
                case .failure: FailedDeleteView().environmentObject(viewModel)
            }
        }
        .onAppear {
            WXMAnalytics.shared.trackScreen(.deleteAccount)
			navigationObject.navigationBarColor = Color(colorEnum: .bg)
        }
    }

    var mainInfoBody: some View {
        ZStack {
            Color(colorEnum: .bg)
                .ignoresSafeArea()

            VStack(alignment: .leading) {
                information
                    .padding()
                Spacer()
            }

            passwordModal
        }
    }

    var information: some View {
        ScrollView(showsIndicators: true) {
            Text( LocalizableString.DeleteAccount.textMarkdown.localized.attributedMarkdown!)
                .font(.system(size: CGFloat(.normalFontSize)))
                .foregroundColor(Color(colorEnum: .text))
        }
        .padding(.vertical, 10)
    }

    @ViewBuilder
    var generalInfo: some View {
        Text(LocalizableString.DeleteAccount.generalInfo.localized.attributedMarkdown!)
            .font(.system(size: CGFloat(.normalFontSize)))
            .foregroundColor(Color(colorEnum: .text))
    }

    var toDeleteInfo: some View {
        Group {
            CustomText(text: Text(LocalizableString.DeleteAccount.toDeleteTitle.localized))
                .padding(.top, 20)
                .padding(.bottom, 1)
            BulletPointText(text: Text(SettingsEnum.toDeleteName.settingsDeleteAccountInfo))
            BulletPointText(text: Text(SettingsEnum.toDeleteAddress.settingsDeleteAccountInfo))
            BulletPointText(text: Text(SettingsEnum.toDeletePersonalData.settingsDeleteAccountInfo))
        }
    }

    var notDeleteInfo: some View {
        Group {
            CustomText(text: Text(LocalizableString.DeleteAccount.notDeleteTitle.localized))
                .padding(.top, 20)
                .padding(.bottom, 1)
            BulletPointText(text: Text(SettingsEnum.notDeleteWeatherData.settingsDeleteAccountInfo))
            BulletPointText(text: Text(SettingsEnum.notDeleteRewards.settingsDeleteAccountInfo))
        }
    }

    var collectingDataInfo: some View {
        CustomText(text: Text(SettingsEnum.noCollectDataTitle.settingsDeleteAccountInfo))
            .padding(.top, 20)
    }

    var contactInfo: some View {
        CustomText(text: Text(LocalizableString.DeleteAccount.contactForSupport.localized))
            .padding(.top, 20)
    }

    var passwordModal: some View {
        VStack {
            Spacer()
            DeleteAccountModalView()
                .environmentObject(viewModel)
        }
    }
}

private struct CustomText: View {
    var text: Text
    var isBold: Bool

    init(text: Text, isBold: Bool = false) {
        self.text = text
        self.isBold = isBold
    }

    var body: some View {
        text
            .fontWeight(isBold ? .bold : .regular)
            .font(.system(size: 14))
            .lineSpacing(3)
    }
}

private struct BulletPointText: View {
    var text: Text

    var body: some View {
        HStack(alignment: .top) {
            Text(verbatim: "  •")
            text
                .font(.system(size: 14))
                .lineSpacing(3)
        }
    }
}

struct Previews_DeleteAccountView_Previews: PreviewProvider {
    static var previews: some View {
		NavigationContainerView {
			DeleteAccountView(viewModel: ViewModelsFactory.getDeleteAccountViewModel(userId: ""))
		}
    }
}
