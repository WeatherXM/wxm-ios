//
//  ChangeFrequencyView.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 13/3/23.
//

import SwiftUI
import DomainLayer
import Toolkit

struct ChangeFrequencyView: View {
    @StateObject var viewModel: ChangeFrequencyViewModel
    @EnvironmentObject var navigationObject: NavigationObject
    @Environment(\.dismiss) private var dismiss

    var body: some View {

        ZStack {
            Color(colorEnum: .top)
                .ignoresSafeArea()
			GeometryReader { _ in
				VStack {
					if viewModel.state == .setFrequency {
						VStack(spacing: 0.0) {
							SelectFrequencyView(selectedFrequency: $viewModel.selectedFrequency,
												isFrequencyAcknowledged: $viewModel.isFrequencyAcknowledged)

							HStack(spacing: CGFloat(.mediumSpacing)) {
								Button {
									viewModel.cancelButtonTapped()
								} label: {
									Text(LocalizableString.cancel.localized)
								}
								.buttonStyle(WXMButtonStyle())

								Button {
									viewModel.changeButtonTapped()
								} label: {
									Text(LocalizableString.change.localized)
								}
								.buttonStyle(WXMButtonStyle.filled())
								.disabled(!viewModel.isFrequencyAcknowledged)
							}
						}
					} else {
						VStack {
							Spacer()

							HStack {
								Spacer()

								DeviceUpdatesLoadingView(title: LocalizableString.changingFrequency.localized,
														 subtitle: nil,
														 steps: viewModel.steps,
														 currentStepIndex: $viewModel.currentStepIndex,
														 progress: .constant(nil))

								Spacer()
							}

							Spacer()
						}
					}
				}
			}
            .fail(show: Binding(get: { viewModel.state.isFailed }, set: { _ in }), obj: viewModel.state.stateObject)
            .success(show: Binding(get: { viewModel.state.isSuccess }, set: { _ in }), obj: viewModel.state.stateObject)
            .animation(.easeIn, value: viewModel.state)
            .padding(.horizontal, CGFloat(.defaultSidePadding))
            .onAppear {
				navigationObject.title = LocalizableString.DeviceInfo.buttonChangeFrequency.localized
                WXMAnalytics.shared.trackScreen(.changeFrequency,
                                          parameters: [.itemId: .custom(viewModel.device.id ?? "")])
            }
            .onChange(of: viewModel.dismissToggle) { _ in
                dismiss()
            }
        }
    }
}

struct ChangeFrequencyView_Set_Previews: PreviewProvider {
    static var previews: some View {
        var device = DeviceDetails.emptyDeviceDetails
		device.bundle = .mock(name: .h1)

        return NavigationContainerView {
			ChangeFrequencyView(viewModel: ViewModelsFactory.getChangeFrequencyViewModel(device: device))
        }
    }
}

struct ChangeFrequencyView_Change_Previews: PreviewProvider {
    static var previews: some View {
        var device = DeviceDetails.emptyDeviceDetails
		device.bundle = .mock(name: .h1)
        let vm = ViewModelsFactory.getChangeFrequencyViewModel(device: device)
        vm.state = .changeFrequency
        return NavigationContainerView {
            ChangeFrequencyView(viewModel: vm)
        }
    }
}

struct ChangeFrequencyView_Fail_Previews: PreviewProvider {
    static var previews: some View {
        var device = DeviceDetails.emptyDeviceDetails
		device.bundle = .mock(name: .h1)
        let vm = ViewModelsFactory.getChangeFrequencyViewModel(device: device)
        vm.state = .failed(.mockErrorObj)
        return NavigationContainerView {
            ChangeFrequencyView(viewModel: vm)
        }
    }
}

struct ChangeFrequencyView_Success_Previews: PreviewProvider {
    static var previews: some View {
        var device = DeviceDetails.emptyDeviceDetails
		device.bundle = .mock(name: .h1)
        let vm = ViewModelsFactory.getChangeFrequencyViewModel(device: device)
        vm.state = .success(.mockSuccessObj)
        return NavigationContainerView {
            ChangeFrequencyView(viewModel: vm)
        }
    }
}
