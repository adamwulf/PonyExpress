//
//  File.swift
//  
//
//  Created by Adam Wulf on 8/27/22.
//

import Foundation
import PonyExpress

// Create a static shared PostOffice
private let globalShared = PostOffice()
public extension PostOffice {
    static var shared: PostOffice {
        return globalShared
    }
}
