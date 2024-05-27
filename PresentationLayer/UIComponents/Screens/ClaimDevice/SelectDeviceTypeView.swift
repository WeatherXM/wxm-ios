//
//  SelectDeviceTypeView.swift
//  PresentationLayer
//
//  Created by Manolis Katsifarakis on 27/9/22.
//

import SwiftUI
import Toolkit

struct SelectDeviceTypeView: View {
    let dismiss: () -> Void
    let didSelectClaimFlow: (DeviceClaimFlow) -> Void

    enum DeviceClaimFlow {
        case manual
        case bluetooth
    }

    var body: some View {
        selectDeviceTypeContainer.shadow(radius: 4)
            .onAppear {
                WXMAnalytics.shared.trackScreen(.claimDeviceTypeSelection)
            }
    }

    var selectDeviceTypeContainer: some View {
        VStack(spacing: 0) {
            title
            ws1000Button()
            divider
            ws2000Button()
        }
        .WXMCardStyle(
            backgroundColor: Color(colorEnum: .top),
            foregroundColor: Color(colorEnum: .text),
            insideHorizontalPadding: 0,
            insideVerticalPadding: 0
        )
    }

    var title: some View {
        HStack {
            Text(LocalizableString.ClaimDevice.selectType.localized)
                .foregroundColor(Color(colorEnum: .text))
                .font(.system(size: CGFloat(.titleFontSize), weight: .bold))
                .multilineTextAlignment(.leading)
                .padding(20)
            Spacer()
            Button {
                dismiss()
            } label: {
                Image(asset: .closeIcon)
                    .renderingMode(.template)
                    .foregroundColor(Color(colorEnum: .text))
            }
            .frame(width: 50, height: 50)
        }
    }

    func ws1000Button() -> some View {
        Button {
            didSelectClaimFlow(.manual)
        } label: {
            deviceEntry(
                icon: AssetEnum.claimWiFi,
                title: LocalizableString.ClaimDevice.typeWS1000Title.localized,
                subtitle: LocalizableString.ClaimDevice.typeWS1000Subtitle.localized
            )
        }
    }

    func ws2000Button() -> some View {
        Button {
            didSelectClaimFlow(.bluetooth)
        } label: {
            deviceEntry(
                icon: AssetEnum.claimHelium,
                title: LocalizableString.ClaimDevice.typeWS2000Title.localized,
                subtitle: LocalizableString.ClaimDevice.typeWS2000Subtitle.localized,
                bottomPadding: 30
            )
        }
    }

    func deviceEntry(
        icon: AssetEnum,
        title: String,
        subtitle: String,
        bottomPadding: CGFloat = CGFloat(.defaultSidePadding)
    ) -> some View {
        VStack {
            HStack(spacing: CGFloat(.mediumSpacing)) {
                Image(asset: icon)
                    .renderingMode(.template)
                    .foregroundColor(Color(colorEnum: .text))

                Text(title)
                    .font(.system(size: CGFloat(.normalMediumFontSize), weight: .bold))
                    .foregroundColor(Color(colorEnum: .text))
                Spacer()
            }
            HStack {
                Text(subtitle)
                    .font(.system(size: CGFloat(.normalMediumFontSize), weight: .bold))
                    .foregroundColor(Color(colorEnum: .primary))
                Spacer()
            }
        }
        .padding(.top, 20)
        .padding(.bottom, bottomPadding)
        .padding(.horizontal, 43)
        .background(Color(colorEnum: .layer1))
    }

    var divider: some View = WXMDivider().padding(.horizontal, CGFloat(.defaultSidePadding))
}
