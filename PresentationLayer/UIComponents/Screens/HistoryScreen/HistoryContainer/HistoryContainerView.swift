//
//  HistoryContainerView.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 7/9/23.
//

import SwiftUI
import Toolkit
import DomainLayer
import LazyLoadingPager

struct HistoryContainerView: View {
    @StateObject var viewModel: HistoryContainerViewModel
    @State private var showCalendarPopOver: Bool = false
	@State private var containerSize: CGSize = .zero

    var body: some View {
        NavigationContainerView {
            navigationBarRightView
        } content: {
            HistoryPagerView(viewModel: viewModel)
        }
		.sizeObserver(size: $containerSize)
		.onChange(of: containerSize) { _ in
			showCalendarPopOver = false
		}
    }

    @ViewBuilder
    var navigationBarRightView: some View {
        Button {
            showCalendarPopOver = true
        } label: {
            Text(FontIcon.calendar.rawValue)
                .font(.fontAwesome(font: .FAProSolid, size: CGFloat(.mediumFontSize)))
                .foregroundColor(Color(colorEnum: .primary))
                .frame(width: 30.0, height: 30.0)
        }
		.modify { [weak viewModel] btn in
			let picker = DatePicker("",
								  selection: Binding(get: { [weak viewModel] in
				viewModel?.currentDate ?? .now
			},
													 set: { [weak viewModel] value in
				guard let fixedDate = viewModel?.historyDates.getFixedDate(from: value) else {
					return
				}

				showCalendarPopOver = false

				DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
					viewModel?.currentDate = fixedDate
				}
			}),
								  in: viewModel!.historyDates.range,
								  displayedComponents: [.date])
				.datePickerStyle(.graphical)
				.labelsHidden()

			if containerSize.width >= iPadElementMaxWidth {
				btn.wxmPopOver(show: $showCalendarPopOver) {
					HStack {
						picker
					}
					.frame(width: 450.0)
				}
			} else {
				btn.bottomSheet(show: $showCalendarPopOver) {
					picker
				}
			}
		}
    }
}

private struct HistoryPagerView: View {

    @StateObject var viewModel: HistoryContainerViewModel
    @EnvironmentObject var navigationObject: NavigationObject

    var body: some View {
        ZStack {
            Color(colorEnum: .bg)
                .edgesIgnoringSafeArea(.all)

            VStack(spacing: 0.0) {
                dateCarousel
                    .zIndex(1)

                ZStack {
                    LazyLoadingPagerView(data: $viewModel.currentDate) { _ in
                        HistoryView(viewModel: ViewModelsFactory.getHistoryViewModel(device: viewModel.device,
                                                                                     date: viewModel.currentDate))
                    } previous: { date in
                        guard let previousDate = viewModel.historyDates.getPreviousDate(from: date) else {
                            return nil
                        }
                        return HistoryView(viewModel: ViewModelsFactory.getHistoryViewModel(device: viewModel.device,
                                                                                            date: previousDate))

                    } next: { date in
                        guard let nextDate = viewModel.historyDates.getNextDate(from: date) else {
                            return nil
                        }
                        return HistoryView(viewModel: ViewModelsFactory.getHistoryViewModel(device: viewModel.device,
                                                                                            date: nextDate))
                    } previousData: { date in
                        viewModel.historyDates.getPreviousDate(from: date)
                    } nextData: { date in
                        viewModel.historyDates.getNextDate(from: date)
                    } scrollDirection: { fromData, toData in
                        fromData < toData ? .forward : .reverse
                    }
                    .zIndex(0)
                }
            }
        }
        .onAppear {
            if let date = viewModel.historyDates.last {
                viewModel.handleDateTap(date: date)
            }
            navigationObject.title = LocalizableString.historyTitle.localized
            navigationObject.subtitle = viewModel.device.address
            WXMAnalytics.shared.trackScreen(.history)
        }
        .onChange(of: viewModel.currentDate) { value in
            print("Current date \(value)")
        }
    }
}

private extension HistoryPagerView {
    @ViewBuilder
    var dateCarousel: some View {
		HStack {
			Spacer(minLength: 0.0)

			ScrollingPickerView(selectedIndex: Binding(get: {
				guard let index = viewModel.historyDates.getIndexOfDate(viewModel.currentDate) else {
					return 0
				}
				return viewModel.historyDates.distance(from: viewModel.historyDates.startIndex, to: index)
			}, set: { value in
				let date = viewModel.historyDates[.inRange(value)]
				viewModel.currentDate = date
			}), textCallback: { index in
				viewModel.historyDates[.inRange(index)].getDateStringRepresentation()
			}, countCallback: {
				viewModel.historyDates.count
			})
			.iPadMaxWidth()

			Spacer(minLength: 0.0)
		}
        .background {
            Color(colorEnum: .top)
        }
        .cornerRadius(CGFloat(.cardCornerRadius),
                      corners: [.bottomLeft, .bottomRight])
        .wxmShadow()
    }
}

#Preview {
        HistoryContainerView(viewModel: ViewModelsFactory.getHistoryContainerViewModel(device: DeviceDetails.emptyDeviceDetails))
}
