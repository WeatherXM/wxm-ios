//
//  HeliumClaimingStatusView.swift
//  PresentationLayer
//
//  Created by Manolis Katsifarakis on 10/10/22.
//

import DomainLayer
import SwiftUI
import Toolkit

struct HeliumClaimingStatusView: View {
	@EnvironmentObject var viewModel: ClaimDeviceViewModel
	let mainVM: MainScreenViewModel = .shared

	@State private var steps: [StepsView.Step] = Steps.allCases.map { StepsView.Step(text: $0.description, isCompleted: false) }
	@State private var stepIndex: Int?
	@State private var showUpdateFirmwareAlert: Bool = false
	@State private var updateFirmwareAlertDevice: DeviceDetails?

	let dismiss: () -> Void
	let restartClaimFlow: () -> Void

	var body: some View {
		ZStack {
			VStack {
				closeButton

				Spacer()
				icon
				title
				information.padding(.bottom, 20)

				if !viewModel.isM5 {
					stepsView
				}

				switch viewModel.claimState {
					case .connectionError, .failed:
						contactSupport
					default:
						EmptyView()
				}
				Spacer()

				infoView

				bottomButtons
			}
		}
		.WXMCardStyle()
		.iPadMaxWidth()
		.padding(CGFloat(.defaultSidePadding))
		.onChange(of: viewModel.claimState) { newValue in
			updateSteps(for: newValue)
		}
		.onAppear {
			updateSteps(for: viewModel.claimState)
			trackViewContentEvent()
		}
		.alert(isPresented: $showUpdateFirmwareAlert) {
			updateFirmwareGoToStationAlert
		}
	}

	@ViewBuilder
	var closeButton: some View {
		switch viewModel.claimState {
			case .idle, .claiming, .rebooting, .settingFrequency:
				HStack {
					Spacer()

					Button {
						dismiss()
					} label: {
						Image(asset: .closeButton)
							.renderingMode(.template)
							.foregroundColor(Color(colorEnum: .text))
					}
				}
			case .success:
				EmptyView()
			case .failed, .connectionError:
				EmptyView()
		}
	}

	@ViewBuilder
	var icon: some View {
		switch viewModel.claimState {
			case .idle:
				EmptyView()
			case .claiming, .rebooting, .settingFrequency:
				spinner
			case .success:
				successIcon
			case .failed, .connectionError:
				failIcon
		}
	}

	@ViewBuilder
	var spinner: some View {
		LottieView(animationCase: AnimationsEnums.loading.animationString, loopMode: .repeat(.infinity))
			.background(
				Circle().fill(Color(colorEnum: .layer2))
			)
			.frame(width: 150, height: 150)
			.padding(.bottom, 20)
	}

	@ViewBuilder
	var successIcon: some View {
		LottieView(animationCase: AnimationsEnums.success.animationString, loopMode: .playOnce)
			.background(
				Circle().fill(Color(colorEnum: .layer2))
			)
			.frame(width: 150, height: 150)
			.padding(.bottom, 20)
	}

	@ViewBuilder
	var failIcon: some View {
		LottieView(animationCase: AnimationsEnums.fail.animationString, loopMode: .playOnce)
			.background(
				Circle().fill(Color(colorEnum: .layer2))
			)
			.frame(width: 150, height: 150)
			.padding(.bottom, 20)
	}

	@ViewBuilder
	var title: some View {
		Group {
			switch viewModel.claimState {
				case .idle:
					EmptyView()
				case .claiming, .rebooting, .settingFrequency:
					Text(LocalizableString.ClaimDevice.claimingTitle.localized)
						.font(.system(size: CGFloat(.largeTitleFontSize), weight: .bold))
				case .success:
					Text(LocalizableString.ClaimDevice.successTitle.localized)
						.font(.system(size: CGFloat(.largeTitleFontSize), weight: .bold))
				case .failed:
					Text(LocalizableString.ClaimDevice.failedTitle.localized)
						.font(.system(size: CGFloat(.largeTitleFontSize), weight: .bold))
				case .connectionError:
					Text(LocalizableString.ClaimDevice.connectionFailedTitle.localized)
						.font(.system(size: CGFloat(.largeTitleFontSize), weight: .bold))
			}
		}
		.foregroundColor(Color(colorEnum: .text))
	}

	@ViewBuilder
	var information: some View {
		switch viewModel.claimState {
			case .idle:
				EmptyView()
			case .claiming, .settingFrequency, .rebooting:
				claimingInformation
			case let .success(deviceResponse, _):
				successInformation(stationName: deviceResponse?.displayName ?? "")
			case let .failed(error):
				failureInformation(errorMessage: error.message)
			case .connectionError:
				connectionFailureInformation
		}
	}

