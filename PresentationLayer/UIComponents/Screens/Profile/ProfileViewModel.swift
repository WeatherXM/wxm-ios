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

@MainActor
class ProfileViewModel: ObservableObject {
    private final let meUseCase: MeUseCase
	private let remoteConfigUseCase: RemoteConfigUseCase
    private var cancellableSet: Set<AnyCancellable> = []
	private let tabBarVisibilityHandler: TabBarVisibilityHandler

	let scrollOffsetObject: TrackableScrollOffsetObject
	private var userRewardsResponse: NetworkUserRewardsResponse? {
		didSet {
			updateRewards()
			updateUserInfoValues()
		}
	}
	@Published var showInfo: Bool = false
	private(set) var info: BottomSheetInfo?
	@Published var userInfoResponse = NetworkUserInfoResponse() {
		didSet {
			updateUserInfoValues()
		}
	}
	@Published var showRewardsIndication: Bool = true
	var rewardsIndicationType: RewardsIndication = .claimWeb
	@Published var showMissingWalletError: Bool = false
	@Published var isTabBarVisible: Bool = true
	@Published var totalEarned: String = 0.0.toWXMTokenPrecisionString
	@Published var totalClaimed: String = 0.0.toWXMTokenPrecisionString
	@Published var allocatedRewards: String = LocalizableString.Profile.noRewardsDescription.localized
	@Published var isClaimAvailable: Bool = false
	@Published var isLoading: Bool = true
	@Published var isFailed: Bool = false
	var failObj: FailSuccessStateObject?
	@Published var surveyConfiguration: AnnouncementCardView.Configuration?

	var claimWebAppUrl: String {
		let urlString = DisplayedLinks.claimToken.linkURL
		let url = URL(string: urlString)
		return url?.host ?? "-"
	}

	public init(meUseCase: MeUseCase, remoteConfigUseCase: RemoteConfigUseCase) {
        self.meUseCase = meUseCase
		self.remoteConfigUseCase = remoteConfigUseCase
		scrollOffsetObject = .init()
		tabBarVisibilityHandler = TabBarVisibilityHandler(scrollOffsetObject: self.scrollOffsetObject)
		tabBarVisibilityHandler.$isTabBarShowing.assign(to: &$isTabBarVisible)
		MainScreenViewModel.shared.$userInfo.sink { [weak self] response in
			guard let response else {
				return
			}
			self?.userInfoResponse = response
			Task { [weak self] in
				await self?.fetchUserRewards()
			}
		}.store(in: &cancellableSet)

		updateRewards()

		MainScreenViewModel.shared.$isWalletMissing.assign(to: &$showMissingWalletError)

		remoteConfigUseCase.surveyPublisher.sink { [weak self] survey in
			self?.surveyConfiguration = self?.getConfigurationForSurvey(survey)
		}.store(in: &cancellableSet)

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
		var params: [DisplayLinkParams: String] = [.embed: String(true)]
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

		let backButtonCallback = { [weak self] in
			WXMAnalytics.shared.trackEvent(.viewContent, parameters: [.contentName: .tokenClaimingResult,
																	  .state: .failure])

			guard let self, let text = LocalizableString.Profile.claimFromWebAlertMessage(claimWebAppUrl).localized.attributedMarkdown else {
				return
			}

			Toast.shared.show(text: text, type: .info, visibleDuration: 10.0, retryButtonTitle: LocalizableString.close.localized, retryAction: { })
		}

		let callback: DeepLinkHandler.QueryParamsCallBack = { [weak self] params in
			if let amount = params?[DisplayLinkParams.claimedAmount.rawValue] {
				self?.updateRewards(additionalClaimed: amount)

				// We consider there is a successful claim
				WXMAnalytics.shared.trackEvent(.viewContent, parameters: [.contentName: .tokenClaimingResult,
																		  .state: .success])
			}
		}

		let onAppearCallback = {
			WXMAnalytics.shared.trackScreen(.claimDapp)
		}

		let conf = WebContainerView.Configuration(title: LocalizableString.Profile.claimFlowTitle.localized,
												  url: url,
												  params: params,
												  onAppearCallback: onAppearCallback,
												  backButtonCallback: backButtonCallback,
												  redirectParamsCallback: callback)
		Router.shared.navigateTo(.webView(conf))
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
				self.userRewardsResponse = nil

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
		if let cumulative = userRewardsResponse?.cumulativeAmount?.toEthDouble {
			totalEarned = cumulative.toWXMTokenPrecisionString + " " + StringConstants.wxmCurrency
		} else if userInfoResponse.wallet?.address == nil {
			totalEarned = 0.0.toWXMTokenPrecisionString + " " + StringConstants.wxmCurrency
		} else {
			totalEarned = LocalizableString.notAvailable.localized
		}

		if let total = userRewardsResponse?.totalClaimed?.toEthDouble {
			let claimed = total + (additionalClaimed?.toEthDouble ?? 0.0)
			totalClaimed = claimed.toWXMTokenPrecisionString + " " + StringConstants.wxmCurrency
		} else if userInfoResponse.wallet?.address == nil {
			totalClaimed = 0.0.toWXMTokenPrecisionString + " " + StringConstants.wxmCurrency
		} else {
			totalClaimed = LocalizableString.notAvailable.localized
		}

		if let available = userRewardsResponse?.available?.toEthDouble {
			let allocated = available - (additionalClaimed?.toEthDouble ?? 0.0)
			isClaimAvailable = allocated > 0.0
			let noRewardsString = LocalizableString.Profile.noRewardsDescription.localized
			let valueString = allocated.toWXMTokenPrecisionString + " " + StringConstants.wxmCurrency
			allocatedRewards = allocated == 0.0 ? noRewardsString : valueString
		} else if userInfoResponse.wallet?.address == nil {
			allocatedRewards = LocalizableString.Profile.noRewardsDescription.localized
		} else {
			allocatedRewards = LocalizableString.notAvailable.localized
			isClaimAvailable = false
		}
	}

	func updateUserInfoValues() {
		Task { @MainActor [weak self] in
			guard let self = self  else {
				return
			}
			let hasDevices = await self.meUseCase.hasOwnedDevices()
			self.rewardsIndicationType = self.isClaimAvailable ? .claimWeb : .buyStation
			self.showRewardsIndication = !hasDevices || self.isClaimAvailable
		}
	}

	func getConfigurationForSurvey(_ survey: Survey?) -> AnnouncementCardView.Configuration? {
		let action = {
			guard let urlString = survey?.url, let url = URL(string: urlString) else {
				return
			}

			Router.shared.showFullScreen(.safariView(url))
		}

		let closeAction = { [weak self] in
			guard let surveyId = survey?.id else {
				return
			}

			self?.remoteConfigUseCase.updateLastDismissedSurvey(surveyId: surveyId)
		}

		return survey?.toAnnouncementConfiguration(actionTitle: survey?.actionLabel, action: action, closeAction: closeAction)
	}
}
