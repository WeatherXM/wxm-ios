//
//  FileStorage+.swift
//  Toolkit
//
//  Created by Pantelis Giazitsis on 10/12/24.
//

import Foundation

public extension FileManager {
	func getDocumentsDirectory() -> URL {
		let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
		let documentsDirectory = paths[0]
		return documentsDirectory
	}
}

public extension URL {
	func createDirectory() {
		if !FileManager.default.fileExists(atPath: self.path) {
			do {
				try FileManager.default.createDirectory(at: self, withIntermediateDirectories: true, attributes: nil)
			}
			catch let error  {
				print("Unable to create directory \(error)")
			}
		}
	}

}
