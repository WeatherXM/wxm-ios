//
//  ExplorerLayerPickerView.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 7/5/25.
//

import SwiftUI
import Toolkit

struct ExplorerLayerPickerView: View {
	@Binding var show: Bool
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
		.onAppear {
			WXMAnalytics.shared.trackScreen(.mapLayerPicker)
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
	var scoresView: some View {
		HStack {
			VStack(spacing: CGFloat(.minimumSpacing)) {
				Text(FontIcon.hexagon.rawValue)
					.font(.fontAwesome(font: .FAProSolid, size: CGFloat(.largeTitleFontSize)))
					.foregroundStyle(Color(colorEnum: .darkGrey))

				Text(LocalizableString.stationNoDataTitle.localized)
					.font(.system(size: CGFloat(.caption)))
					.foregroundStyle(Color(colorEnum: .text))
			}
			.frame(maxWidth: .infinity)

			ForEach([15, 60, 90], id: \.self) { score in
				VStack(spacing: CGFloat(.minimumSpacing)) {
					Text(FontIcon.hexagon.rawValue)
						.font(.fontAwesome(font: .FAProSolid, size: CGFloat(.largeTitleFontSize)))
						.foregroundStyle(Color(colorEnum: score.rewardScoreColor))

					Text(score.rewardScoreRangeText)
						.font(.system(size: CGFloat(.caption)))
						.foregroundStyle(Color(colorEnum: .text))
				}
				.frame(maxWidth: .infinity)
			}
		}
		.padding(CGFloat(.smallToMediumSidePadding))
		.background(Color(colorEnum: .top))
		.cornerRadius(CGFloat(.lightCornerRadius))
	}

	@ViewBuilder
	func viewFor(option: Option) -> some View {
		Button {
			self.selectedOption = option
			show = false
		} label: {
			switch option {
				case .default:
					rowView(title: LocalizableString.Explorer.mapLayersDefault.localized,
							description: LocalizableString.Explorer.mapLayersDefaultDescription.localized,
							isSelected: selectedOption == .default) {
						EmptyView()
					}
				case .dataQuality:
					rowView(title: LocalizableString.Explorer.mapLayersDataQualityScore.localized,
							description: LocalizableString.Explorer.mapLayersDataQualityScoreDescription.localized,
							isSelected: selectedOption == .dataQuality) {
						scoresView
					}
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
	func rowView(title: String,
				 description: String,
				 isSelected: Bool,
				 @ViewBuilder bottomView: () -> some View) -> some View {
		HStack(spacing: CGFloat(.mediumSpacing)) {
			ZStack {
				Image(asset: isSelected ? .radioButtonActive : .radioButton)
					.renderingMode(.template)
					.foregroundColor(Color(colorEnum: isSelected ? .wxmPrimary : .midGrey))

			}

			VStack(spacing: CGFloat(.defaultSpacing)) {
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

				bottomView()
			}
		}
	}
}

#Preview {
	ExplorerLayerPickerView(show: .constant(true),
							selectedOption: .constant(.dataQuality))
		.padding()
}
