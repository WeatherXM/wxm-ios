//
//  ClaimDeviceVerify.swift
//  PresentationLayer
//
//  Created by Manolis Katsifarakis on 29/9/22.
//

import DomainLayer
import SwiftUI

struct ClaimDeviceVerify: View {
    @EnvironmentObject var viewModel: ClaimDeviceViewModel
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    @State private var disallowSubmit = true
    @State private var focusSerialNumber: Bool? = true

    private let swinjectHelper: SwinjectInterface
    private let transport: StepsNavView.Transport
    public init(swinjectHelper: SwinjectInterface, transport: StepsNavView.Transport) {
        self.swinjectHelper = swinjectHelper
        self.transport = transport
    }

    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 0) {
                title

                ScrollView {
                    textField
                    information
                }

                bottomButtons
            }
            .WXMCardStyle()
        }
        .padding(.horizontal, CGFloat(.defaultSidePadding))
        .padding(.bottom, CGFloat(.defaultSidePadding))
        .onChange(of: viewModel.device.devEUI, perform: { _ in
            self.updateDisallowSubmit()
        })
        .onAppear {
            self.updateDisallowSubmit()
        }
    }

    func updateDisallowSubmit() {
        disallowSubmit = viewModel.device.devEUI.count != 26
    }

    var title: some View {
        Text(LocalizableString.ClaimDevice.verifyTitle.localized)
            .font(.system(size: CGFloat(.titleFontSize), weight: .bold))
            .padding(.bottom, 30)
    }

    var textField: some View {
        VStack(spacing: CGFloat(.minimumSpacing)) {
            HStack {
                Text(LocalizableString.deviceSerialNumber.localized)
                    .foregroundColor(Color(colorEnum: .text))
                    .font(.system(size: CGFloat(.normalFontSize), weight: .bold))
                Spacer()
            }
            let serialNumber = viewModel.device.devEUI.replacingOccurrences(of: ":", with: "")
            ZStack(alignment: .leading) {
                Text("\(UITextField.formatAsSerialNumber(serialNumber, placeholder: "A"))")
                    .font(.custom("Menlo-Regular", fixedSize: FontSizeEnum.mediumFontSize.sizeValue))
					.padding(CGFloat(.defaultSidePadding))
                    .opacity(0.4)

                UberTextField(
                    text: $viewModel.device.devEUI,
                    isFirstResponder: $focusSerialNumber,
                    shouldChangeCharactersIn: { tf, range, string in
                        tf.updateSerialNumberCharactersIn(nsRange: range, for: string)
                        return false
                    },
                    onSubmit: { _ in
                        focusSerialNumber = false
                        return true
                    },
                    configuration: { tf in
                        tf.keyboardType = .asciiCapable
                        tf.returnKeyType = .continue
                        tf.horizontalPadding = CGFloat(.defaultSidePadding)
                        tf.verticalPadding = CGFloat(.defaultSidePadding)
                        tf.configureForSerialNumber()
                        tf.backgroundColor = .clear
                    }
                )
            }
			.strokeBorder(color: Color(colorEnum: .primary), lineWidth: 2.0, radius: CGFloat(.buttonCornerRadius))
        }
        .padding(.bottom, 16)
    }

    var information: some View {
        InfoView(text: LocalizableString.ClaimDevice.information(LocalizableString.ClaimDevice.informationBold.localized).localized.attributedMarkdown ?? "")
    }

    var bottomButtons: some View {
        Button {
            submit()
        } label: {
            Text(LocalizableString.ClaimDevice.verifyButton.localized)
        }
        .buttonStyle(WXMButtonStyle.filled())
        .disabled(disallowSubmit)
    }
}

private extension ClaimDeviceVerify {
    func submit() {
        hideKeyboard()

        viewModel.heliumDeviceInformation = HeliumDevice(
            devEUI: viewModel.device.devEUI,
            deviceKey: ""
        )

        transport.nextStep()
    }
}

struct Previews_ClaimDeviceVerify_Previews: PreviewProvider {
    static var previews: some View {
        ClaimDeviceVerify(swinjectHelper: SwinjectHelper.shared, transport: StepsNavView.Transport(nextStep: {

        }, previousStep: {

        }, firstStep: {

        }, isLastStep: {
            true
        }, isFirstStep: {
            true
        }))
		.environmentObject(ViewModelsFactory.getClaimDeviceViewModel())
    }
}
