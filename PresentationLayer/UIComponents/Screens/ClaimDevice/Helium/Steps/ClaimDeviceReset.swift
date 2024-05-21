//
//  ClaimDeviceReset.swift
//  PresentationLayer
//
//  Created by Manolis Katsifarakis on 29/9/22.
//

import SwiftUI

struct ClaimDeviceReset: View {
    @EnvironmentObject var viewModel: ClaimDeviceViewModel

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
			Color(colorEnum: .newBG)
				.ignoresSafeArea()

			VStack {
				ScrollView {
					VStack(spacing: CGFloat(.largeSpacing)) {
						title

						VStack(spacing: CGFloat(.mediumSpacing)) {

							ClaimDeviceBulletView(bullet: .init(fontIcon: .circleOne,
																text: LocalizableString.ClaimDevice.resetSection1Markdown.localized.attributedMarkdown ?? ""))

							ClaimDeviceBulletView(bullet: .init(fontIcon: .circleTwo,
																text: LocalizableString.ClaimDevice.resetSection2Markdown.localized.attributedMarkdown ?? ""))
						}

						Image(asset: .stationResetSchematic)
							.resizable()
							.aspectRatio(contentMode: .fit)
							.frame(maxWidth: 600.0)
							.padding(.horizontal)
					}
					.padding(.horizontal, CGFloat(.mediumSidePadding))
					.padding(.top, CGFloat(.largeSidePadding))
				}
				.clipped()

				bottomButtons
					.padding(.horizontal, CGFloat(.mediumSidePadding))
			}
        }
    }

    var title: some View {
		HStack {
			Text(LocalizableString.ClaimDevice.resetStationTitle.localized)
				.font(.system(size: CGFloat(.smallTitleFontSize), weight: .bold))
				.foregroundStyle(Color(colorEnum: .darkestBlue))

			Spacer()
		}
    }

    var bottomButtons: some View {
        VStack(spacing: CGFloat(.defaultSpacing)) {
            Button {
                transport.nextStep()
            } label: {
                Text(LocalizableString.ClaimDevice.iVeResetMyDeviceButton.localized)
            }
            .buttonStyle(WXMButtonStyle.filled())
        }
    }
}

private extension ClaimDeviceReset {
    func section(index: Int, markdown: String) -> some View {
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

            Text(markdown.attributedMarkdown!)
                .font(.system(size: CGFloat(.normalFontSize), weight: .regular))
                .foregroundColor(Color(colorEnum: .text))

            Spacer()
        }
        .padding(.bottom, 20)
    }
}
