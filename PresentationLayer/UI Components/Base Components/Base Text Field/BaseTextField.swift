//
//  BaseTextField.swift
//  PresentationLayer
//
//  Created by Danae Kikue Dimou on 10/5/22.
//

import SwiftUI

struct BaseTextField: View {
    @Binding var input: String
    var caption: String?
    @State var showPassword: Bool
    @State var showFloatingLabel: Bool
    @State var isTextFieldFocused: Bool
    var textFieldStyle: BaseTextFieldEnum
    var error: TextFieldError?
    let keyboardType: UIKeyboardType
    let maskStringOffset = 5
    var isInputForDeleteAccount: Bool

    public init(
        input: Binding<String>,
        caption: String? = nil,
        showPassword: Bool = true,
        showFloatingLabel: Bool = false,
        isTextFieldFocused: Bool = false,
        textFieldStyle: BaseTextFieldEnum,
        error: TextFieldError? = nil,
        keyboardType: UIKeyboardType = .default,
        isInputForDeleteAccount: Bool = false
    ) {
        _input = input
        self.caption = caption
        self.showPassword = showPassword
        self.showFloatingLabel = showFloatingLabel
        self.isTextFieldFocused = isTextFieldFocused
        self.textFieldStyle = textFieldStyle
        self.error = error
        self.keyboardType = keyboardType
        self.isInputForDeleteAccount = isInputForDeleteAccount
    }

    var body: some View {
        VStack(spacing: CGFloat(.minimumSpacing)) {
            if showFloatingLabel, !isInputForDeleteAccount {
                floatingLabel
            }
            HStack {
                inputField
            }

            captionHStack
        }.onChange(of: input) { changedInput in
            withAnimation {
                showFloatingLabel = !changedInput.isEmpty
            }
        }.onAppear {
            showFloatingLabel = !input.isEmpty
        }
    }

    var inputField: some View {
        HStack {
            leftIcon
            Group {
                switch showPassword == textFieldStyle.isPassword {
                    case true:
                        SecureField(isInputForDeleteAccount ? "Type your Password" : textFieldStyle.label, text: $input)
                            .textContentType(.password)
                            .foregroundColor(Color(colorEnum: .text))
                    case false:
                        if textFieldStyle == .currentWXMAddress {
                            TextField(input.maskString(offsetStart: maskStringOffset, offsetEnd: maskStringOffset, maskedCharactersToShow: maskStringOffset), text: .constant(""))
                                .disabled(textFieldStyle == .currentWXMAddress ? true : false)
                                .autocapitalization(.none)
                                .foregroundColor(Color(colorEnum: .text))
                        } else if textFieldStyle == .user {
                            TextField(textFieldStyle.label, text: $input, onEditingChanged: { editingChanged in
                                if editingChanged {
                                    isTextFieldFocused = true
                                } else {
                                    isTextFieldFocused = false
                                }
                            })
                            .foregroundColor(Color(colorEnum: .text))
                            .autocapitalization(.none)
                            .keyboardType(keyboardType)
                            .textContentType(.emailAddress)
                        } else {
                            TextField(textFieldStyle.label, text: $input, onEditingChanged: { editingChanged in
                                if editingChanged {
                                    isTextFieldFocused = true
                                } else {
                                    isTextFieldFocused = false
                                }
                            })
                            .foregroundColor(Color(colorEnum: .text))
                            .keyboardType(keyboardType)
                            .autocapitalization(.none)
                        }
                }
            }
            rightIcon
        }
        .foregroundColor(Color(colorEnum: .midGrey))
        .padding(CGFloat(.smallSidePadding))
        .font(.system(size: CGFloat(.normalMediumFontSize)))
        .overlay(overlayViewColor)
    }

    @ViewBuilder
    var leftIcon: some View {
        if let icon = textFieldStyle.leftIcon {
            icon
                .renderingMode(.template)
                .foregroundColor(Color(colorEnum: .text))
                .padding(.trailing, CGFloat(.normalMediumFontSize))
        }
    }

    @ViewBuilder
    var rightIcon: some View {
        if let icon = textFieldStyle.rightIcon {
            Button {
                rightIconAction()
            } label: {
                icon
                    .renderingMode(.template)
                    .foregroundColor(Color(colorEnum: .text))

            }
        }
    }

    var floatingLabel: some View {
        HStack {
            Text(textFieldStyle.label).font(.system(size: CGFloat(.smallFontSize), weight: .bold, design: .default)).foregroundColor(Color(colorEnum: .primary))
            Spacer()
        }
    }

    var captionHStack: some View {
        HStack {
            if let error = error {
                Text(error.description).font(.system(size: CGFloat(.smallFontSize))).foregroundColor(Color(colorEnum: .error))
            }

            Spacer()

            if let caption {
                Text(caption).font(.system(size: CGFloat(.caption))).foregroundColor(Color(colorEnum: .text))
            }
        }
    }

    private func rightIconAction() {
        switch textFieldStyle {
            case .password, .accountConfirmation:
                showPassword.toggle()
            default:
                break
        }
    }

    private var overlayViewColor: some View {
        if isTextFieldFocused && error == nil {
            return RoundedRectangle(cornerRadius: CGFloat(.lightCornerRadius)).stroke(Color(colorEnum: .primary))
        } else if !isTextFieldFocused && error == nil {
            return RoundedRectangle(cornerRadius: CGFloat(.lightCornerRadius)).stroke(Color(colorEnum: .midGrey))
        } else if error != nil && isTextFieldFocused {
            return RoundedRectangle(cornerRadius: CGFloat(.lightCornerRadius)).stroke(Color(colorEnum: .primary))
        } else {
            return RoundedRectangle(cornerRadius: CGFloat(.lightCornerRadius)).stroke(Color(colorEnum: .error))
        }
    }

    func shareWalletAddress(walletAddress: String) {
        let activityVC = UIActivityViewController(activityItems: [walletAddress], applicationActivities: nil)
        UIApplication.shared.windows.first?.rootViewController?.present(activityVC, animated: true, completion: nil)
    }
}
