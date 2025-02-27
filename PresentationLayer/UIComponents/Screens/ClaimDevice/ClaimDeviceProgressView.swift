//
//  ClaimDeviceProgressView.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 17/5/24.
//

import SwiftUI
import Toolkit

struct ClaimDeviceProgressView: View {
	@Binding var state: State

    var body: some View {
		ZStack {
			Color(colorEnum: .topBG)
				.ignoresSafeArea()
			Group {
				switch state {
					case .loading(let obj):
						DeviceUpdatesLoadingView(title: obj.title,
												 subtitle: obj.subtitle,
												 steps: obj.steps,
												 currentStepIndex: .constant(obj.stepIndex),
												 progress: .constant(obj.progress))
					case .success(let object):
						SuccessView(obj: object)
							.onAppear {
								WXMAnalytics.shared.trackEvent(.viewContent, parameters: [.success: .custom("1")])
							}
					case .fail(let object):
						FailView(obj: object)
							.onAppear {
								WXMAnalytics.shared.trackEvent(.viewContent, parameters: [.success: .custom("0")])
							}
				}
			}
			.padding()
		}
		.iPadMaxWidth()
    }
}

extension ClaimDeviceProgressView {
	enum State {
		case loading(LoadingStateObject)
		case success(FailSuccessStateObject)
		case fail(FailSuccessStateObject)
	}

	struct LoadingStateObject {
		let title: String
		let subtitle: AttributedString?
		var steps: [StepsView.Step] = []
		var stepIndex: Int?
		var progress: UInt?
	}
}

#Preview {
	ClaimDeviceProgressView(state: .constant(.loading(.init(title: "Title", subtitle: "Subtitle"))))
}