	@ViewBuilder
	var claimingInformation: some View {
		let boldText = viewModel.isM5 ? "" : LocalizableString.ClaimDevice.claimingTextInformation.localized
		let text = LocalizableString.ClaimDevice.claimingText(boldText).localized
		var attributedtext = NSMutableAttributedString(
			string: text,
			attributes: [.font: UIFont.systemFont(ofSize: FontSizeEnum.normalFontSize.sizeValue)]
		)

		if let range = text.range(of: boldText) {
			let boldTextRange = NSRange(range, in: text)
			attributedtext.setAttributes([.font: UIFont.systemFont(ofSize: FontSizeEnum.normalFontSize.sizeValue, weight: .bold)], range: boldTextRange)
		}

		return AttributedLabel(attributedText: .constant(attributedtext)) {
			$0.textAlignment = .center
		}
	}

	@ViewBuilder
	func successInformation(stationName: String) -> some View {
		let boldText = stationName
		let text = LocalizableString.ClaimDevice.successText(boldText).localized
		let attributedtext = NSMutableAttributedString(
			string: text,
			attributes: [.font: UIFont.systemFont(ofSize: FontSizeEnum.normalFontSize.sizeValue)]
		)

		if let range = text.range(of: boldText) {
			let boldTextRange = NSRange(range, in: text)
			attributedtext.setAttributes([.font: UIFont.systemFont(ofSize: FontSizeEnum.normalFontSize.sizeValue, weight: .bold)], range: boldTextRange)
		}

		return AttributedLabel(attributedText: .constant(attributedtext)) {
			$0.textAlignment = .center
		}
	}

	@ViewBuilder
	func failureInformation(errorMessage: String) -> some View {
		let contactLink = LocalizableString.ClaimDevice.failedTextLinkTitle.localized
		let error = "**\(errorMessage)**"
		let str = LocalizableString.ClaimDevice.failedText(error, contactLink).localized
		let attributedStr = str.attributedMarkdown

		Text(attributedStr!)
			.foregroundColor(Color(colorEnum: .text))
			.font(.system(size: CGFloat(.normalFontSize)))
			.multilineTextAlignment(.center)
	}

	@ViewBuilder var connectionFailureInformation: some View {
		// Contact
		let contactLink = LocalizableString.ClaimDevice.failedTextLinkTitle.localized

		// Troubleshooting
		let troubleshootingLink = LocalizableString.ClaimDevice.failedTroubleshootingTextLinkTitle.localized

		// Text format
		let text = LocalizableString.ClaimDevice.connectionFailedMarkDownText(troubleshootingLink, contactLink).localized

		Text(text.attributedMarkdown!)
			.foregroundColor(Color(colorEnum: .text))
			.font(.system(size: CGFloat(.normalFontSize)))
			.multilineTextAlignment(.center)
	}

	@ViewBuilder
	var stepsView: some View {
		switch viewModel.claimState {
			case .idle, .connectionError, .success, .failed:
				EmptyView()
			case .settingFrequency, .rebooting, .claiming:
				StepsView(steps: steps, currentStepIndex: $stepIndex)
		}
	}

	@ViewBuilder
	var bottomButtons: some View {
		switch viewModel.claimState {
			case .idle, .claiming, .rebooting, .settingFrequency:
				EmptyView()
			case let .success(device, followState):
				successBottomButtons(device, followState: followState)
			case .failed, .connectionError:
				failureBottomButtons
		}
	}

	@ViewBuilder
	func successBottomButtons(_ device: DeviceDetails?, followState: UserDeviceFollowState?) -> some View {
		HStack(spacing: CGFloat(.defaultSpacing)) {
			let needsUpdate = device?.needsUpdate(mainVM: mainVM, followState: followState) == true
			let style = needsUpdate ? WXMButtonStyle(fillColor: .clear) : WXMButtonStyle()
			Button {
				if let event = viewModel.claimState.retryButtonEvent {
					WXMAnalytics.shared.trackEvent(event.event, parameters: event.parameters)
				}

				if let device,
				   device.needsUpdate(mainVM: mainVM, followState: followState) {
					updateFirmwareAlertDevice = device
					showUpdateFirmwareAlert = true
					return
				}
				dismissAndNavigate(device: device)
			} label: {
				Text(LocalizableString.ClaimDevice.viewStationButton.localized)
			}
			.buttonStyle(style)

			if device?.needsUpdate(mainVM: mainVM, followState: followState) == true {
				Button {
					WXMAnalytics.shared.trackEvent(.userAction, parameters: [.actionName: .claimingResult,
																	   .contentType: .claiming,
																	   .action: .updateFirmware])

					dismissAndUpdateFirmware(device: device)
				} label: {
					HStack(spacing: CGFloat(.smallSpacing)) {
						Image(asset: .updateFirmwareIcon)
						Text(LocalizableString.ClaimDevice.updateFirmwareButton.localized)
					}
				}
				.buttonStyle(WXMButtonStyle.filled())
			}
		}
	}

