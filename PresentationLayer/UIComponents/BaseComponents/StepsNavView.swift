//
//  StepsNavView.swift
//  PresentationLayer
//
//  Created by Manolis Katsifarakis on 1/10/22.
//

import SwiftUI

struct StepsNavView: View {
    @State var isMovingForward = false
    @State var currentStep = 0

    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    @State private var id = UUID()

    var title: String
    var steps: [Step]

    /**
     Provided to children (step) views, so that they move to the next or previous step.
     */
    final class Transport {
        let nextStep: () -> Void
        let previousStep: () -> Void
        let firstStep: () -> Void
        let isLastStep: () -> Bool
        let isFirstStep: () -> Bool
        init(
            nextStep: @escaping () -> Void,
            previousStep: @escaping () -> Void,
            firstStep: @escaping () -> Void,
            isLastStep: @escaping () -> Bool,
            isFirstStep: @escaping () -> Bool
        ) {
            self.nextStep = nextStep
            self.previousStep = previousStep
            self.firstStep = firstStep
            self.isLastStep = isLastStep
            self.isFirstStep = isFirstStep
        }
    }

    struct Step {
        var title: String
        var view: (Transport) -> AnyView
    }

    var body: some View {
        GeometryReader { _ in
			VStack(spacing: CGFloat(.minimumSpacing)) {
                customNavbar

                StepsHeaderView(steps: steps,
                                currentStep: currentStep)
				.iPadMaxWidth()
                    .animation(.easeInOut(duration: 0.2), value: currentStep)

                currentView
					.iPadMaxWidth()
                    .transition(AnyTransition.asymmetric(
                        insertion: .move(edge: isMovingForward ? .trailing : .leading),
                        removal: .move(edge: isMovingForward ? .leading : .trailing)
                    ))
                    .animation(.easeInOut(duration: 0.2), value: currentStep)
            }
        }
        .navigationBarTitle("")
        .navigationBarHidden(true)
        .background(
            Color(colorEnum: .bg).edgesIgnoringSafeArea(.all)
        )
        .ignoresSafeArea(.keyboard)
    }

    var customNavbar: some View {
        HStack {
            Button {
                let transport = getTransportObject()
                if transport.isFirstStep() {
                    self.presentationMode.wrappedValue.dismiss()
                } else {
                    transport.previousStep()
                }
            } label: {
                Image(asset: .backArrow)
                    .renderingMode(.template)
                    .foregroundColor(Color(colorEnum: .primary))
                    .padding(.leading, 14)
                    .padding(.top, 2.5)
                    .padding(.trailing, 10)
            }
            titleView
            Spacer()
        }
        .padding(.top, 12)
        .padding(.bottom, 12)
    }

    var titleView: some View {
        Text(title)
            .foregroundColor(Color(colorEnum: .text))
            .padding(.top, 2)
            .font(.system(size: CGFloat(.largeTitleFontSize)))
    }

    @State var viewCache: [Int: AnyView] = [:]

    @ViewBuilder
    var currentView: some View {
        steps[currentStep].view(getTransportObject())
            .id("\(id)step\(currentStep)")
    }

    private struct StepsHeaderView: View {
        let steps: [StepsNavView.Step]
        let currentStep: Int

        private static let CIRCLE_RADIUS: CGFloat = 22
        private static let CIRCLE_BORDER_WIDTH: CGFloat = 3
        private static let HEADER_PADDING: CGFloat = 12
        private static let STEP_LAST_PADDING: CGFloat = 10

        var body: some View {
            HStack(spacing: -(Self.CIRCLE_RADIUS + Self.CIRCLE_BORDER_WIDTH)) {
                ForEach(0 ..< steps.count, id: \.self) { index in
                    stepView(step: steps[index], index: index)
                }
            }
            .fixedSize(horizontal: false, vertical: true)
            .padding(.horizontal, CGFloat(.defaultSidePadding))
        }

