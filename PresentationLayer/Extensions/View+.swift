//
//  View+.swift
//  PresentationLayer
//
//  Created by Hristos Condrea on 18/5/22.
//

import Foundation
import SwiftUI

extension View {
    var toAnyView: AnyView {
        AnyView(self)
    }
    
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
