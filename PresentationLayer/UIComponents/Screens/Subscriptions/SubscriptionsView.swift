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
                switch viewModel.viewState {
                    case .free(let plans):
                        freeStateView(plans: plans)
                    case .premium(let plans):
                        plansView(for: plans)
                }

				Button {
					viewModel.continueButtonTapped()
				} label: {
                    HStack(spacing: CGFloat(.smallToMediumSpacing)) {
                        if let fontIcon = viewModel.ctaFontIcon {
                            Text(fontIcon.rawValue)
                                .font(.fontAwesome(font: .FAPro, size: CGFloat(.largeFontSize)))
                        }

                        Text(viewModel.ctaText)
                    }
				}
                .buttonStyle(WXMButtonStyle.filled(textColor: .textWhite, fillColor: viewModel.ctaBackgroundColor))
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
        .wxmAlert(show: $viewModel.showDowngradeAlert) {
            WXMAlertView(show: $viewModel.showDowngradeAlert,
                         configuration: viewModel.downgradeAlertConfiguration!) {
                EmptyView()
            }
        }

    }
}

extension SubscriptionsView {
    enum State {
        case free([[SubscriptionPlanView.Plan]])
        case premium([SubscriptionPlanView.Plan])
    }
}

private extension SubscriptionsView {
    @ViewBuilder
    func freeStateView(plans: [[SubscriptionPlanView.Plan]]) -> some View {
        VStack(spacing: 0) {
            if !viewModel.segments.isEmpty {
                CustomSegmentView(options: viewModel.segments.map { .init(title: $0) },
                                  selectedIndex: $viewModel.currentTabIndex,
                                  style: .buttons)
                .overlay {
                    if let badge = viewModel.badgeText {
                        VStack {
                            HStack(alignment: .top) {
                                Spacer()

                                Text(badge)
                                    .font(.system(size: CGFloat(.littleCaption), weight: .bold))
                                    .foregroundStyle(Color(colorEnum: .darkBg))
                                    .padding(.horizontal, CGFloat(.smallSidePadding))
                                    .padding(.vertical, 2.0)
                                    .background {
                                        Capsule()
                                            .fill(Color(colorEnum: .success))
                                    }
                            }

                            Spacer()
                        }
                        .offset(CGSize(width: 0.0, height: -CGFloat(.smallSidePadding)))
                    }
                }

                .padding(.horizontal, CGFloat(.mediumSidePadding))
                .padding(.top, CGFloat(.mediumSidePadding))
            }

            TabViewWrapper(selection: $viewModel.currentTabIndex) {
                ForEach(Array(plans.enumerated()), id: \.offset) { index, plans in
                    plansView(for: plans)
                        .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .never))
            .zIndex(0)
            .animation(.easeOut(duration: 0.3), value: viewModel.currentTabIndex)
        }
    }

    @ViewBuilder
    func plansView(for plans: [SubscriptionPlanView.Plan]) -> some View {
        ScrollView {
            VStack(spacing: CGFloat(.mediumSpacing)) {

                ForEach(plans) { plan in
                    Button {
                        viewModel.selectedPlan = plan
                    } label: {
                        SubscriptionPlanView(plan: plan,
                                             isSelected: viewModel.selectedPlan == plan)
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

