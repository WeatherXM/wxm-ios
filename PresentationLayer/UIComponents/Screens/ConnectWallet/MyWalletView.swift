//
//  MyWalletView.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 5/4/23.
//

import SwiftUI
import Toolkit

struct MyWalletView: View {
    @EnvironmentObject var navigationObj: NavigationObject
    @StateObject var viewModel: MyWalletViewModel
    @State private var showScanner: Bool = false
    @State private var bottomDrawerSize: CGSize = .zero

    var body: some View {
        ZStack {
            Color(colorEnum: .bg).ignoresSafeArea()

            ZStack {
                TrackableScrollView(offsetObject: viewModel.trackableObject) {
                    VStack(spacing: CGFloat(.defaultSpacing)) {

						enterAddressCard
                            .padding(.horizontal, CGFloat(.defaultSidePadding))

                        if !viewModel.isInEditMode {
                            Button {
                                viewModel.handleViewTransactionHistoryTap()
                            } label: {
                                Text(LocalizableString.Wallet.viewTransactionHistory.localized)
                            }
                            .buttonStyle(WXMButtonStyle(fillColor: .top))
                            .padding(.horizontal, CGFloat(.defaultSidePadding))
                            .transition(AnyTransition.opacity.animation(.easeIn(duration: 0.2)))
                        }

                        if viewModel.isWarningVisible {
                            warningCard
                                .padding(.horizontal, CGFloat(.defaultSidePadding))
                                .transition(AnyTransition.opacity.animation(.easeIn(duration: 0.2)))
                        }
                    }
					.iPadMaxWidth()
                    .padding(.top)
                }
                .padding(.bottom, bottomDrawerSize.height)

                if viewModel.isInEditMode {
                    bottomDrawer
                }
            }
            .spinningLoader(show: $viewModel.isLoading, hideContent: true)
            .fail(show: $viewModel.isFailed, obj: viewModel.failObj)
        }
        .simultaneousGesture(TapGesture().onEnded { _ in
            hideKeyboard()
        })
        .onAppear {
            navigationObj.title = LocalizableString.Wallet.myWallet.localized
            navigationObj.navigationBarColor = Color(colorEnum: .bg)
            WXMAnalytics.shared.trackScreen(.wallet)
        }
        .sheet(isPresented: $viewModel.showQrScanner) {
			ScannerView(mode: .qr, completion: viewModel.handleScanResult)
        }
        .customSheet(isPresented: $viewModel.showAccountConfirmation) { _ in
            AccountConfirmationView(viewModel: viewModel.accountConfirmationViewModel!)
        }

    }
}

private extension MyWalletView {
    @ViewBuilder
    var enterAddressCard: some View {
		VStack(spacing: CGFloat(.defaultSpacing)) {
			VStack(spacing: CGFloat(.smallSpacing)) {
                HStack {
                    Text(LocalizableString.Wallet.enterWallet.localized)
                        .foregroundColor(Color(colorEnum: .text))
                        .font(.system(size: CGFloat(.normalFontSize), weight: .bold))
                    Spacer()
                }

                TextFieldsWallet(type: viewModel.isInEditMode ? .newWXMAddress : .currentWXMAddress,
                                 input: $viewModel.input,
                                 newAddressError: viewModel.textFieldError)
            }

            if viewModel.isInEditMode {
                scanQRButton
            } else {
                editAddressButton
            }

			VStack(spacing: CGFloat(.smallSpacing)) {
                HStack {
                    Text(LocalizableString.Wallet.addressTextFieldCaption.localized)
                        .foregroundColor(Color(colorEnum: .text))
                        .font(.system(size: CGFloat(.normalFontSize)))
                    Spacer()
                }

                HStack {
                    Text(LocalizableString.Wallet.createMetaMaskLink.localized.attributedMarkdown!)
                        .tint(Color(colorEnum: .wxmPrimary))
                        .font(.system(size: CGFloat(.caption), weight: .bold))
                        .simultaneousGesture(TapGesture().onEnded {
                            WXMAnalytics.shared.trackEvent(.selectContent, parameters: [.contentType: .createMetamask,
                                                                                  .itemId: .custom(viewModel.wallet?.address ?? "")])
                        })
                    Spacer()
                }
            }
        }
        .WXMCardStyle()
        .wxmShadow()
    }

