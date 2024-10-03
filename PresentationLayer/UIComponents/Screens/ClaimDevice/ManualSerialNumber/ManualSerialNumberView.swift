//
//  ManualSerialNumberView.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 14/5/24.
//

import SwiftUI

struct ManualSerialNumberView: View {
	@StateObject var viewModel: ManualSerialNumberViewModel

    var body: some View {
		ZStack {
			Color(colorEnum: .topBG)
				.ignoresSafeArea()
			VStack {
				ScrollView(showsIndicators: false) {
					VStack(spacing: CGFloat(.largeSpacing)) {
						HStack {
							Text(viewModel.title)
								.font(.system(size: CGFloat(.smallTitleFontSize), weight: .bold))
								.foregroundStyle(Color(colorEnum: .darkestBlue))

							Spacer()
						}

						if let subtitle = viewModel.subtitle {
							HStack {
								Text(subtitle)
									.foregroundStyle(Color(colorEnum: .text))
									.font(.system(size: CGFloat(.normalFontSize)))

								Spacer()
							}
						}

						bullets

						Group {
							if let image = viewModel.image {
								Image(asset: image)
									.resizable()
									.aspectRatio(contentMode: .fit)
							}

							if let gifFile = viewModel.gifFile {
								GifImageView(fileName: gifFile)
									.aspectRatio(contentMode: .fit)

							}
						}

						if let caption = viewModel.caption {
							HStack {
								Text(caption)
									.foregroundStyle(Color(colorEnum: .newText))
									.font(.system(size: CGFloat(.normalFontSize)))

								Spacer()
							}
						}

						textFields
					}
					.padding(.horizontal, CGFloat(.mediumSidePadding))
					.padding(.top, CGFloat(.mediumSidePadding))
				}

				bottomButton
			}
			.padding(.bottom, CGFloat(.mediumSidePadding))
		}
    }
}

private extension ManualSerialNumberView {

	@ViewBuilder
	var bullets: some View {
		if let bullets = viewModel.bullets {
			VStack(spacing: CGFloat(.mediumSpacing)) {
				ForEach(0..<bullets.count, id: \.self) { index in
					let bullet = bullets[index]
					ClaimDeviceBulletView(bullet: bullet)
				}
			}
		} else {
			EmptyView()
		}
	}

	@ViewBuilder
	var textFields: some View {
		VStack(spacing: CGFloat(.mediumSpacing)) {
			ForEach(viewModel.inputFields) { field in
				textfield(for: field)
			}
		}
	}

	@ViewBuilder
	func textfield(for inputField: SerialNumberInputField) -> some View {
		VStack(spacing: CGFloat(.minimumSpacing)) {
			HStack {
				Text(inputField.type.description)
					.font(.system(size: CGFloat(.normalFontSize), weight: .bold))
					.foregroundStyle(Color(colorEnum: .text))
				Spacer()
			}

			UberTextField(
				text: Binding(get: { inputField.value },
							  set: { [weak viewModel] newValue in
								  viewModel?.setValue(for: inputField.type, value: newValue)
							  }),
				hint: .constant(inputField.type.placeholder),
				shouldChangeCharactersIn: { [weak viewModel] tf, range, string in
					viewModel?.shouldChangeText(for: inputField.type,
												textfield: tf,
												range: range,
												text: string) ?? true
				},
				configuration: { tf in
					tf.keyboardType = inputField.type.keyboardType
					tf.font = UIFont.systemFont(ofSize: CGFloat(.mediumFontSize), weight: .regular)
					tf.textColor = UIColor(colorEnum: .text)
					tf.prefix = inputField.type.prefix
					tf.autocorrectionType = .no
					tf.autocapitalizationType = inputField.type.autocapitalizationType
					tf.backgroundColor = .clear
				}
			)
			.padding(CGFloat(.mediumSidePadding))
			.strokeBorder(color: Color(colorEnum: .midGrey), lineWidth: 1.0, radius: 5.0)
		}
	}

	@ViewBuilder
	var bottomButton: some View {
		Button {
			viewModel.handleProceedButtonTap()
		} label: {
			Text(LocalizableString.ClaimDevice.enterGatewayProceedButtonTitle.localized)
		}
		.buttonStyle(WXMButtonStyle.filled())
		.padding(.horizontal, CGFloat(.mediumSidePadding))
		.disabled(!viewModel.canProceed)
	}
}

#Preview {
	ManualSerialNumberView(viewModel: ManualSerialNumberPulseViewModel { _ in })
}

#Preview {
	ManualSerialNumberView(viewModel: ManualSerialNumberViewModel { _ in })
}

#Preview {
	ManualSerialNumberView(viewModel: ClaimingKeyPulseViewModel { _ in })
}
