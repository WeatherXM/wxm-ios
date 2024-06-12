//
//  BluetoothMessages.swift
//  PresentationLayer
//
//  Created by Manolis Katsifarakis on 29/9/22.
//

import SwiftUI

struct BluetoothMessageView: View {
    let message: Message

    enum Message {
        case empty
        case noAccess
        case unsupported
        case bluetoothOff
    }

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack {
                    Spacer()
                    Image(asset: .bluetoothGray)
                        .renderingMode(.template)
                        .foregroundColor(Color(colorEnum: .darkGrey))

                    title

                    text

                    Spacer()
                }
                .frame(minHeight: geometry.size.height)
            }
        }
    }

    var title: some View {
        Group {
            switch message {
                case .empty:
                    return Text("")
                case .bluetoothOff:
                    return Text(LocalizableString.Bluetooth.title.localized)
                case .unsupported:
                    return Text(LocalizableString.Bluetooth.unsupportedTitle.localized)
                case .noAccess:
                    return Text(LocalizableString.Bluetooth.noAccessTitle.localized)
            }
        }
        .font(.system(size: CGFloat(.mediumFontSize), weight: .bold))
        .foregroundColor(Color(colorEnum: .darkestBlue))
    }

    var text: some View {
        ZStack {
            switch message {
                case .empty:
                    emptyMessage
                case .unsupported:
                    bluetoothUnsupportedMessage
                case .bluetoothOff:
                    bluetoothOffMessage
                case .noAccess:
                    noAccessMessage
            }
        }
    }

    var emptyMessage: some View {
        return VStack {
            AttributedLabel(attributedText: .constant(NSAttributedString(string: "")))
        }
    }

    var bluetoothUnsupportedMessage: some View {
        return VStack {
            attributedMessageWithText(LocalizableString.Bluetooth.offText.localized)
        }
    }

    var bluetoothOffMessage: some View {
        return VStack {
            attributedMessageWithText(LocalizableString.Bluetooth.offText.localized)
        }
    }

    var noAccessMessage: some View {
        return VStack {
            attributedMessageWithText(LocalizableString.Bluetooth.offText.localized)
            settingsButton(LocalizableString.Bluetooth.goToSettingsGrantAccess.localized)
        }
    }
}

private extension BluetoothMessageView {
    func attributedMessageWithText(_ text: String, boldText: String = LocalizableString.ClaimDevice.manuallyButton.localized) -> some View {
        let formattedMessage = messageWithBoldClaimButtonTitle(text, boldText: boldText)
        return AttributedLabel(attributedText: .constant(formattedMessage)) { uiLabel in
            uiLabel.textAlignment = .center
            uiLabel.textColor = UIColor(colorEnum: .text)
            uiLabel.font = .systemFont(ofSize: CGFloat(.normalFontSize))
        }
        .padding()
    }

    func messageWithBoldClaimButtonTitle(_ text: String, boldText: String) -> NSAttributedString {
        let attributedText = NSMutableAttributedString(
            string: text,
            attributes: [.font: UIFont.systemFont(ofSize: FontSizeEnum.caption.sizeValue)]
        )

        if let range = text.range(of: boldText) {
            let boldTextRange = NSRange(range, in: text)
            attributedText.setAttributes([.font: UIFont.systemFont(ofSize: FontSizeEnum.caption.sizeValue, weight: .bold)], range: boldTextRange)
        }

        return attributedText
    }

    func settingsButton(_ text: String) -> some View {
        Button {
            guard let url = URL(string: UIApplication.openSettingsURLString) else {
                return
            }

            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } label: {
            Label(text, image: AssetEnum.claimBluetoothButton.rawValue)
        }
        .buttonStyle(WXMButtonStyle())
        .padding()
    }
}

extension NSAttributedString {
    convenience init(format: NSAttributedString, _ args: NSAttributedString...) {
        let mutableNSAttributedString = NSMutableAttributedString(attributedString: format)

        args.forEach { attributedString in
            let range = NSString(string: mutableNSAttributedString.string).range(of: "%@")
            mutableNSAttributedString.replaceCharacters(in: range, with: attributedString)
        }

        self.init(attributedString: mutableNSAttributedString)
    }
}
