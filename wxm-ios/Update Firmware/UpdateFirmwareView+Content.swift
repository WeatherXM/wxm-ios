//
//  UpdateFirmwareView+Content.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 3/2/23.
//

import PresentationLayer
import SwiftUI

extension UpdateFirmwareView {
    struct Step: Hashable {
        var id: String {
            text
        }

        let text: String
        var isCompleted: Bool

        mutating func setCompleted(_ completed: Bool) {
            isCompleted = completed
        }
    }
}

extension UpdateFirmwareView {
    @ViewBuilder
    var installationView: some View {
        VStack(spacing: 20.0) {
            lottieViewLoading
                .background {
                    Circle().foregroundColor(Color(.light2))
                }

            VStack(spacing: 10.0) {
                Text(viewModel.title)
                    .font(.system(size: CGFloat(.largeTitleFontSize), weight: .bold))
                    .foregroundColor(Color(.black))

                if let attributedText = viewModel.subtile {
                    Text(attributedText)
                        .font(.system(size: CGFloat(.mediumFontSize)))
                        .foregroundColor(Color(.black))
                }
            }

            stepsView
        }
    }
}

private extension UpdateFirmwareView {
    @ViewBuilder
    var lottieViewLoading: some View {
        LottieView(animationCase: AnimationsEnums.loading.animationString, loopMode: .loop)
            .frame(width: CGFloat(IntConstants.iconDimensions), height: CGFloat(IntConstants.iconDimensions))
    }

    @ViewBuilder
    var stepsView: some View {
        VStack(spacing: 10.0) {
            VStack(alignment: .leading, spacing: 10.0) {
                ForEach(Array(viewModel.steps.enumerated()), id: \.element) { index, step in
                    let isCurrent = viewModel.currentStepIndex == index

                    HStack(spacing: 5.0) {
                        if step.isCompleted {
                            Image(.circleCheckmark)
                                .renderingMode(.template)
                                .foregroundColor(Color(.darkGrey))
                        } else {
                            Text("\(index)")
                                .foregroundColor(Color(.white))
                                .font(.system(size: CGFloat(.caption), weight: .bold))
                                .frame(width: 20.0, height: 20.0)
                                .background {
                                    Circle().foregroundColor(Color(isCurrent ? .black : .midGrey))
                                }
                        }

                        let weight: Font.Weight = isCurrent ? .bold : .regular
                        Text(step.text)
                            .foregroundColor(Color(.black))
                            .font(.system(size: CGFloat(.mediumFontSize), weight: weight))
                    }
                }
            }
            .fixedSize(horizontal: true, vertical: false)
            .sizeObserver(size: $stepsViewSize)

            if let progress = viewModel.progress {
                ProgressView(value: Float(progress), total: 100)
                    .progressViewStyle(ProgressBarStyle(text: .constant("Hellloz"), bgColor: Color(.light2), progressColor: Color(.darkestBlue)))
                    .frame(width: stepsViewSize.width, height: 22.0)
            }
        }
    }
}
