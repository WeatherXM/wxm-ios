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
	enum State: Equatable {
		case loading(LoadingStateObject)
		case success(FailSuccessStateObject)
		case fail(FailSuccessStateObject)

		static func == (lhs: ClaimDeviceProgressView.State, rhs: ClaimDeviceProgressView.State) -> Bool {
			switch (lhs, rhs) {
				case (.loading(let lhsObj), .loading(let rhsObj)):
					return lhsObj == rhsObj
				case (.success(let lhsObj), .success(let rhsObj)):
					return lhsObj.title == rhsObj.title
				case (.fail(let lhsObj), .fail(let rhsObj)):
					return lhsObj.title == rhsObj.title
				default:
					return false
			}
		}
	}

	struct LoadingStateObject: Equatable {
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
