//
//  PhotosRepository.swift
//  DomainLayer
//
//  Created by Pantelis Giazitsis on 10/12/24.
//

import Foundation
import UIKit

public protocol PhotosRepository: Sendable {
	func saveImage(_ image: UIImage) throws -> String?
}
