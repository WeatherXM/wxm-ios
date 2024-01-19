//
//  Image+.swift
//  PresentationLayer
//
//  Created by Danae Kikue Dimou on 10/5/22.
//

import Foundation
import SwiftUI

extension Image {
    init(asset: AssetEnum) {
        self.init(asset.rawValue)
    }
}

extension UIImage {
    convenience init?(named asset: AssetEnum) {
        self.init(named: asset.rawValue)
    }
}
