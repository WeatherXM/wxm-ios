//
//  ExplorerLayerPickerView.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 7/5/25.
//

import SwiftUI

struct ExplorerLayerPickerView: View {
	@Binding var selectedOption: ExplorerLayerPickerView.Option

    var body: some View {
		ZStack {
			Color(colorEnum: .top)

			VStack(spacing: CGFloat(.mediumSpacing)) {
				HStack {
					Text(LocalizableString.Explorer.mapLayers.localized)
						.foregroundStyle(Color(colorEnum: .text))
						.font(.system(size: CGFloat(.titleFontSize), weight: .bold))

					Spacer()
				}

				ForEach(Option.allCases) { option in
					viewFor(option: option)
				}
			}
		}
    }
}

extension ExplorerLayerPickerView {
	enum Option: String, CaseIterable, Identifiable {
		var id: String {
			self.rawValue
		}

		case `default`
		case dataQuality
	}
}

private extension ExplorerLayerPickerView {
	@ViewBuilder
	func viewFor(option: Option) -> some View {
		Button {
			self.selectedOption = option
		} label: {
			switch option {
				case .default:
					rowView(title: LocalizableString.Explorer.mapLayersDefault.localized,
							description: LocalizableString.Explorer.mapLayersDefaultDescription.localized,
							isSelected: selectedOption == .default)
				case .dataQuality:
					rowView(title: LocalizableString.Explorer.mapLayersDataQualityScore.localized,
							description: LocalizableString.Explorer.mapLayersDataQualityScoreDescription.localized,
							isSelected: selectedOption == .dataQuality)
			}
		}
		.buttonStyle(.plain)
		.WXMCardStyle(backgroundColor: Color(colorEnum: .layer1),
					  cornerRadius: CGFloat(.smallCornerRadius))
		.if(selectedOption == option) { view in
			view
				.strokeBorder(color: Color(colorEnum: .wxmPrimary), lineWidth: 1.0,
							  radius: CGFloat(.smallCornerRadius))
		}

	}

	@ViewBuilder
	func rowView(title: String, description: String, isSelected: Bool) -> some View {
		HStack(spacing: CGFloat(.mediumSpacing)) {
			ZStack {
				Circle()
					.frame(width: 20.0, height: 20.0)
					.foregroundColor(Color(colorEnum: .bg))

				if isSelected {
					Circle()
						.frame(width: 12.0, height: 12.0)
						.foregroundColor(Color(colorEnum: .wxmPrimary))
				}

			}

			VStack(spacing: CGFloat(.smallSpacing)) {
				HStack {
					Text(title)
						.foregroundStyle(Color(colorEnum: .text))
						.font(.system(size: CGFloat(.largeFontSize), weight: .bold))

					Spacer()
				}

				HStack {
					Text(description)
						.foregroundStyle(Color(colorEnum: .text))
						.font(.system(size: CGFloat(.mediumFontSize)))

					Spacer()
				}
			}
		}
	}
}

#Preview {
	ExplorerLayerPickerView(selectedOption: .constant(.dataQuality))
		.colorScheme(.dark)
		.padding()
}
