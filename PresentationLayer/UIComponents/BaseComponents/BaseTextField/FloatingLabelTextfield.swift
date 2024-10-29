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
				Spacer()
				if let maxCount {
					Text("\(text.count)/\(maxCount)")
						.foregroundStyle(Color(colorEnum: counterColor))
						.font(.system(size: CGFloat(.caption)))
				}
			}
		}
    }
}

private extension FloatingLabelTextfield {
	var isError: Bool {
		guard let maxCount else {
			return false
		}
		let isError: Bool = text.count > maxCount
		return isError
	}

	private var borderColor: ColorEnum {
		return isError ? .error : .midGrey
	}

	private var counterColor: ColorEnum {
		return isError ? .error : .text
	}
}

private struct BorderModifier: ViewModifier {
	let textCount: Int
	let maxCount: Int?

	private var color: ColorEnum {
		guard let maxCount else {
			return .midGrey
		}
		let isError: Bool = textCount > maxCount

		return isError ? .error : .midGrey
	}

	func body(content: Content) -> some View {
		content
			.strokeBorder(color: Color(colorEnum: color), lineWidth: 1.0, radius: CGFloat(.lightCornerRadius))
	}
}

private extension View {
	@ViewBuilder
	func bordered(textCount: Int, maxCount: Int?) -> some View {
		modifier(BorderModifier(textCount: textCount, maxCount: maxCount))
	}
}

#Preview {
	FloatingLabelTextfield(placeholder: "Placeholder",
						   maxCount: 10,
						   text: .constant(""))
	.padding()
}
