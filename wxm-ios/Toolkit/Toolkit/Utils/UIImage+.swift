//
//  UIImage+.swift
//  Toolkit
//
//  Created by Pantelis Giazitsis on 14/12/23.
//

import Foundation
import UIKit

public extension UIImage {
	func saveWithName(_ name: String, tempDirectory: Bool = false) -> URL? {
		guard let directory = tempDirectory ? FileManager.tempDirectory : FileManager.documentsDirectory,
			  let data = self.pngData() else {
			return nil
		}

		let filename = directory.appendingPathComponent(name).appendingPathExtension(for: .png)
		try? data.write(to: filename)
		
		return filename
	}

	func withColor(_ color: UIColor) -> UIImage? {
		UIGraphicsBeginImageContextWithOptions(size, false, scale)

		let drawRect = CGRect(x: 0, y: 0, width: size.width, height: size.height)

		color.setFill()
		UIRectFill(drawRect)

		draw(in: drawRect, blendMode: .destinationIn, alpha: 1)

		let tintedImage = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		return tintedImage
	}

	func scaleDown(newWidth: CGFloat) -> UIImage {
		guard size.width >= newWidth else {
			return self
		}

		let scaleFactor = newWidth / self.size.width

		let newHeight = self.size.height * scaleFactor
		let newSize = CGSize(width: newWidth, height: newHeight)

		UIGraphicsBeginImageContextWithOptions(newSize, true, 1.0)
		self.draw(in: CGRect(x: 0.0, y: 0.0, width: newWidth, height: newHeight))

		let newImage: UIImage? = UIGraphicsGetImageFromCurrentImageContext()

		UIGraphicsEndImageContext()

		return newImage ?? self
	}
}

public extension CGImagePropertyOrientation {
	init(_ uiOrientation: UIImage.Orientation) {
		switch uiOrientation {
			case .up: self = .up
			case .down: self = .down
			case .left: self = .left
			case .right: self = .right
			case .upMirrored: self = .upMirrored
			case .downMirrored: self = .downMirrored
			case .leftMirrored: self = .leftMirrored
			case .rightMirrored: self = .rightMirrored
			@unknown default: self = .up
		}
	}
}
