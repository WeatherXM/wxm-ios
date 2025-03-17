//
//  AnalyticsView.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 19/5/23.
//

import SwiftUI

struct AnalyticsView: View {
    @Binding var show: Bool
    @StateObject var viewModel: AnalyticsViewModel
    @State private var bottomButtonsSize: CGSize = .zero

    var body: some View {
        ZStack {
            Color(colorEnum: .top)
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: CGFloat(.largeSpacing)) {
                    Spacer()

                    VStack(spacing: CGFloat(.defaultSpacing)) {
                        Image(asset: .analyticsIcon)
                            .renderingMode(.template)
                            .foregroundColor(Color(colorEnum: .darkGrey))
                            .padding(CGFloat(.XLSidePadding))
                            .background {
                                Circle()
                                    .foregroundColor(Color(colorEnum: .layer1))
                            }

                        VStack(spacing: CGFloat(.smallSpacing)) {
                            Text(LocalizableString.Analytics.title.localized)
                                .foregroundColor(Color(colorEnum: .darkestBlue))
                                .font(.system(size: CGFloat(.largeTitleFontSize), weight: .bold))

                            Text(LocalizableString.Analytics.description.localized.attributedMarkdown ?? "")
                                .multilineTextAlignment(.center)
                                .foregroundColor(Color(colorEnum: .text))
                                .font(.system(size: CGFloat(.normalFontSize)))

                        }

                    }
                    .padding(.horizontal, CGFloat(.defaultSidePadding))

                    VStack(spacing: CGFloat(.XLSpacing)) {
                        collectView

                        captionView
                    }
                    .padding(.horizontal, CGFloat(.XLSidePadding))
                }
				.iPadMaxWidth()
            }
            .padding(.bottom, bottomButtonsSize.height)

            VStack {
                Spacer()

                bottomButtons
					.iPadMaxWidth()
                    .padding(CGFloat(.defaultSidePadding))
                    .sizeObserver(size: $bottomButtonsSize)
            }
        }
    }
}

private extension AnalyticsView {
    @ViewBuilder
    var collectView: some View {
        LazyVGrid(columns: [GridItem(), GridItem()]) {
            VStack(alignment: .leading, spacing: CGFloat(.smallSpacing)) {
                HStack {
                    Text(LocalizableString.Analytics.whatWeCollect.localized)
                        .foregroundColor(Color(colorEnum: .darkestBlue))
                        .font(.system(size: CGFloat(.mediumFontSize), weight: .bold))
                        .fixedSize(horizontal: true, vertical: false)

                    Spacer()
                }

                let fields: [LocalizableString.Analytics] = [.appUsage, .systemVerion]
                ForEach(fields, id: \.self) { field in
                    HStack(spacing: CGFloat(.minimumSpacing)) {
                        Image(asset: .toggleCheckmark)
                            .renderingMode(.template)
                            .foregroundColor(Color(colorEnum: .top))
                            .frame(width: 20.0, height: 20.0)
                            .background {
                                Circle().foregroundColor(Color(colorEnum: .text))
                            }

                        Text(field.localized)
                            .foregroundColor(Color(colorEnum: .text))
                            .font(.system(size: CGFloat(.normalFontSize)))
                            .fixedSize(horizontal: true, vertical: false)

                        Spacer()
                    }
                }
            }

            VStack(alignment: .leading, spacing: CGFloat(.smallSpacing)) {
                HStack {
                    Text(LocalizableString.Analytics.whatWeDontCollect.localized)
                        .foregroundColor(Color(colorEnum: .darkestBlue))
                        .font(.system(size: CGFloat(.mediumFontSize), weight: .bold))
                        .fixedSize(horizontal: true, vertical: false)
                    Spacer()
                }

                let fields: [LocalizableString.Analytics] = [.personalData, .identifyingInfo]
                ForEach(fields, id: \.self) { field in
                    HStack(spacing: CGFloat(.minimumSpacing)) {
                        Image(asset: .toggleXMark)
                            .renderingMode(.template)
                            .foregroundColor(Color(colorEnum: .top))
                            .frame(width: 20.0, height: 20.0)
                            .background {
                                Circle().foregroundColor(Color(colorEnum: .text))
                            }

                        Text(field.localized)
                            .foregroundColor(Color(colorEnum: .text))
                            .font(.system(size: CGFloat(.normalFontSize)))
                            .fixedSize(horizontal: true, vertical: false)

                        Spacer()
                    }
                }
            }
        }
    }

    @ViewBuilder
    var captionView: some View {
        HStack(spacing: CGFloat(.smallSpacing)) {
            Image(asset: .accountFilledIcon)
                .renderingMode(.template)
                .foregroundColor(Color(colorEnum: .darkGrey))
                .padding(CGFloat(.minimumPadding))
                .background {
                    Circle()
                        .foregroundColor(Color(colorEnum: .bg))
                }

            Text(LocalizableString.Analytics.caption.localized)
                .foregroundColor(Color(colorEnum: .text))
                .font(.system(size: CGFloat(.normalFontSize)))

            Spacer()
        }
        .padding(CGFloat(.smallSidePadding))
        .background {
            Capsule()
                .foregroundColor(Color(colorEnum: .layer1))
        }
    }

    @ViewBuilder
    var bottomButtons: some View {
        HStack(spacing: CGFloat(.defaultSpacing)) {
            Button {
                viewModel.denyButtonTapped()
                show.toggle()
            } label: {
                Text(LocalizableString.deny.localized)
            }
            .buttonStyle(WXMButtonStyle())

            Button {
                viewModel.soundsGoodButtonTapped()
                show.toggle()
            } label: {
                Text(LocalizableString.soundsGood.localized)
            }
            .buttonStyle(WXMButtonStyle.filled())
        }
    }
}

struct AnalyticsView_Previews: PreviewProvider {
    static var previews: some View {
        AnalyticsView(show: .constant(true),
                      viewModel: ViewModelsFactory.getAnalyticsViewModel())
    }
}
