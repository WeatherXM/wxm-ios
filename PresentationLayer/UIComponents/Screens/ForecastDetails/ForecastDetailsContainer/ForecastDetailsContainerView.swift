//
//  ForecastDetailsContainerView.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 6/1/26.
//

import SwiftUI
import DomainLayer

struct ForecastDetailsContainerView: View {
    @StateObject var viewModel: ForecastDetailsContainerViewModel

    var body: some View {
        ZStack {
            Color(colorEnum: .topBG)
                .ignoresSafeArea()

            VStack (spacing: CGFloat(.defaultSpacing)) {
                
                if viewModel.viewModels.count > 1 {
                    NavigationTitleView(title: .constant(viewModel.navigationTitle),
                                        subtitle: .constant(viewModel.navigationSubtitle)) {
                        Group {
                            if let faIcon = viewModel.fontIconState {
                                Text(faIcon.icon.rawValue)
                                    .font(.fontAwesome(font: faIcon.font, size: CGFloat(.mediumFontSize)))
                                    .foregroundColor(Color(colorEnum: faIcon.color))
                            } else {
                                EmptyView()
                            }
                        }
                    }.padding(.horizontal, CGFloat(.mediumSidePadding))

                    CustomSegmentView(options: [.init(title: LocalizableString.Forecast.basicForecast.localized),
                                                .init(fontIcon: .sparkles, title: LocalizableString.Forecast.hyperlocal.localized)],
                                      selectedIndex: $viewModel.selectedTabIndex,
                                      style: .buttons)
                    .iPadMaxWidth()
                    .padding(.horizontal)
                    .padding(.top)
                    .zIndex(1)
                }

                TabViewWrapper(selection: $viewModel.selectedTabIndex) {
                    ForEach(0..<viewModel.viewModels.count, id: \.self) { index in
                        let viewModel = viewModel.viewModels[index]
                        ForecastDetailsView(viewModel: viewModel)
                            .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .never))
                .zIndex(0)
                .animation(.easeOut(duration: 0.3), value: viewModel.selectedTabIndex)
            }
        }
    }
}

#Preview {
    let forecasts: [NetworkDeviceForecastResponse] = (0..<6).map { _ in .init(tz: "Europe/Athens", date: "", hourly: (0..<24).map {_ in .mockInstance }, daily: .mockInstance) }
    let configuration = ForecastDetailsViewModel.Configuration(forecasts: forecasts,
                                                               selectedforecastIndex: 0,
                                                               selectedHour: nil,
                                                               device: .mockDevice,
                                                               followState: .init(deviceId: "", relation: .owned))
    return NavigationContainerView {

        ForecastDetailsContainerView(viewModel: ViewModelsFactory.getForecastDetailsContainerViewModel(configuration: configuration,
                                                                                                       premiumConfiguration: configuration))
    }
}
