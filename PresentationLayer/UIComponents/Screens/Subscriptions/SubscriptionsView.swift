//
//  SubscriptionsView.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 7/11/25.
//

import SwiftUI
import StoreKit

struct SubscriptionsView: View {
	@StateObject var viewModel: SubscriptionsViewModel
	@EnvironmentObject var navigationObject: NavigationObject

    var body: some View {
		ZStack {
			Color(colorEnum: .bg)
				.ignoresSafeArea()
			VStack {
                if !viewModel.segments.isEmpty {
                    CustomSegmentView(options: viewModel.segments.map { .init(title: $0) },
                                      selectedIndex: $viewModel.currentTabIndex,
                                      style: .buttons)
                    .padding(.horizontal, CGFloat(.mediumSidePadding))
                    .padding(.top, CGFloat(.mediumSidePadding))
                }

                TabViewWrapper(selection: $viewModel.currentTabIndex) {
                    ForEach(Array(viewModel.plans.enumerated()), id: \.offset) { index, plans in
                        plansView(for: plans)
                            .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .never))
                .zIndex(0)
                .animation(.easeOut(duration: 0.3), value: viewModel.currentTabIndex)


				Button {
					viewModel.continueButtonTapped()
				} label: {
                    HStack(spacing: CGFloat(.smallToMediumSpacing)) {
                        Text(FontIcon.sparkles.rawValue)
                            .font(.fontAwesome(font: .FAPro, size: CGFloat(.largeFontSize)))
                        Text(LocalizableString.Subscriptions.upgradeToPremium.localized)
                    }
				}
				.buttonStyle(WXMButtonStyle.filled())
				.padding(CGFloat(.mediumSidePadding))
				.disabled(!viewModel.isCTAEnabled)
				.iPadMaxWidth()
			}
			.spinningLoader(show: $viewModel.isLoading)
			.success(show: $viewModel.isSuccess, obj: viewModel.failSuccessObject)
			.fail(show: $viewModel.isFailed, obj: viewModel.failSuccessObject)
		}
		.task {
			await viewModel.refresh()
		}
		.onAppear {
			navigationObject.title = LocalizableString.Subscriptions.upgradeToPremium.localized
            navigationObject.subtitle = LocalizableString.Subscriptions.getMostAccurateForecasts.localized
		}
    }
}

private extension SubscriptionsView {
    @ViewBuilder
    func plansView(for plans: [SubscriptionPlanView.Plan]) -> some View {
        ScrollView {
            VStack(spacing: CGFloat(.mediumSpacing)) {

                ForEach(plans) { plan in
                    Button {
                        viewModel.selectedPlan = plan
                    } label: {
                        SubscriptionPlanView(plan: plan, isSelected: viewModel.selectedPlan == plan)
                    }
                }
            }
            .padding(CGFloat(.mediumSidePadding))
            .iPadMaxWidth()
        }
        .scrollIndicators(.hidden)
        .refreshable {
            await viewModel.refresh()
        }
    }
}

#Preview {
	NavigationContainerView {
		SubscriptionsView(viewModel: ViewModelsFactory.getSubscriptionsViewModel())
	}
}

