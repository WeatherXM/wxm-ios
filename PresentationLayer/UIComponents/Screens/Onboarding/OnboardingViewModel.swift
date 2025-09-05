//
//  OnboardingViewModel.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 3/9/25.
//

import Foundation
import SwiftUI

@MainActor
class OnboardingViewModel: ObservableObject {

	func handleSignUpButtonTap(show: Binding<Bool>) {
		let viewModel = ViewModelsFactory.getRegisterViewModel { [weak self] in
			show.wrappedValue.toggle()
		}

		Router.shared.navigateTo(.register(viewModel))
	}

	func handleExploreAppButtonTap() {

	}
}

extension OnboardingViewModel: HashableViewModel {
	nonisolated func hash(into hasher: inout Hasher) { }
}
