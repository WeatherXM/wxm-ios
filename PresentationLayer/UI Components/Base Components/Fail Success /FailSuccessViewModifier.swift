//
//  FailSuccessViewModifier.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 20/6/23.
//

import SwiftUI

private struct FailSuccessModifier: ViewModifier {
    @Binding var show: Bool
    let isSuccess: Bool
    let obj: FailSuccessStateObject

    func body(content: Content) -> some View {
        content
            .if(show) { view in
                view.hidden()
            }
            .overlay {
                if show {
                    stateView
						.iPadMaxWidth()
                        .padding()
                }
            }
    }

    @ViewBuilder
    private var stateView: some View {
        if isSuccess {
            SuccessView(obj: obj)
        } else {
            FailView(obj: obj)
        }
    }
}

extension View {
    @ViewBuilder
    func fail(show: Binding<Bool>, obj: FailSuccessStateObject?) -> some View {
        if let obj {
            modifier(FailSuccessModifier(show: show, isSuccess: false, obj: obj))
        } else {
            self
        }
    }

    @ViewBuilder
    func success(show: Binding<Bool>, obj: FailSuccessStateObject?) -> some View {
        if let obj {
            modifier(FailSuccessModifier(show: show, isSuccess: true, obj: obj))
        } else {
            self
        }
    }
}

struct Previews_Fail_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Color.gray
                .ignoresSafeArea()
        }
        .fail(show: .constant(true), obj: .mockErrorObj)
        .padding()
    }
}

struct Previews_Success_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Color.gray
                .ignoresSafeArea()
        }
        .success(show: .constant(true), obj: .mockSuccessObj)
        .padding()
    }
}
