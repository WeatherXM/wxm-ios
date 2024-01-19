//
//  DeviceUpdatesLoadingView.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 9/3/23.
//

import SwiftUI

struct DeviceUpdatesLoadingView: View {
    var topTitle: String?
    var topSubtitle: String?
    let title: String
    var subtitle: AttributedString?
    var steps: [StepsView.Step] = []
    @Binding var currentStepIndex: Int?
    @Binding var progress: UInt?

    @State private var stepsViewSize: CGSize = .zero
    private let iconDimensions: CGFloat = 150

    var body: some View {
        ZStack {
            Color(colorEnum: .top)
                .ignoresSafeArea()

            VStack(spacing: CGFloat(.defaultSpacing)) {
                VStack(spacing: CGFloat(.smallSpacing)) {
                    if let topTitle {
                        Text(topTitle)
                            .font(.system(size: CGFloat(.caption)))
                            .foregroundColor(Color(colorEnum: .text))
                    }

                    if let topSubtitle {
                        Text(topSubtitle)
                            .font(.system(size: CGFloat(.normalFontSize), weight: .bold))
                            .foregroundColor(Color(colorEnum: .text))
                    }
                }

                lottieViewLoading
                    .background {
                        Circle().foregroundColor(Color(colorEnum: .layer2))
                    }

                VStack(spacing: CGFloat(.smallSpacing)) {
                    Text(title)
                        .font(.system(size: CGFloat(.largeTitleFontSize), weight: .bold))
                        .foregroundColor(Color(colorEnum: .text))

                    if let attributedText = subtitle {
                        Text(attributedText)
                            .font(.system(size: CGFloat(.mediumFontSize)))
                            .foregroundColor(Color(colorEnum: .text))
                            .multilineTextAlignment(.center)
                    }
                }

                stepsView
            }
            .animation(.easeIn(duration: 0.1), value: currentStepIndex)
        }
    }
}

private extension DeviceUpdatesLoadingView {
    @ViewBuilder
    var lottieViewLoading: some View {
        LottieView(animationCase: AnimationsEnums.loading.animationString, loopMode: .loop)
            .frame(width: iconDimensions, height: iconDimensions)
    }

    @ViewBuilder
    var stepsView: some View {
        VStack(spacing: CGFloat(.smallSpacing)) {
            StepsView(steps: steps, currentStepIndex: $currentStepIndex)
                .sizeObserver(size: $stepsViewSize)

            if let progress = progress {
                ProgressView(value: Float(progress), total: 100)
                    .progressViewStyle(ProgressBarStyle(text: "\(progress)%", bgColor: Color(colorEnum: .layer2), progressColor: Color(colorEnum: .darkestBlue)))
                    .frame(width: stepsViewSize.width, height: 22.0)
            }
        }
    }
}

struct DeviceUpdatesLoadingView_Previews: PreviewProvider {
    static var previews: some View {
        DeviceUpdatesLoadingView(topTitle: "Firmware Version",
                                 topSubtitle: "23.243.01 → 23.243.02",
                                 title: "Title",
                                 steps: [StepsView.Step(text: "Download Firmware Update",
                                                        isCompleted: true),
                                         StepsView.Step(text: "Connect to Station",
                                                        isCompleted: true),
                                         StepsView.Step(text: "Install Firmware Update",
                                                        isCompleted: false)],
                                 currentStepIndex: .constant(2),
                                 progress: .constant(nil))
    }
}
