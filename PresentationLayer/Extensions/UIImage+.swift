//
//  UIImage+.swift
//  DomainLayer
//
//  Created by Lampros Zouloumis on 29/8/22.
//

import struct UIKit.CGAffineTransform
import struct UIKit.CGFloat
import struct UIKit.CGPoint
import struct UIKit.CGRect
import func UIKit.UIGraphicsBeginImageContextWithOptions
import func UIKit.UIGraphicsEndImageContext
import func UIKit.UIGraphicsGetCurrentContext
import func UIKit.UIGraphicsGetImageFromCurrentImageContext
import class UIKit.UIImage
import Foundation

extension UIImage {
    func rotate(degrees: Float) -> UIImage {
        let radians = degrees * .pi / 180.0
        var newSize = CGRect(origin: CGPoint.zero, size: self.size).applying(CGAffineTransform(rotationAngle: CGFloat(radians))).size
        // Trim off the extremely small float value to prevent core graphics from rounding it up
        newSize.width = floor(newSize.width)
        newSize.height = floor(newSize.height)

        UIGraphicsBeginImageContextWithOptions(newSize, false, self.scale)
        guard let context = UIGraphicsGetCurrentContext() else { return UIImage() }

        // Move origin to middle
        context.translateBy(x: newSize.width / 2, y: newSize.height / 2)
        // Rotate around middle
        context.rotate(by: CGFloat(radians))
        // Draw the image at its center
        self.draw(in: CGRect(x: -self.size.width / 2, y: -self.size.height / 2, width: self.size.width, height: self.size.height))

        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage ?? UIImage()
    }
}