    @ViewBuilder
    var warningCard: some View {
        CardWarningView(type: .error,
                        title: LocalizableString.Wallet.compatibility.localized,
                        message: LocalizableString.Wallet.compatibilityDescription.localized) {
            viewModel.isWarningVisible = false
            WXMAnalytics.shared.trackEvent(.prompt, parameters: [.promptName: .walletCompatibility,
                                                           .promptType: .info,
                                                           .action: .dismissAction])
		} content: {
            HStack {
                Text(LocalizableString.Wallet.compatibilityCheckLink.localized.attributedMarkdown!)
                    .tint(Color(colorEnum: .wxmPrimary))
                    .font(.system(size: CGFloat(.caption), weight: .bold))
                    .simultaneousGesture(TapGesture().onEnded {
                        WXMAnalytics.shared.trackEvent(.prompt, parameters: [.promptName: .walletCompatibility,
                                                                       .promptType: .info,
                                                                       .action: .action])
                    })
                Spacer()
            }
        }
        .onAppear {
            WXMAnalytics.shared.trackEvent(.prompt, parameters: [.promptName: .walletCompatibility,
                                                           .promptType: .info,
                                                           .action: .viewAction])
        }

    }

    @ViewBuilder
    var scanQRButton: some View {
        Button {
            viewModel.handleQRButtonTap()
        } label: {
            HStack {
                Image(asset: .qrCodeBlue)
                    .renderingMode(.template)
                    .foregroundColor(Color(colorEnum: .wxmPrimary))
                Text(LocalizableString.Wallet.scanQRCodeButton.localized)
            }
        }
        .buttonStyle(WXMButtonStyle())
    }

    @ViewBuilder
    var editAddressButton: some View {
        Button {
            withAnimation {
                viewModel.handleEditButtonTap()
            }
        } label: {
            HStack {
                Image(asset: .editIcon)
                    .renderingMode(.template)
                    .foregroundColor(Color(colorEnum: .wxmPrimary))
                Text(LocalizableString.Wallet.editAddress.localized)
            }
        }
        .buttonStyle(WXMButtonStyle())
    }

    @ViewBuilder
    var bottomDrawer: some View {
        VStack {
            Spacer()

			VStack(spacing: CGFloat(.defaultSpacing)) {
                HStack {
                    Toggle("",
                           isOn: $viewModel.isTermsOfServiceAccepted)
                    .labelsHidden()
                    .toggleStyle(WXMToggleStyle.Default)

                    Text("\(LocalizableString.Wallet.acceptTermsOfService.localized) **[\(LocalizableString.Wallet.termsTitle.localized)](\(DisplayedLinks.termsLink.linkURL))**".attributedMarkdown!)
                        .tint(Color(colorEnum: .wxmPrimary))
                        .foregroundColor(Color(colorEnum: .text))
                        .font(.system(size: CGFloat(.normalFontSize)))
                        .simultaneousGesture(TapGesture().onEnded {
                            WXMAnalytics.shared.trackEvent(.selectContent, parameters: [.contentType: .walletTermsOfService])
                        })

                    Spacer()
                }

                HStack {
                    Toggle("",
                           isOn: $viewModel.isOwnershipAcknowledged)
                    .labelsHidden()
                    .toggleStyle(WXMToggleStyle.Default)

                    Text(LocalizableString.Wallet.acknowledgementOfOwnership.localized)
                        .tint(Color(colorEnum: .wxmPrimary))
                        .foregroundColor(Color(colorEnum: .text))
                        .font(.system(size: CGFloat(.normalFontSize)))

                    Spacer()
                }

                Button {
                    viewModel.handleSaveButtonTap()
                } label: {
                    Text(LocalizableString.Wallet.saveAddress.localized)
                }
                .buttonStyle(WXMButtonStyle(textColor: .top,
                                                      fillColor: .wxmPrimary))
                .disabled(!viewModel.isSaveButtonEnabled)
            }
            .WXMCardStyle()
            .sizeObserver(size: $bottomDrawerSize)
            .background {
                Color(colorEnum: .top)
                    .cornerRadius(CGFloat(.cardCornerRadius))
                    .wxmShadow()
                    .drawingGroup()
                    .ignoresSafeArea()
            }
        }
        .transition(AnyTransition.move(edge: .bottom).animation(.easeIn(duration: 0.2)))

    }
}

struct MyWalletView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationContainerView {
            MyWalletView(viewModel: MyWalletViewModel(useCase: nil))
				.environmentObject(MainScreenViewModel.shared)
        }
    }
}
