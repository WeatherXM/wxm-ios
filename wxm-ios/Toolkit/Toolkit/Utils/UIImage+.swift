//
//  UIImage+.swift
//  Toolkit
//
//  Created by Pantelis Giazitsis on 14/12/23.
//

import Foundation
import UIKit

public extension UIImage {
	func saveWithName(_ name: String) -> URL? {
		guard let documentsDirectory = FileManager.documentsDirectory,
			  let data = self.pngData() else {
			return nil
		}

		let filename = documentsDirectory.appendingPathComponent(name)
		try? data.write(to: filename)
		
		return filename
	}

	func withColor(_ color: UIColor) -> UIImage? {
		UIGraphicsBeginImageContextWithOptions(size, false, scale)

		let drawRect = CGRect(x: 0,y: 0,width: size.width,height: size.height)

		color.setFill()
		UIRectFill(drawRect)

		draw(in: drawRect, blendMode: .destinationIn, alpha: 1)

		let tintedImage = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		return tintedImage
	}
}
