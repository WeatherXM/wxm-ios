//
//  WXMDivider.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 25/4/23.
//

import SwiftUI

struct WXMDivider: View {
    var body: some View {
        Divider()
            .foregroundColor(Color(colorEnum: .midGrey))
    }
}

struct WXMDivider_Previews: PreviewProvider {
    static var previews: some View {
        WXMDivider()
    }
}
