//
//  ClaimDeviceConnection.swift
//  PresentationLayer
//
//  Created by Manolis Katsifarakis on 29/11/22.
//

import SwiftUI

struct ClaimDeviceConnection: View {
    @EnvironmentObject var viewModel: ClaimDeviceViewModel

    @State private var didSelectManualFlow = true

    private let swinjectHelper: SwinjectInterface
    private let transport: StepsNavView.Transport

    public init(
        swinjectHelper: SwinjectInterface,
        transport: StepsNavView.Transport
    ) {
        self.swinjectHelper = swinjectHelper
        self.transport = transport
    }

    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 0) {
                title

                ScrollView {
                    section(
                        index: 1,
                        attributedText: attributedText(
                            text: LocalizableString.ClaimDevice.connectionBullet1(LocalizableString.ClaimDevice.connectionBullet1Bold.localized).localized,
                            boldText: LocalizableString.ClaimDevice.connectionBullet1Bold.localized
                        )
                    )

                    section(
                        index: 2,
                        attributedText: attributedText(
                            text: LocalizableString.ClaimDevice.connectionBullet2(LocalizableString.ClaimDevice.connectionBullet2Bold.localized).localized,
                            boldText: LocalizableString.ClaimDevice.connectionBullet2Bold.localized
                        )
                    )

                    section(
                        index: 3,
                        text: LocalizableString.ClaimDevice.connectionBullet3.localized
                    )

                    HStack {
                        Text(LocalizableString.ClaimDevice.connectionText.localized)
                            .foregroundColor(Color(colorEnum: .text))
                            .font(.system(size: CGFloat(.normalFontSize), weight: .bold))

                        Spacer()
                    }

                    Button {
                        if
							let url = URL(string: DisplayedLinks.m5VideoLink.linkURL),
                            UIApplication.shared.canOpenURL(url)
                        {
                            UIApplication.shared.open(url, options: [:])
                        }
                    } label: {
                        Image(asset: .m5Video)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    }
                }

                Spacer()

                bottomButtons
            }
            .WXMCardStyle()
            .padding(.horizontal, CGFloat(.defaultSidePadding))
            .padding(.bottom, CGFloat(.defaultSidePadding))
        }
    }

    var title: some View {
        Text(LocalizableString.ClaimDevice.connectionTitle.localized)
            .font(.system(size: CGFloat(.titleFontSize), weight: .bold))
            .padding(.bottom, 30)
    }

    var bottomButtons: some View {
        VStack(spacing: CGFloat(.defaultSpacing)) {
            Button {
                transport.nextStep()
            } label: {
                Text(LocalizableString.ClaimDevice.iVeConnectMyM5Button.localized)
            }
            .buttonStyle(WXMButtonStyle.filled())
        }
    }
}

private extension ClaimDeviceConnection {
    func section(
        index: Int,
        attributedText: NSAttributedString? = nil,
        text: String? = nil
    ) -> some View {
        HStack(alignment: .top) {
            Text("\(index)")
                .font(.system(size: CGFloat(.mediumFontSize), weight: .bold))
                .foregroundColor(Color(colorEnum: .top))
                .background(
                    Circle()
                        .background(
                            Circle().fill(Color(colorEnum: .darkGrey))
                        )
                        .frame(width: 24, height: 24)
                )
                .padding(.vertical, 6)
                .padding(.horizontal, 10)

            if let attributedText = attributedText {
                AttributedLabel(attributedText: .constant(attributedText))
            } else if let text = text {
                Text(text)
                    .font(.system(size: CGFloat(.normalFontSize)))
            }

            Spacer()
        }
        .padding(.bottom, CGFloat(.defaultSidePadding))
    }

    func attributedText(text: String, boldText: String) -> NSAttributedString {
        let attributedText = NSMutableAttributedString(
            string: text,
            attributes: [.font: UIFont.systemFont(ofSize: FontSizeEnum.normalFontSize.sizeValue)]
        )
        
        if let range = text.range(of: boldText) {
            let boldTextRange = NSRange(range, in: text)
            attributedText.setAttributes([.font: UIFont.systemFont(ofSize: FontSizeEnum.normalFontSize.sizeValue, weight: .bold)], range: boldTextRange)
        }

        return attributedText
    }
}
