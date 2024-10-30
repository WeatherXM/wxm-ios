//
//  FloatingLabelTextfield.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 29/10/24.
//

import SwiftUI

struct FloatingLabelTextfield: View {

	let placeholder: String?
	var maxCount: Int?
	@Binding var textFieldError: TextFieldError?
	@Binding var text: String

	@FocusState private var isFocused: Bool

    var body: some View {
		VStack(spacing: CGFloat(.smallSpacing)) {
			HStack {
				TextField(placeholder ?? "",
						  text: $text)
				.foregroundColor(Color(colorEnum: .text))
				.font(.system(size: CGFloat(.mediumFontSize)))
				.focused($isFocused)
			}
			.padding(.horizontal, CGFloat(.mediumSidePadding))
			.padding(.vertical, CGFloat(.smallSidePadding))
			.strokeBorder(color: Color(colorEnum: borderColor),
						  lineWidth: 1.0,
						  radius: CGFloat(.lightCornerRadius))
			.zIndex(1)

			HStack {
				if let textFieldError {
					Text(textFieldError.description)
						.transition(.move(edge: .top).combined(with: .opacity))
				}

				Spacer()
				
				if let maxCount {
					Text("\(text.count)/\(maxCount)")
				}
			}
			.foregroundStyle(Color(colorEnum: counterColor))
			.font(.system(size: CGFloat(.caption)))
			.zIndex(0)
			.animation(.easeIn(duration: 0.2), value: textFieldError)
		}
    }
}

private extension FloatingLabelTextfield {
	var isError: Bool {
		if textFieldError != nil {
			return true
		}
		if let maxCount  {
			return text.count > maxCount
		}

		return false
	}

	private var borderColor: ColorEnum {
		let defaultColor: ColorEnum = isFocused ? .wxmPrimary : .midGrey
		return isError ? .error : defaultColor
	}

	private var counterColor: ColorEnum {
		return isError ? .error : .text
	}
}

#Preview {
	FloatingLabelTextfield(placeholder: "Placeholder",
						   maxCount: 10,
						   textFieldError: .constant(nil),
						   text: .constant(""))
	.padding()
}
