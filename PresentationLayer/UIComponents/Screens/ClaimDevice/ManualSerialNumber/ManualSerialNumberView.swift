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
			Color(colorEnum: .newBG)
				.ignoresSafeArea()
			VStack {
				ScrollView(showsIndicators: false) {
					VStack(spacing: CGFloat(.largeSpacing)) {
						HStack {
							Text(LocalizableString.ClaimDevice.enterGatewayDetailsTitle.localized)
								.font(.system(size: CGFloat(.smallTitleFontSize), weight: .bold))
								.foregroundStyle(Color(colorEnum: .darkestBlue))

							Spacer()
						}

						HStack {
							Text(LocalizableString.ClaimDevice.enterGatewayDetailsDescription.localized.attributedMarkdown ?? "")
								.foregroundStyle(Color(colorEnum: .text))
								.font(.system(size: CGFloat(.normalFontSize)))

							Spacer()
						}

						Group {
							if let image = viewModel.image {
								Image(asset: image)
							}

							if let gifFile = viewModel.gifFile {
								GifImageView(fileName: gifFile)
							}
						}
						.aspectRatio(1.0, contentMode: .fit)

						textFields
					}
					.padding(.horizontal, CGFloat(.mediumSidePadding))
					.padding(.top, CGFloat(.largeSidePadding))
				}
				.clipped()

				bottomButton
			}
		}
    }
}

private extension ManualSerialNumberView {
	@ViewBuilder
	var textFields: some View {
		VStack(spacing: CGFloat(.mediumSpacing)) {
			TextField("123", text: .constant(""))
				.font(.system(size: CGFloat(.normalFontSize)))
				.foregroundStyle(Color(colorEnum: .text))
				.padding(CGFloat(.mediumSidePadding))
				.strokeBorder(color: Color(colorEnum: .midGrey), lineWidth: 1.0, radius: 5.0)

		}
	}

	@ViewBuilder
	var bottomButton: some View {
		Button {
		} label: {
			Text(LocalizableString.ClaimDevice.enterGatewayProceedButtonTitle.localized)
		}
		.buttonStyle(WXMButtonStyle.filled())
		.padding(.horizontal, CGFloat(.mediumSidePadding))
		.disabled(true)
	}
}

#Preview {
	ManualSerialNumberView(viewModel: ManualSerialNumberM5ViewModel())
}

#Preview {
	ManualSerialNumberView(viewModel: ManualSerialNumberViewModel())
}
