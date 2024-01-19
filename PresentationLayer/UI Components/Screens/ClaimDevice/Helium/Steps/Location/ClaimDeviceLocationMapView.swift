//
//  ClaimDeviceLocationMapView.swift
//  PresentationLayer
//
//  Created by Manolis Katsifarakis on 15/10/22.
//

import DomainLayer
import MapboxMaps
import SwiftUI
import Toolkit

struct ClaimDeviceLocationMapView: View {
    @EnvironmentObject var viewModel: ClaimDeviceViewModel

    @State private var showSearchResults = false
    @State var stopMapScrolling = false

    var body: some View {
        mapContainer
    }

    var mapContainer: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                MapBoxClaimDeviceView(
                    location: $viewModel.selectedCoordinates,
					annotationTitle: Binding(get: { viewModel.selectedLocation?.name }, set: { _ in }),
                    areLocationServicesAvailable: false,
                    geometryProxyForFrameOfMapView: geometry.frame(in: .global)
                )
                .onTapGesture {
                    showSearchResults = false
                    hideKeyboard()
                }

                searchViews
            }
            .transaction { transaction in
                transaction.animation = nil
            }
        }
    }

    var searchViews: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: CGFloat(.smallSpacing)) {
                    searchField
                    homeLocationButton
                }

                if viewModel.locationSearchResults.count > 0, showSearchResults {
                    searchResults
                }

                Spacer().frame(minHeight: 50)
            }
        }
        .padding()
    }

    @ViewBuilder
    var searchField: some View {
        HStack {
            UberTextField(
                text: $viewModel.locationSearchQuery,
                hint: .constant(LocalizableString.ClaimDevice.confirmLocationSearchHint.localized),
                onEditingChanged: { _, isFocused in showSearchResults = isFocused },
                configuration: {
                    $0.font = UIFont.systemFont(ofSize: FontSizeEnum.normalFontSize.sizeValue)
                    $0.horizontalPadding = 16
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
            RoundedRectangle(cornerRadius: 10)
                .style(withStroke: Color(colorEnum: .midGrey), lineWidth: 1, fill: Color(colorEnum: .top))
        )
        .cornerRadius(10)
    }

    var homeLocationButton: some View {
        Button {
            viewModel.moveToDetectedLocation()
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

    @ViewBuilder
    var searchResults: some View {
        ScrollViewReader { proxy in
            List(viewModel.locationSearchResults, id: \.self) { searchResult in
                Button {
                    viewModel.moveToLocationFromSearchResult(searchResult)
                    showSearchResults = false
                    Logger.shared.trackEvent(.userAction, parameters: [.actionName: .searchLocation,
                                                                       .contentType: .claimingAddressSearch,
                                                                       .location: .custom(searchResult.description)])
                } label: {
                    AttributedLabel(attributedText: .constant(
                        searchResult.attributedDescriptionForQuery(viewModel.locationSearchQuery)
                    ))
                    .font(.system(size: CGFloat(.normalFontSize)))
                    .foregroundColor(Color(colorEnum: .text))
                    .padding(.vertical, 5)
                }
                .buttonStyle(.borderless) // This modifier is necessary for iOS 15 builds. In general buttons inside lists are buggy. SwiftUI 🤌!
                .listRowInsets(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16))
                .listRowBackground(Color(colorEnum: .top))
            }
            .onChange(of: viewModel.locationSearchResults) { newValue in
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

extension DeviceLocationSearchResult {
    func attributedDescriptionForQuery(_ query: String) -> NSAttributedString {
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: CGFloat(FontSizeEnum.normalFontSize))
        ]

        guard let range = description.range(of: query, options: .caseInsensitive) else {
            return NSAttributedString(string: description, attributes: attributes)
        }

        let attributedDescription = NSMutableAttributedString(
            string: description,
            attributes: attributes
        )

        let boldAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: CGFloat(FontSizeEnum.normalFontSize), weight: .bold)
        ]

        attributedDescription.addAttributes(
            boldAttributes,
            range: NSRange(range, in: description)
        )

        return attributedDescription
    }
}
