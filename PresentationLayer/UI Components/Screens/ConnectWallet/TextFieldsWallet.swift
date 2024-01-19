//
//  TextFieldWalletView.swift
//  PresentationLayer
//
//  Created by Danae Kikue Dimou on 2/6/22.
//

import SwiftUI

struct TextFieldsWallet: View {
    let type: BaseTextFieldEnum
    let inputLimit: Int
    @Binding var input: String
    var newAddressError: TextFieldError?

    public init(
        type: BaseTextFieldEnum,
        currentAddressLabel: Binding<String> = .constant(""),
        inputLimit: Int = 42,
        input: Binding<String> = .constant(""),
        newAddressError: TextFieldError? = nil
    ) {
        self.type = type
        self.inputLimit = inputLimit
        _input = input.trimmed().max(inputLimit)
        self.newAddressError = newAddressError
    }

    var body: some View {
        VStack(alignment: .leading, spacing: CGFloat(.defaultSpacing)) {
            textField
        }
    }

    var textField: some View {
        BaseTextField(input: $input,
                      caption: type == .newWXMAddress ? "\(input.count)/\(inputLimit)" : nil,
                      textFieldStyle: type,
                      error: newAddressError)
    }
}

private extension Binding where Value == String {
    func trimmed() -> Self {
        if wrappedValue.containsSpaces() {
            DispatchQueue.main.async {
                self.wrappedValue = self.wrappedValue.trimWhiteSpaces().removeSpaces()
            }
        }

        return self
    }

    func max(_ limit: Int) -> Self {
        if self.wrappedValue.count > limit {
            DispatchQueue.main.async {
                self.wrappedValue = String(self.wrappedValue.dropLast())
            }
        }

        return self
    }
}
