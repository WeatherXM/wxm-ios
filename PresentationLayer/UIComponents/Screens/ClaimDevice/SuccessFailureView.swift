//
//  SuccessFailureView.swift
//  PresentationLayer
//
//  Created by Danae Kikue Dimou on 23/5/22.
//

import SwiftUI

struct SuccessFailureView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    let title: String
    let description: String
    let isSuccess: Bool
    let isBottomButtonAvailable: Bool
    let serialNumber: String?
    let email: String?

    public init(title: String, desc: String, isSuccess: Bool, isBottomButtonAvailable: Bool = false, serialNumber: String? = nil, email: String? = nil) {
        self.title = title
        description = desc
        self.isSuccess = isSuccess
        self.isBottomButtonAvailable = isBottomButtonAvailable
        self.serialNumber = serialNumber
        self.email = email
    }

    var body: some View {
        claimDeviceFailureScreen
    }

    var claimDeviceFailureScreen: some View {
        VStack {
            claimDeviceFailureContainer
            viewDeviceListButton
            Spacer()
        }
    }

    var claimDeviceFailureContainer: some View {
        VStack {
            Spacer()
            successFailIcon
            successFailTitle
            successFailDescription
            Spacer()
            bottomButton
        }
        .baseContainerStyle()
    }

    @ViewBuilder
    var viewDeviceListButton: some View {
        if isBottomButtonAvailable {
            BaseButton(
                text: .viewDeviceList,
                isEnabled: isSuccess,
                isRedirection: false
            ) {
                presentationMode.wrappedValue.dismiss()
            }
            .customPadding(.top, .failureStandardPadding)
            .padding(.horizontal, 34)
        }
    }

    var successFailIcon: some View {
        LottieView(animationCase: getDeviceFlowFinalAnimation(), loopMode: .playOnce)
            .frame(
                width: CGFloat(IntConstants.iconDimensions),
                height: CGFloat(IntConstants.iconDimensions)
            )
    }

    var successFailTitle: some View {
        Text(title)
            .font(.system(size: CGFloat(.titleFontSize), weight: .bold))
            .customPadding(.bottom, .failureStandardPadding)
            .multilineTextAlignment(.center)
    }

    var successFailDescription: some View {
        Text(description)
            .font(.system(size: CGFloat(.largeFontSize), weight: .thin))
            .multilineTextAlignment(.center)
    }

    @ViewBuilder
    var bottomButton: some View {
        if isBottomButtonAvailable {
            if !isSuccess {
                BaseTextButton(text: .contactUsText, isRedirection: false) {
                    openEmailApp()
                }
                .scaleEffect(1.2)
                .lineSpacing(1)
                .multilineTextAlignment(.center)
            }
        }
    }

    private func openEmailApp() {
        let subject = StringConstants.cannotClaimDeviceTitleEmail.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? ""
        let firstBodyParameter: String = (StringConstants.cannotClaimDeviceBodyUserAccount + (email ?? "")).addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? ""
        let secondBodyParameter = ("\n" + (StringConstants.cannotClaimDeviceBodyDeviceSN + (serialNumber?.replaceColonOcurrancies() ?? ""))).addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? ""
        if let url = URL(string: "mailto:\(StringConstants.weatherXMSupportEmail)?subject=\(subject)&body=\(firstBodyParameter)\(secondBodyParameter)") {
            UIApplication.shared.open(url)
        }
    }

    private func getDeviceFlowFinalAnimation() -> String {
        if isSuccess {
            return AnimationsEnums.success.animationString
        } else {
            return AnimationsEnums.fail.animationString
        }
    }
}
