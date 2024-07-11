//
//  SelectLocationMapView.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 15/5/24.
//

import SwiftUI
import DomainLayer

struct SelectLocationMapView: View {
	@StateObject var viewModel: SelectLocationMapViewModel
	@State private var annotationSize: CGSize = .zero
	@State private var showSearchResults: Bool = false

    var body: some View {
		GeometryReader { proxy in
			ZStack {
				MapBoxClaimDeviceView(location: $viewModel.selectedCoordinate,
									  annotationTitle: Binding(get: { viewModel.selectedDeviceLocation?.name },
															   set: { _ in }),
									  geometryProxyForFrameOfMapView: proxy.frame(in: .local))

				searchArea
			}
		}
    }
}

private extension SelectLocationMapView {
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
					$0.textColor = UIColor(colorEnum: .text)
				}
			)
			.padding(.horizontal, CGFloat(.mediumSidePadding))

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
			.animation(.easeIn, value: showSearchResults)
		}
	}

}

#Preview {
	let useCase = SwinjectHelper.shared.getContainerForSwinject().resolve(DeviceLocationUseCase.self)!
	return SelectLocationMapView(viewModel: .init(useCase: useCase))
}