        @ViewBuilder
        func stepView(step: Step, index: Int) -> some View {
            let isSelected = index == currentStep
            let isCompleted = index < currentStep
            HStack(spacing: CGFloat(.minimumSpacing)) {

                if isCompleted {
                    Image(asset: .circleCheckmark)
                        .resizable()
                        .renderingMode(.template)
                        .foregroundColor(Color(colorEnum: .text))
                        .scaledToFit()
                        .frame(width: Self.CIRCLE_RADIUS, height: Self.CIRCLE_RADIUS)
                } else {
                    Text("\(index + 1)")
                        .font(.system(size: CGFloat(.mediumFontSize), weight: .bold))
                        .foregroundColor(isSelected ? Color(colorEnum: .text) : Color(colorEnum: .top))
                        .frame(width: Self.CIRCLE_RADIUS, height: Self.CIRCLE_RADIUS)
                        .background(
                            Circle()
                                .foregroundColor(isSelected ? Color(colorEnum: .top) : Color(colorEnum: .text))
                        )
                        .strokeBorder(color: Color(colorEnum: .text), lineWidth: Self.CIRCLE_BORDER_WIDTH, radius: Self.CIRCLE_RADIUS)
                }

                Text(step.title)
                    .foregroundColor(Color(colorEnum: .text))
                    .font(
                        .system(
                            size: CGFloat(.caption),
                            weight: isSelected ? .bold : .regular
                        )
                    )
                    .multilineTextAlignment(.leading)

                Spacer(minLength: 0.0)
            }
            .frame(maxHeight: .infinity)
			.padding(CGFloat(.smallSidePadding))
            .background(Color(colorEnum: isCompleted ? .successTint : .top))
            .cornerRadius(Self.CIRCLE_RADIUS)
            .strokeBorder(color: Color(colorEnum: .bg), lineWidth: Self.CIRCLE_BORDER_WIDTH, radius: Self.CIRCLE_RADIUS)
        }
    }
}

private extension StepsNavView {
    func getTransportObject() -> Transport {
        Transport(
            nextStep: {
                if currentStep >= steps.count - 1 {
                    return
                }

                isMovingForward = true
                withAnimation {
                    currentStep += 1
                }
            },
            previousStep: {
                if currentStep <= 0 {
                    return
                }

                isMovingForward = false
                withAnimation {
                    currentStep -= 1
                }
            },
            firstStep: {
                if currentStep == 0 {
                    return
                }

                isMovingForward = false
                withAnimation {
                    currentStep = 0
                }
            },
            isLastStep: {
                currentStep == steps.count - 1
            },
            isFirstStep: {
                currentStep == 0
            }
        )
    }
}

// Enable swipe-to-go-back gesture after the back button has been customized.
extension UINavigationController: UIGestureRecognizerDelegate {
    override open func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = self
    }

    public func gestureRecognizerShouldBegin(_: UIGestureRecognizer) -> Bool {
        return viewControllers.count > 1
    }
}

struct Previews_StepsNavView_Previews: PreviewProvider {
    static var previews: some View {
        let step = StepsNavView.Step(title: LocalizableString.ClaimDevice.connectionStepTitle.localized) { _ in
            AnyView(Text(LocalizableString.ClaimDevice.connectionStepTitle.localized))
        }
        let step1 = StepsNavView.Step(title: LocalizableString.ClaimDevice.verifyStepTitle.localized) { _ in
            AnyView(Text(LocalizableString.ClaimDevice.resetStationTitle.localized))
        }

        let step2 = StepsNavView.Step(title: LocalizableString.ClaimDevice.locationStepTitle.localized) { _ in
            AnyView(Text(LocalizableString.ClaimDevice.verifyTitle.localized))
        }

        StepsNavView(title: LocalizableString.ClaimDevice.ws1000DeviceTitle.localized,
                     steps: [step, step1, step2])
    }
}