	@ViewBuilder
	var failureBottomButtons: some View {
		HStack(spacing: CGFloat(.smallSpacing)) {
			Button {
				if let event = viewModel.claimState.cancelButtonEvent {
					WXMAnalytics.shared.trackEvent(event.event, parameters: event.parameters)
				}

				dismiss()
				viewModel.cancelClaim()
				DispatchQueue.main.async {
					viewModel.shouldExitClaimFlow = true
				}
			} label: {
				Text(LocalizableString.ClaimDevice.cancelClaimButton.localized)
			}
			.buttonStyle(WXMButtonStyle())

			Button {
				if let event = viewModel.claimState.retryButtonEvent {
					WXMAnalytics.shared.trackEvent(event.event, parameters: event.parameters)
				}

				restartClaimFlow()
			} label: {
				Text(LocalizableString.ClaimDevice.retryClaimButton.localized)
			}
			.buttonStyle(
				WXMButtonStyle(
					textColor: .top,
					fillColor: .primary
				)
			)
		}
	}

	@ViewBuilder
	var contactSupport: some View {
		Button {
			viewModel.handleContactSupportTap(userEmail: mainVM.userInfo?.email ?? "")
		} label: {
			Text(LocalizableString.contactSupport.localized)
		}
		.buttonStyle(WXMButtonStyle())
	}

	@ViewBuilder
	var infoView: some View {
		switch viewModel.claimState {
			case .idle, .connectionError, .failed, .settingFrequency, .rebooting, .claiming:
				EmptyView()
			case let .success(device, followState):
				if let device,
				   device.needsUpdate(mainVM: mainVM, followState: followState),
				   let text = LocalizableString.ClaimDevice.updateFirmwareInfoMarkdown.localized.attributedMarkdown {
					InfoView(text: text)
						.padding(.bottom, CGFloat(.defaultSidePadding))
						.onAppear {
							WXMAnalytics.shared.trackEvent(.prompt, parameters: [.promptName: .OTAAvailable,
																		   .promptType: .warnPromptType,
																		   .action: .viewAction])
						}
				} else {
					EmptyView()
				}
		}
	}

	var updateFirmwareGoToStationAlert: Alert {
		Alert(
			title: Text(LocalizableString.ClaimDevice.updateFirmwareAlertTitle.localized),
			message: Text(LocalizableString.ClaimDevice.updateFirmwareAlertText.localized),
			primaryButton: .default(Text(LocalizableString.ClaimDevice.updateFirmwareAlertGoToStation.localized)) {
				showUpdateFirmwareAlert = false
				if let device = updateFirmwareAlertDevice {
					dismissAndNavigate(device: device)
				}
			},
			secondaryButton: .default(Text(LocalizableString.ClaimDevice.updateFirmwareAlertUpdate.localized)) {
				if let device = updateFirmwareAlertDevice {
					dismissAndUpdateFirmware(device: device)
				}
			}
		)
	}
}

private extension HeliumClaimingStatusView {
	func updateSteps(for state: ClaimDeviceViewModel.ClaimState) {
		switch state {
			case .idle, .connectionError, .success, .failed:
				stepIndex = nil
			case .settingFrequency:
				stepIndex = Steps.settingFrequency.index
			case .rebooting:
				stepIndex = Steps.rebooting.index
			case .claiming:
				stepIndex = Steps.claiming.index
		}

		(0 ..< steps.count).forEach { index in
			guard let stepIndex else {
				steps[index].setCompleted(false)
				return
			}
			steps[index].setCompleted(stepIndex > index)
		}
	}

	func trackViewContentEvent() {
		guard let success = viewModel.claimState.viewContentSuccessValue else {
			return
		}

		WXMAnalytics.shared.trackEvent(.viewContent, parameters: [.contentName: .claimingResult,
															.contentId: .claimingResultContentId,
															.success: .custom(success)])
	}
}

private extension ClaimDeviceViewModel.ClaimState {
	typealias AnalyticsEvent = (event: Event, parameters: [Parameter: ParameterValue])

	var viewContentSuccessValue: String? {
		switch self {
			case .connectionError:
				return "0"
			case .success:
				return "1"
			case .failed:
				return "0"
			default:
				return nil
		}
	}

	var cancelButtonEvent: AnalyticsEvent? {
		switch self {
			case .idle:
				return nil
			case .settingFrequency:
				return nil
			case .rebooting:
				return nil
			case .claiming:
				return nil
			case .connectionError:
				return (.userAction, [.actionName: .heliumBLEPopupError,
									  .contentType: .heliumBLEPopup,
									  .action: .quit])
			case .success:
				return nil
			case .failed:
				return (.userAction, [.actionName: .claimingResult,
									  .contentType: .claiming,
									  .action: .cancel])
		}
	}

	var retryButtonEvent: AnalyticsEvent? {
		switch self {
			case .idle:
				return nil
			case .settingFrequency:
				return nil
			case .rebooting:
				return nil
			case .claiming:
				return nil
			case .connectionError:
				return (.userAction, [.actionName: .heliumBLEPopupError,
									  .contentType: .heliumBLEPopup,
									  .action: .tryAgain])
			case .success:
				return (.userAction, [.actionName: .claimingResult,
									  .contentType: .claiming,
									  .action: .viewStation])
			case .failed:
				return (.userAction, [.actionName: .claimingResult,
									  .contentType: .claiming,
									  .action: .retry])
		}
	}
}
