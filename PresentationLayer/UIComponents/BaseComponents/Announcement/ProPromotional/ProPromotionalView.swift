//
//  ProPromotionalView.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 21/3/25.
//

import SwiftUI

struct ProPromotionalView: View {
	@StateObject var viewModel: ProPromotionalViewModel

	var body: some View {
		VStack {
			LinearGradient(
				stops: [
					Gradient.Stop(color: Color(red: 0.16, green: 0.15, blue: 0.45), location: 0.00),
					Gradient.Stop(color: Color(red: 0.47, green: 0.23, blue: 0.69), location: 0.49),
					Gradient.Stop(color: Color(red: 0.3, green: 0.12, blue: 0.66), location: 1.00),
				],
				startPoint: UnitPoint(x: 0, y: 1),
				endPoint: UnitPoint(x: 1, y: 0)
			)
			.aspectRatio(1.7, contentMode: .fit)
		}
    }
}

#Preview {
	ProPromotionalView(viewModel: ViewModelsFactory.getProPromotionalViewModel())
}
