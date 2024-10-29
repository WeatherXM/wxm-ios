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
	var textFieldError: TextFieldError?
	@Binding var text: String

    var body: some View {
		VStack(spacing: CGFloat(.smallSpacing)) {
			HStack {
				TextField(placeholder ?? "",
						  text: $text)
				.foregroundColor(Color(colorEnum: .text))
				.font(.system(size: CGFloat(.mediumFontSize)))
			}
			.padding(.horizontal, CGFloat(.mediumSidePadding))
			.padding(.vertical, CGFloat(.smallSidePadding))
			.strokeBorder(color: Color(colorEnum: borderColor),
						  lineWidth: 1.0,
						  radius: CGFloat(.lightCornerRadius))

			HStack {
				if let textFieldError {
					Text(textFieldError.description)
						.transition(.move(edge: .top).animation(.easeIn(duration: 1.2)))
				}

				Spacer()
				
				if let maxCount {
					Text("\(text.count)/\(maxCount)")
				}
			}
			.foregroundStyle(Color(colorEnum: counterColor))
			.font(.system(size: CGFloat(.caption)))
		}
    }
}

private extension FloatingLabelTextfield {
	var isError: Bool {
		if let textFieldError {
			return true
		}
		if let maxCount  {
			return text.count > maxCount
		}

		return false
	}

	private var borderColor: ColorEnum {
		return isError ? .error : .midGrey
	}

	private var counterColor: ColorEnum {
		return isError ? .error : .text
	}
}

#Preview {
	FloatingLabelTextfield(placeholder: "Placeholder",
						   maxCount: 10,
						   text: .constant(""))
	.padding()
}
