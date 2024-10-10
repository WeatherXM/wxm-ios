//
//  SelectStationLocationView.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 14/12/23.
//

import SwiftUI
import DomainLayer

struct SelectStationLocationView: View {
	@StateObject var viewModel: SelectStationLocationViewModel
	@EnvironmentObject var navigationObject: NavigationObject
	@State private var annotationSize: CGSize = .zero
	@State private var showSearchResults: Bool = false

	var body: some View {
		ZStack {
			Color(colorEnum: .bg)
				.ignoresSafeArea()

			VStack(spacing: 0.0) {
				VStack(spacing: 0.0) {
					SelectLocationMapView(viewModel: viewModel.locationViewModel)
						.cornerRadius(CGFloat(.cardCornerRadius), corners: [.topLeft, .topRight])

					VStack(spacing: CGFloat(.defaultSpacing)) {
						CardWarningView(configuration: .init(message: LocalizableString.SelectStationLocation.warningText(DisplayedLinks.polAlgorithm.linkURL).localized,
															 closeAction: nil),
										content: { EmptyView() })
						
						acknowledgementView

						Button {
							viewModel.handleConfirmTap()
						} label: {
							Text(LocalizableString.SelectStationLocation.buttonTitle.localized)
						}
						.buttonStyle(WXMButtonStyle.filled())
						.disabled(!viewModel.termsAccepted)
					}
					.WXMCardStyle(cornerRadius: 0.0)
					.cornerRadius(CGFloat(.cardCornerRadius), corners: [.bottomLeft, .bottomRight])
				}
				.success(show: $viewModel.isSuccessful, obj: viewModel.successObj)
			}
			.padding(.horizontal, CGFloat(.defaultSidePadding))
			.padding(.bottom, CGFloat(.defaultSidePadding))
			.cornerRadius(CGFloat(.cardCornerRadius), corners: [.topLeft, .topRight])
			.if(!viewModel.isSuccessful) { view in
				view.wxmShadow()
			}
			.onTapGesture {
				hideKeyboard()
			}
			.ignoresSafeArea(.keyboard, edges: .bottom)
			.iPadMaxWidth()
		}
		.onAppear {
			navigationObject.title = LocalizableString.SelectStationLocation.title.localized
			navigationObject.subtitle = viewModel.device.displayName
			navigationObject.navigationBarColor = Color(colorEnum: .bg)
		}
	}
}

private extension SelectStationLocationView {
	@ViewBuilder
	var acknowledgementView: some View {
		HStack(alignment: .top, spacing: CGFloat(.smallSpacing)) {
			Toggle(LocalizableString.SelectStationLocation.termsText.localized,
				   isOn: $viewModel.termsAccepted)
			.labelsHidden()
			.toggleStyle(WXMToggleStyle.Default)

			Text(LocalizableString.SelectStationLocation.termsText.localized)
				.foregroundColor(Color(colorEnum: .text))
				.font(.system(size: CGFloat(.normalFontSize)))
				.fixedSize(horizontal: false, vertical: true)
		}
	}
}

#Preview {
	let device = DeviceDetails.mockDevice
	let viewModel = ViewModelsFactory.getSelectLocationViewModel(device: device,
																 followState: .init(deviceId: device.id!, relation: .owned),
																 delegate: nil)
	return NavigationContainerView {
		SelectStationLocationView(viewModel: viewModel)
	}
}
