//
//  FilterView.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 15/9/23.
//

import SwiftUI
import DomainLayer
import Toolkit

struct FilterView: View {
    @Binding var show: Bool
    @StateObject var viewModel: FilterViewModel

    var body: some View {
        VStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: CGFloat(.defaultSpacing)) {
                    HStack {
                        Text(LocalizableString.Filters.title.localized)
                            .font(.system(size: CGFloat(.titleFontSize), weight: .bold))
                            .foregroundStyle(Color(colorEnum: .darkestBlue))

                        Spacer()
                    }

                    section(title: SortBy.title,
                            options: SortBy.allCases,
                            selected: viewModel.selectedSortBy)
                    section(title: Filter.title,
                            options: Filter.allCases,
                            selected: viewModel.selectedFilter)
                    section(title: GroupBy.title,
                            options: GroupBy.allCases,
                            selected: viewModel.selectedGroupBy)
                }
                .padding(CGFloat(.defaultSidePadding))
            }

            bottomButtons
                .padding(CGFloat(.defaultSidePadding))
        }
        .onAppear {
            WXMAnalytics.shared.trackScreen(.sortFilter)
        }
    }
}

private extension FilterView {
    @ViewBuilder
    var bottomButtons: some View {
        HStack {
            Button {
                viewModel.handleResetTap()
            } label: {
                Text(LocalizableString.Filters.reset.localized)
            }
            .buttonStyle(WXMButtonStyle.plain(fixedSize: true))

            Spacer()

            PercentageGridLayoutView(alignments: [.center, .center], firstColumnPercentage: 0.5) {
                Group {
                    Button {
                        WXMAnalytics.shared.trackEvent(.userAction,
                                                 parameters: [.actionName: .filtersCancel])
                        show = false
                    } label: {
                        Text(LocalizableString.cancel.localized)
                    }
                    .buttonStyle(WXMButtonStyle.plain(fixedSize: true))

                    Button {
                        viewModel.handleSaveTap()
                        show = false
                    } label: {
                        Text(LocalizableString.save.localized)
                            .padding(.vertical, CGFloat(.smallSidePadding))
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(WXMButtonStyle.filled(fixedSize: true))
                    .disabled(!viewModel.isSaveEnabled)
                }
            }
        }
    }

    @ViewBuilder
    func section(title: String, options: [some FilterPresentable], selected: some FilterPresentable) -> some View {
        VStack(spacing: CGFloat(.mediumSpacing)) {
            HStack {
                Text(title)
                    .font(.system(size: CGFloat(.largeFontSize), weight: .bold))
                    .foregroundStyle(Color(colorEnum: .darkestBlue))

                Spacer()
            }

            ForEach(options, id: \.self.description) { option in
                Button {
                    viewModel.handleTapOn(filterPresentable: option)
                } label: {
                    HStack(spacing: CGFloat(.smallSpacing)) {
                        let isSelected = option.description == selected.description
                        Image(asset: isSelected ? .radioButtonActive : .radioButton)
                            .renderingMode(.template)
                            .foregroundColor(Color(colorEnum: isSelected ? .wxmPrimary : .midGrey))
                        Text(option.description)
                            .font(.system(size: CGFloat(.normalFontSize)))
                            .foregroundColor(Color(colorEnum: .text))
                        Spacer()
                    }
                }

            }
        }
    }
}

#Preview {
    FilterView(show: .constant(true), viewModel: ViewModelsFactory.getFilterViewModel())
}
