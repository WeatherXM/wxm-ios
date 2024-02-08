//
//  SelectStationLocationView.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 14/12/23.
//

import SwiftUI
import DomainLayer

struct SelectStationLocationView: View {
	@StateObject var viewModel: SelectStationLocationViewModel
	@EnvironmentObject var navigationObject: NavigationObject
	@State private var annotationSize: CGSize = .zero
	@State private var showSearchResults: Bool = false

	var body: some View {
		ZStack {
			Color(colorEnum: .bg)
				.ignoresSafeArea()

			VStack(spacing: 0.0) {
				GeometryReader { proxy in
					ZStack {
						MapBoxClaimDeviceView(location: $viewModel.selectedCoordinate,
											  annotationTitle: Binding(get: { viewModel.selectedDeviceLocation?.name }, set: { _ in }),
											  geometryProxyForFrameOfMapView: proxy.frame(in: .local))
						.cornerRadius(CGFloat(.cardCornerRadius), corners: [.topLeft, .topRight])

						searchArea
					}
				}

				VStack(spacing: CGFloat(.defaultSpacing)) {
					acknowledgementView

					CardWarningView(message: LocalizableString.SelectStationLocation.warningText(DisplayedLinks.polAlgorithm.linkURL).localized,
									closeAction: nil,
									content: { EmptyView() })

					Button {
						viewModel.handleConfirmTap()
					} label: {
						Text(LocalizableString.SelectStationLocation.buttonTitle.localized)
					}
					.buttonStyle(WXMButtonStyle.filled())
					.disabled(!viewModel.termsAccepted)
				}
				.WXMCardStyle(cornerRadius: 0.0)
				.cornerRadius(CGFloat(.cardCornerRadius), corners: [.bottomLeft, .bottomRight])
			}
			.padding(.horizontal, CGFloat(.defaultSidePadding))
			.padding(.bottom, CGFloat(.defaultSidePadding))
			.cornerRadius(CGFloat(.cardCornerRadius), corners: [.topLeft, .topRight])
			.wxmShadow()
			.onTapGesture {
				hideKeyboard()
			}
			.ignoresSafeArea(.keyboard, edges: .bottom)
		}
		.onAppear {
			navigationObject.title = LocalizableString.SelectStationLocation.title.localized
			navigationObject.subtitle = viewModel.device.displayName
			navigationObject.navigationBarColor = Color(colorEnum: .bg)
		}
	}
}

private extension SelectStationLocationView {
	@ViewBuilder
	var acknowledgementView: some View {
		HStack(alignment: .top, spacing: CGFloat(.smallSpacing)) {
			Toggle(LocalizableString.SelectStationLocation.termsText.localized,
				   isOn: $viewModel.termsAccepted)
			.labelsHidden()
			.toggleStyle(WXMToggleStyle.Default)

			Text(LocalizableString.SelectStationLocation.termsText.localized)
				.foregroundColor(Color(colorEnum: .text))
				.font(.system(size: CGFloat(.normalFontSize)))
				.fixedSize(horizontal: false, vertical: true)
		}
	}

	@ViewBuilder
	var markerAnnotation: some View {
		HStack(spacing: CGFloat(.mediumSpacing)) {
			Image(asset: .globe)
				.renderingMode(.template)
				.foregroundColor(Color(colorEnum: .text))

			Text(viewModel.selectedDeviceLocation?.name ?? "")
				.font(.system(size: CGFloat(.normalFontSize)))
		}
		.disabled(true)
		.WXMCardStyle()
		.wxmShadow()
	}

	@ViewBuilder
	var searchArea: some View {
		VStack(spacing: 0.0) {
			HStack {
				searchField

				Button {
					viewModel.moveToUserLocation()
				} label: {
					Image(asset: .detectLocation)
						.renderingMode(.template)
						.foregroundColor(Color(colorEnum: .text))
				}
				.frame(width: 50, height: 50)
				.background(
					RoundedRectangle(cornerRadius: 10)
						.style(withStroke: Color(colorEnum: .midGrey), lineWidth: 1, fill: Color(colorEnum: .top))
				)

			}
			Spacer(minLength: 0.0)
			if showSearchResults, !viewModel.searchResults.isEmpty {
				searchResults
			}
		}
		.padding(CGFloat(.defaultSidePadding))
	}

	@ViewBuilder
	var searchField: some View {
		HStack {
			UberTextField(
				text: $viewModel.searchTerm,
				hint: .constant(LocalizableString.SelectStationLocation.searchPlaceholder.localized),
				onEditingChanged: { _, isFocused in showSearchResults = isFocused },
				configuration: {
					$0.font = UIFont.systemFont(ofSize: FontSizeEnum.normalFontSize.sizeValue)
					$0.horizontalPadding = CGFloat(.mediumSidePadding)
					$0.textColor = UIColor(colorEnum: .text)
				}
			)

			WXMDivider()
				.padding(.vertical, 4)

			Image(asset: .search)
				.renderingMode(.template)
				.foregroundColor(Color(colorEnum: .text))
				.padding(.trailing, 9)
		}
		.frame(height: 50)
		.background(
			RoundedRectangle(cornerRadius: CGFloat(.buttonCornerRadius))
				.style(withStroke: Color(colorEnum: .midGrey), lineWidth: 1.0, fill: Color(colorEnum: .top))
		)
		.cornerRadius(CGFloat(.buttonCornerRadius))
	}

	@ViewBuilder
	var searchResults: some View {
		ScrollViewReader { proxy in
			List(viewModel.searchResults, id: \.self) { searchResult in
				Button {
					viewModel.handleSearchResultTap(result: searchResult)
					hideKeyboard()
					showSearchResults = false
				} label: {
					AttributedLabel(attributedText: .constant(
						searchResult.attributedDescriptionForQuery(viewModel.searchTerm)
					))
					.font(.system(size: CGFloat(.normalFontSize)))
					.foregroundColor(Color(colorEnum: .text))
					.padding(.vertical, 5)
				}
				.buttonStyle(.borderless) // This modifier is necessary for iOS 15 builds. In general buttons inside lists are buggy. SwiftUI 🤌!
				.listRowInsets(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16))
				.listRowBackground(Color(colorEnum: .top))
			}
			.onChange(of: viewModel.searchResults) { newValue in
				if let firstLocation = newValue.first {
					proxy.scrollTo(firstLocation, anchor: .top)
				}
			}
			.environment(\.defaultMinListRowHeight, 0)
			.listStyle(.plain)
			.cornerRadius(10)
			.background(
				RoundedRectangle(cornerRadius: 10)
					.style(withStroke: Color(colorEnum: .midGrey), lineWidth: 1, fill: Color(colorEnum: .top))
			)
			.animation(nil)
		}
	}

}

#Preview {
	let device = DeviceDetails.mockDevice
	let viewModel = ViewModelsFactory.getSelectLocationViewModel(device: device,
																 followState: .init(deviceId: device.id!, relation: .owned),
																 delegate: nil)
	return NavigationContainerView {
		SelectStationLocationView(viewModel: viewModel)
	}
}
