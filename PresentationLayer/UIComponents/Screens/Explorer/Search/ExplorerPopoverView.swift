//
//  ExplorerPopoverView.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 5/5/25.
//

import SwiftUI

struct ExplorerPopoverView: View {
	@Binding var show: Bool
	@ObservedObject var viewModel: ExplorerSearchViewModel

	var body: some View {
		VStack(spacing: CGFloat(.mediumSpacing)) {
			HStack(spacing: CGFloat(.minimumSpacing)) {
				Spacer()

				Image(asset: .weatherXMLogo)
					.renderingMode(.template)
					.foregroundStyle(Color(colorEnum: .text))

				Text(LocalizableString.weatherXM.localized.uppercased())
					.foregroundStyle(Color(.text))
					.font(.system(size: CGFloat(.smallTitleFontSize), weight: .semibold))

				Spacer()
			}
			.overlay {
				HStack {
					Spacer()

					Button {
						show = false
					} label: {
						Text(FontIcon.close.rawValue)
							.font(.fontAwesome(font: .FAProSolid, size: CGFloat(.smallTitleFontSize)))
							.foregroundColor(Color(colorEnum: .text))
					}
				}
			}

			Group {
				Button {
					show = false
					viewModel.handleNetworkStatsButtonTap()
				} label: {
					HStack(spacing: CGFloat(.minimumSpacing)) {
						VStack(spacing: CGFloat(.smallSpacing)) {
							HStack {
								Text(LocalizableString.NetStats.networkStatistics.localized)
									.font(.system(size: CGFloat(.largeFontSize), weight: .bold))
									.foregroundStyle(Color(colorEnum: .text))

								Spacer()
							}

							HStack {
								Text(LocalizableString.NetStats.networkStatisticsDescription.localized)
									.font(.system(size: CGFloat(.mediumFontSize)))
									.foregroundStyle(Color(colorEnum: .text))
									.multilineTextAlignment(.leading)

								Spacer()
							}
						}

						Spacer()

						Text(FontIcon.chevronRight.rawValue)
							.font(.fontAwesome(font: .FAProSolid, size: CGFloat(.smallTitleFontSize)))
							.foregroundColor(Color(colorEnum: .text))
					}
				}
			}
			.WXMCardStyle(backgroundColor: Color(colorEnum: .layer1),
						  cornerRadius: CGFloat(.smallCornerRadius))
		}
		.WXMCardStyle()
    }
}

#Preview {
	ExplorerPopoverView(show: .constant(true),
						viewModel: ViewModelsFactory.getNetworkSearchViewModel())
		.padding()
}
