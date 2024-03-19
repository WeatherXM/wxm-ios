//
//  StepsView.swift
//  PresentationLayer
//
//  Created by Pantelis Giazitsis on 16/2/23.
//

import SwiftUI

struct StepsView: View {
    var steps: [Step] = []
    @Binding var currentStepIndex: Int?
    @State private var stepsViewSize: CGSize = .zero

    var body: some View {
        stepsView
    }
}

extension StepsView {
    @ViewBuilder
    var stepsView: some View {
        VStack(spacing: CGFloat(.smallSpacing)) {
            VStack(alignment: .leading, spacing: CGFloat(.smallSpacing)) {
                ForEach(Array(steps.enumerated()), id: \.element) { index, step in
                    let isCurrent = currentStepIndex == index

                    HStack(spacing: CGFloat(.minimumSpacing)) {
                        if step.isCompleted {
                            Image(asset: .circleCheckmark)
                                .renderingMode(.template)
                                .foregroundColor(Color(colorEnum: .darkGrey))
                        } else {
                            Text("\(index + 1)")
                                .foregroundColor(Color(colorEnum: .top))
                                .font(.system(size: CGFloat(.caption), weight: .bold))
                                .frame(width: 20.0, height: 20.0)
                                .background {
                                    Circle().foregroundColor(Color(colorEnum: isCurrent ? .text : .darkGrey))
                                }
                        }

                        let weight: Font.Weight = isCurrent ? .bold : .regular
                        Text(step.text)
                            .foregroundColor(Color(colorEnum: .text))
                            .font(.system(size: CGFloat(.mediumFontSize), weight: weight))
                    }
                }
            }
            .fixedSize(horizontal: true, vertical: false)
            .sizeObserver(size: $stepsViewSize)
        }
    }
}

extension StepsView {
    /// Step structure to render in steps list
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

struct StepsView_Previews: PreviewProvider {
    static var previews: some View {
        StepsView(currentStepIndex: .constant(nil))
    }
}
