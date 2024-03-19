//
//  ProfileViewModel.swift
//  PresentationLayer
//
//  Created by Danae Kikue Dimou on 7/6/22.
//

import Combine
import DomainLayer
import SwiftUI
import Toolkit

class ProfileViewModel: ObservableObject {
    private final let meUseCase: MeUseCase
    private var cancellableSet: Set<AnyCancellable> = []
	private let tabBarVisibilityHandler: TabBarVisibilityHandler

	let scrollOffsetObject: TrackableScrollOffsetObject
	private var userRewardsResponse: NetworkUserRewardsResponse? {
		didSet {
			updateRewards()
		}
	}
	@Published var showInfo: Bool = false
	private(set) var info: BottomSheetInfo?
	@Published var userInfoResponse = NetworkUserInfoResponse() {
		didSet {
			updateUserInfoValues()
		}
	}
	@Published var showBuyStation: Bool = true
	@Published var showMissingWalletError: Bool = false
	@Published var isTabBarVisible: Bool = true
	@Published var totalEarned: String = 0.0.toWXMTokenPrecisionString
	@Published var totalClaimed: String = 0.0.toWXMTokenPrecisionString
	@Published var allocatedRewards: String = LocalizableString.Profile.noRewardsDescription.localized
	@Published var isClaimAvailable: Bool = false
	@Published var isLoading: Bool = true
	@Published var isFailed: Bool = false
	var failObj: FailSuccessStateObject?

    public init(meUseCase: MeUseCase) {
        self.meUseCase = meUseCase
		scrollOffsetObject = .init()
		tabBarVisibilityHandler = TabBarVisibilityHandler(scrollOffsetObject: self.scrollOffsetObject)
		tabBarVisibilityHandler.$isTabBarShowing.assign(to: &$isTabBarVisible)
		
		updateRewards()

		MainScreenViewModel.shared.$isWalletMissing.assign(to: &$showMissingWalletError)

		self.refresh { }
    }

	func refresh(completion: @escaping VoidCallback) {
		Task { @MainActor [weak self] in
			defer {
				self?.isLoading = false
				completion()
			}

			if let userInfoError = await self?.getUserInfo() {
				self?.failObj = userInfoError.uiInfo.defaultFailObject(type: .profile) {
					self?.isFailed = false
					self?.isLoading = true
					self?.refresh { }
				}
				self?.isFailed = true

				return
			}

			if let rewardsError = await self?.fetchUserRewards(),
			   rewardsError.backendError?.code != FailAPICodeEnum.walletAddressNotFound.rawValue,
			   case let info = rewardsError.uiInfo,
			   let message = info.description?.attributedMarkdown {
					Toast.shared.show(text: message)

				return
			}
		}
	}

	func handleBuyStationTap() {
		HelperFunctions().openUrl(DisplayedLinks.shopLink.linkURL)
	}

	func handleTotalEarnedInfoTap() {
		info = BottomSheetInfo(title: LocalizableString.Profile.totalEarnedInfoTitle.localized,
							   description: LocalizableString.Profile.totalEarnedInfoDescription.localized)
		showInfo = true
	}

	func handleTotalClaimedInfoTap() {
		info = BottomSheetInfo(title: LocalizableString.Profile.totalClaimedInfoTitle.localized,
							   description: LocalizableString.Profile.totalClaimedInfoDescription.localized)
		showInfo = true
	}

	func handleClaimButtonTap() {
		let url = DisplayedLinks.claimToken.linkURL
		var params: [DisplayLinkParams: String] = [:]
		if let activeTheme = MainScreenViewModel.shared.deviceActiveTheme {
			params += [.theme: activeTheme.rawValue]
		}
		if let amount = userRewardsResponse?.available {
			params += [.amount: amount]
		}
		
		if let walletAddress = userInfoResponse.wallet?.address {
			params += [.wallet: walletAddress]
		}

		if let urlScheme = Bundle.main.urlScheme {
			params += [.redirectUrl: "\(urlScheme)://\(DeepLinkHandler.tokenClaim)"]
		}

		let callback: DeepLinkHandler.QueryParamsCallBack = { [weak self] params in
			if let amount = params?[DisplayLinkParams.claimedAmount.rawValue] {
				self?.updateRewards(additionalClaimed: amount)
			}
		}
		Router.shared.navigateTo(.webView(LocalizableString.Profile.claimFlowTitle.localized, url, params, callback))
	}

	@MainActor
    func getUserInfo() async -> NetworkErrorResponse? {
		do {
			let userInfoResponse = try await meUseCase.getUserInfo().toAsync()
			if let error = userInfoResponse.error {
				return error
			}
			
			if let value = userInfoResponse.value {
				self.userInfoResponse = value
			}

			return nil
		} catch {
			print(error)
			return nil
		}
    }
}

private extension ProfileViewModel {
	@MainActor
	func fetchUserRewards() async -> NetworkErrorResponse? {
		guard let address = userInfoResponse.wallet?.address else {
			return nil
		}

		do {
			let userRewardsResponse = try await meUseCase.getUserRewards(wallet: address).toAsync()
			if let error = userRewardsResponse.error {
				return error
			}

			if let value = userRewardsResponse.value {
				self.userRewardsResponse = value
			}

			return nil
		} catch {
			print(error)
			return nil
		}
	}

	func updateRewards(additionalClaimed: String? = nil) {
		let cumulative = userRewardsResponse?.cumulativeAmount?.toEthDouble ?? 0.0
		totalEarned = cumulative.toWXMTokenPrecisionString + " " + StringConstants.wxmCurrency

		let claimed = (userRewardsResponse?.totalClaimed?.toEthDouble ?? 0.0) + (additionalClaimed?.toEthDouble ?? 0.0)
		totalClaimed = claimed.toWXMTokenPrecisionString + " " + StringConstants.wxmCurrency

		let allocated = (userRewardsResponse?.available?.toEthDouble ?? 0.0) - (additionalClaimed?.toEthDouble ?? 0.0)
		isClaimAvailable = allocated > 0.0
		let noRewardsString = LocalizableString.Profile.noRewardsDescription.localized
		let valueString = allocated.toWXMTokenPrecisionString + " " + StringConstants.wxmCurrency
		allocatedRewards = allocated == 0.0 ? noRewardsString : valueString
	}

	func updateUserInfoValues() {
		Task { @MainActor [weak self] in
			guard let self = self  else {
				return
			}
			self.showBuyStation = await !self.meUseCase.hasOwnedDevices()
		}
	}
}
