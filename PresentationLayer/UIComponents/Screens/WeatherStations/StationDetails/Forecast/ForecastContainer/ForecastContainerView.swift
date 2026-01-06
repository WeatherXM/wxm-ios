//
//  ForecastContainerView.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 31/12/25.
//

import SwiftUI

struct ForecastContainerView: View {
    @StateObject var viewModel: ForecastContainerViewModel

    var body: some View {
        ZStack {
            Color(colorEnum: .bg)
                .ignoresSafeArea()

            VStack (spacing: CGFloat(.largeSpacing)) {
                if viewModel.isSubscribed {
                    CustomSegmentView(options: [.init(title: LocalizableString.Forecast.basicForecast.localized),
                                                .init(fontIcon: .sparkles, title: LocalizableString.Forecast.hyperlocal.localized)],
                                      selectedIndex: $viewModel.selectedTabIndex,
                                      style: .buttons)
                    .iPadMaxWidth()
                    .padding(.horizontal)
                    .padding(.top)
                    .zIndex(1)
                }

                TabViewWrapper(selection: $viewModel.selectedTabIndex, content: {
                    ForEach(0..<viewModel.viewModels.count, id: \.self) { index in
                        let viewModel = viewModel.viewModels[index]
                        StationForecastView(viewModel: viewModel)
                            .tag(index)
                    }
                })
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .never))
                .zIndex(0)
                .animation(.easeOut(duration: 0.3), value: viewModel.selectedTabIndex)
            }
        }

    }
}

#Preview {
    ForecastContainerView(viewModel: ViewModelsFactory.getForecastContainerViewModel(delegate: nil))
}
