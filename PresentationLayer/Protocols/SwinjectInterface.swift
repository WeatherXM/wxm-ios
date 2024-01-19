//
//  SwinjectInterface.swift
//  PresentationLayer
//
//  Created by Hristos Condrea on 6/5/22.
//

import Foundation
import Swinject

public protocol SwinjectInterface {
    func getContainerForSwinject() -> Container
}
