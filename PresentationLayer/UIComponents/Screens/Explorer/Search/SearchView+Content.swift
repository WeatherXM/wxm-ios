//
//  SearchView+Content.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 21/6/23.
//

import SwiftUI
import CoreLocation
import Toolkit

extension SearchView {
    struct Row: Identifiable {
        var id: String {
            "\(icon?.rawValue ?? "")-\(fontIcon?.rawValue ?? "")-\(title)-\(subtitle ?? "")-\(String(describing: networkModel))"
        }
        var icon: AssetEnum?
        var fontIcon: FontIcon?
        let title: AttributedString
        let subtitle: String?
        let networkModel: NetworkSearchModel?
    }

    @ViewBuilder
    var nonActiveView: some View {
        VStack {
            HStack(spacing: CGFloat(.mediumSpacing)) {
                Image(asset: .xmSearchLogo)

                TextField("",
                          text: $term,
                          prompt: Text(LocalizableString.Search.fieldPlaceholder.localized).foregroundColor(Color(colorEnum: .darkGrey)))
                .font(.system(size: CGFloat(.mediumFontSize)))
                .tint(Color(colorEnum: .text))
                .foregroundColor(Color(colorEnum: .text))
                .focused($noActiveTextfieldIsFocused)
                .onChange(of: noActiveTextfieldIsFocused) { newValue in
                    // This hacky way is to avoid interaction with the outer textfield
                    noActiveTextfieldIsFocused = false
                    if newValue {
                        viewModel.isSearchActive = true
                    }
                }

                Spacer()

                if shouldShowSettingsButton {
                    Button {
                        WXMAnalytics.shared.trackEvent(.userAction, parameters: [.actionName: .explorerPopUp])
                        showSettingsPopOver = true
                    } label: {
                        Text(FontIcon.threeDots.rawValue)
							.font(.fontAwesome(font: .FAProSolid, size: CGFloat(.smallTitleFontSize)))
                            .foregroundColor(Color(colorEnum: .darkGrey))
                            .padding(.horizontal, CGFloat(.smallSidePadding))
                    }
                    .background(Color(colorEnum: .top))
                    .wxmPopOver(show: $showSettingsPopOver) {
						VStack {
							Button {
								showSettingsPopOver = false
								viewModel.handleSettingsButtonTap()
							} label: {
								Text(LocalizableString.settings.localized)
									.font(.system(size: CGFloat(.mediumFontSize)))
									.foregroundColor(Color(colorEnum: .text))
							}
						}
						.padding()
						.background(Color(colorEnum: .top).scaleEffect(2.0).ignoresSafeArea())
                    }
                }
            }
			.padding(.vertical, CGFloat(.mediumSidePadding))
            .padding(.horizontal, CGFloat(.defaultSidePadding))
            .background(Capsule().foregroundColor(Color(colorEnum: .top)))
            .compositingGroup()
            .wxmShadow()
            .padding(CGFloat(.defaultSidePadding))
            .animation(.easeIn(duration: 0.2),
                       value: term)

            Spacer()
        }
    }

    @ViewBuilder
    var activeView: some View {
        ZStack {
            Color(colorEnum: .top)
                .ignoresSafeArea()

            VStack(spacing: 0.0) {
                HStack(spacing: CGFloat(.defaultSpacing)) {
                    Button {
                        WXMAnalytics.shared.trackEvent(.userAction, parameters: [.actionName: .explorerSearch])
                        isFocused = false
                        viewModel.isSearchActive = false
                    } label: {
                        Image(asset: .backArrow)
                            .renderingMode(.template)
                            .tint(Color(colorEnum: .text))
                    }

                    TextField("",
                              text: $term, prompt: Text(LocalizableString.Search.fieldPlaceholder.localized).foregroundColor(Color(colorEnum: .darkGrey)))
                    .textFieldClearButton(text: $term,
                                          isLoading: $viewModel.isLoading,
                                          icon: .clearIcon)
                    .submitLabel(.search)
                    .onSubmit {
                        viewModel.handleSubmitButtonTap()
                    }
                    .focused($isFocused)
                    .font(.system(size: CGFloat(.mediumFontSize)))
                    .tint(Color(colorEnum: .text))
                    .foregroundColor(Color(colorEnum: .text))
                }
				.padding(.vertical, CGFloat(.mediumSidePadding))
                .padding(.leading, CGFloat(.defaultSidePadding))
                .padding(.trailing, CGFloat(.smallToMediumSpacing))
                .overlay {
                    Capsule().stroke(lineWidth: 1.0).foregroundColor(Color(colorEnum: .darkGrey))
                }
                .padding(CGFloat(.defaultSidePadding))
                .animation(.easeIn(duration: 0.1),
                           value: term)

                ScrollView {
					VStack(spacing: CGFloat(.largeSpacing)) {
                        if viewModel.isShowingRecent {
                            HStack {
                                Text(LocalizableString.Search.resultsRecent.localized)
                                    .font(.system(size: CGFloat(.largeFontSize), weight: .bold))
                                    .foregroundColor(Color(colorEnum: .text))

                                Spacer()
                            }
                        }

                        if viewModel.showNoResults {
                            noResultsView
								.padding(.top, viewModel.isShowingRecent ? CGFloat(.smallSidePadding) : CGFloat(.XLSidePadding))
                        } else {
                            ForEach(viewModel.searchResults) { result in
                                Button {
                                    isFocused = false
                                    term.removeAll()
                                    viewModel.handleTapOnResult(result)
                                } label: {
                                    rowView(row: result)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 36.0)
                }
            }
        }
    }
    
    @ViewBuilder
    func rowView(row: Row) -> some View {
		HStack(spacing: CGFloat(CGFloat(.mediumSpacing))) {
            ZStack {
                if let icon = row.icon {
                    Image(asset: icon)
                        .renderingMode(.template)
                } else if let fontIcon = row.fontIcon {
                    Text(fontIcon.rawValue)
						.font(.fontAwesome(font: .FAPro, size: CGFloat(.mediumFontSize)))
                }
            }
            .foregroundColor(Color(colorEnum: .text))
            .frame(width: 40.0, height: 40.0)
            .background(Circle().foregroundColor(Color(colorEnum: .layer1)))

            VStack(alignment: .leading, spacing: 0.0) {
                Text(row.title)
                    .foregroundColor(Color(colorEnum: .darkGrey))
                    .font(.system(size: CGFloat(.mediumFontSize)))
                    .multilineTextAlignment(.leading)

                if let subtitle = row.subtitle {
                    Text(subtitle)
                        .foregroundColor(Color(colorEnum: .darkGrey))
                        .font(.system(size: CGFloat(.normalFontSize)))
                        .multilineTextAlignment(.leading)
                }
            }

            Spacer()
        }
    }

    @ViewBuilder
    var noResultsView: some View {
		VStack(spacing: CGFloat(.smallSpacing)) {
            Text(viewModel.isShowingRecent ? LocalizableString.Search.noRecentResultsTitle.localized : LocalizableString.Search.noResultsTitle.localized)
                .font(.system(size: CGFloat(.smallTitleFontSize), weight: .bold))
                .foregroundColor(Color(colorEnum: .text))

            Text(viewModel.isShowingRecent ? LocalizableString.Search.noRecentResultsSubtitle.localized : LocalizableString.Search.noResultsSubtitle.localized)
                .font(.system(size: CGFloat(.normalFontSize)))
                .foregroundColor(Color(colorEnum: .text))
        }
        .multilineTextAlignment(.center)
    }
}
