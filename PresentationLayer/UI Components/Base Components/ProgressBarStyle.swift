//
//  ProgressBarStyle.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 3/2/23.
//

import SwiftUI

struct ProgressBarStyle: ProgressViewStyle {
	var withOffset: Bool = false
    var text: String?
    var bgColor: Color = Color(colorEnum: .midGrey)
    var progressColor: Color = Color(colorEnum: .primary)

    @State private var textFrame: CGRect = .zero
    @State private var progressSize: CGSize = .zero

    func makeBody(configuration: Configuration) -> some View {
        GeometryReader { geometry in
            ZStack {
                bgColor
                HStack(spacing: 0.0) {
                    progressColor
						.frame(width: progressWidth(with: configuration.fractionCompleted ?? 0,
													containerSize: geometry.size))
                        .clipShape(Capsule())
                        .animation(.linear, value: configuration.fractionCompleted)
                        .sizeObserver(size: $progressSize)

                    Spacer(minLength: 0.0)
                }

                HStack(spacing: 0.0) {
                    Color(.white)
                        .frame(width: progressSize.width)
                        .clipShape(Capsule())
                        .animation(.linear, value: configuration.fractionCompleted)

                    progressColor
                }.mask {
                    if let text {
                        Text(text)
                            .font(.system(size: CGFloat(.caption)))
                            .transaction { transaction in
                                transaction.animation = nil
                            }
                    }
                }
            }
            .clipShape(Capsule())
        }
    }
}

private extension ProgressBarStyle {
	func progressWidth(with value: Double, containerSize: CGSize) -> CGFloat {
		let offset = withOffset ? containerSize.width / 10.0 : 0.0
		let actualContainerWidth = containerSize.width - offset
		let width = value * actualContainerWidth
		return width + offset
	}
}

struct ProgressBarStyle_Previews: PreviewProvider {
    static var previews: some View {
        ProgressView(value: 5,
                     total: 10)
            .progressViewStyle(ProgressBarStyle(withOffset: true, text: "\(4)"))
            .previewLayout(.fixed(width: 256, height: 22))
    }
}
