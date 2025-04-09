//
//  AppUpdateViewModel.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 6/12/23.
//

import Foundation
import UIKit
import Toolkit
import DomainLayer
import Combine

@MainActor
class AppUpdateViewModel: ObservableObject {
	@Published var whatsNewText: String?
	@Published var forceUpdate: Bool = false
	
	private var cancellableSet: Set<AnyCancellable> = .init()
	private let useCase: MainUseCaseApi
	private let linkNavigation: LinkNavigation

	init(useCase: MainUseCaseApi,
		 linkNavigation: LinkNavigation = LinkNavigationHelper()) {
		self.useCase = useCase
		self.linkNavigation = linkNavigation

		RemoteConfigManager.shared.$iosAppChangelog.assign(to: &$whatsNewText)

		RemoteConfigManager.shared.$iosAppMinimumVersion.sink { [weak self] minVersion in
			guard let self, let minVersion else {
				return
			}
			
			self.forceUpdate = self.useCase.shouldForceUpdate(minimumVersion: minVersion, currentVersion: nil)
		}.store(in: &cancellableSet)
	}

	func viewAppeared() {
		WXMAnalytics.shared.trackScreen(.appUpdatePrompt)
	}
	
	func handleUpdateButtonTap() {
		linkNavigation.openUrl(DisplayedLinks.appstore.linkURL)

		if let version = RemoteConfigManager.shared.iosAppLatestVersion {
			useCase.updateLastAppVersionPrompt(with: version)
		}

		WXMAnalytics.shared.trackEvent(.userAction,
									   parameters: [.actionName: .appUpdatePromptResult,
													.contentType: .appUpdatePrompt,
													.action: .update])
	}

	func handleNoUpdateButtonTap() {
		if let version = RemoteConfigManager.shared.iosAppLatestVersion {
			useCase.updateLastAppVersionPrompt(with: version)
		}

		WXMAnalytics.shared.trackEvent(.userAction,
									   parameters: [.actionName: .appUpdatePromptResult,
													.contentType: .appUpdatePrompt,
													.action: .discard])
	}
}
