//
//  MyWalletViewModelTests.swift
//  WeatherXMTests
//
//  Created by Pantelis Giazitsis on 2/4/25.
//

import Testing
@testable import WeatherXM

@Suite(.serialized)
@MainActor
struct MyWalletViewModelTests {
	let viewModel: MyWalletViewModel
	let useCase: MockMeUseCase
	let linkNavigation: MockLinkNavigation
	let validAddress = "0x399ccdA0E2ccdd1f0d146a8fF47886dCbb5C0000"
	init() {
		useCase = .init()
		linkNavigation = .init()
		viewModel = .init(useCase: useCase, linkNavigation: linkNavigation)
	}

	@Test func input() async throws {
		#expect(viewModel.input.isEmpty)
		#expect(viewModel.textFieldError == nil)
		viewModel.handleSaveButtonTap()
		#expect(viewModel.textFieldError == .emptyField)
		
		viewModel.input = "123"
		#expect(viewModel.textFieldError == nil)
		viewModel.handleSaveButtonTap()
		#expect(viewModel.textFieldError == .invalidNewAddress)

		viewModel.input = validAddress
		#expect(viewModel.textFieldError == nil)
		viewModel.handleSaveButtonTap()
		#expect(viewModel.textFieldError == nil)
    }


	@Test func linkNavigation() async throws {
		#expect(linkNavigation.openedUrl == nil)
		viewModel.handleViewTransactionHistoryTap()
		#expect(linkNavigation.openedUrl ==  String(format: DisplayedLinks.networkAddressWebsiteFormat.linkURL, ""))

		viewModel.handleCheckCompatibilityTap()
		#expect(linkNavigation.openedUrl == DisplayedLinks.createWalletsLink.linkURL)
	}

	@Test func qrScanner() {
		#expect(!viewModel.showQrScanner)
		viewModel.handleQRButtonTap()
		#expect(viewModel.showQrScanner)
	}

	@Test func qrResult() {
		#expect(viewModel.input.isEmpty)
		viewModel.handleScanResult(result: nil)
		#expect(viewModel.input.isEmpty)

		viewModel.handleScanResult(result: "123")
		#expect(viewModel.input == "123")

		let address = validAddress + "123"
		viewModel.handleScanResult(result: address)
		#expect(viewModel.input == validAddress)
	}
}
