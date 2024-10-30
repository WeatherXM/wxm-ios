//
//  FloatingLabelTextfield.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 29/10/24.
//

import SwiftUI

struct FloatingLabelTextfield: View {
	let configuration: Configuration
	let placeholder: String?
	var maxCount: Int?
	@Binding var textFieldError: TextFieldError?
	@Binding var text: String

	@FocusState private var isFocused: Bool
	@State private var showPassword: Bool = false

    var body: some View {
		VStack(spacing: CGFloat(.smallSpacing)) {
			floatingLabel
				.transition(.move(edge: .bottom).combined(with: .opacity))
				.zIndex(0)

			textField
				.zIndex(2)

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
			.zIndex(1)
			.animation(.easeIn(duration: 0.2), value: textFieldError)
			.animation(.easeIn(duration: 0.2), value: text)
		}
    }
}

extension FloatingLabelTextfield {
	struct Configuration {
		var floatingPlaceholder: Bool = false
		var isPassword: Bool = false
		var icon: FontIcon? = nil
	}

	@ViewBuilder
	var floatingLabel: some View {
		if configuration.floatingPlaceholder, !text.isEmpty,
		   let placeholder {
			HStack {
				Text(placeholder)
					.font(.system(size: CGFloat(.smallFontSize), weight: .bold))
					.foregroundStyle(Color(colorEnum: .wxmPrimary))
				Spacer()
			}
		}
	}

	@ViewBuilder
	var textField: some View {
		HStack {
			if let icon = configuration.icon {
				Text(icon.rawValue)
					.font(.fontAwesome(font: .FAProSolid, size: CGFloat(.smallTitleFontSize)))
					.foregroundStyle(Color(colorEnum: .darkGrey))
			}

			Group {
				if configuration.isPassword, !showPassword {
					SecureField(placeholder ?? "",
								text: $text)
					.textContentType(.password)
				} else {
					TextField(placeholder ?? "",
							  text: $text)
				}
			}
			.foregroundColor(Color(colorEnum: .text))
			.font(.system(size: CGFloat(.mediumFontSize)))
			.focused($isFocused)

			if configuration.isPassword {
				Button {
					showPassword.toggle()
				} label: {
					Text(showPassword ? FontIcon.eyeSlash.rawValue : FontIcon.eye.rawValue)
						.font(.fontAwesome(font: .FAProSolid, size: CGFloat(.smallTitleFontSize)))
						.foregroundStyle(Color(colorEnum: .darkGrey))
				}
			}
		}
		.padding(.horizontal, CGFloat(.mediumSidePadding))
		.padding(.vertical, CGFloat(.smallSidePadding))
		.strokeBorder(color: Color(colorEnum: borderColor),
					  lineWidth: 1.0,
					  radius: CGFloat(.lightCornerRadius))

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
	FloatingLabelTextfield(configuration: .init(floatingPlaceholder: true,
												isPassword: true,
												icon: .envelope),
						   placeholder: "Placeholder",
						   maxCount: 10,
						   textFieldError: .constant(nil),
						   text: .constant(""))
	.padding()
}
