//
//  File.swift
//  
//
//  Created by Adam Wulf on 10/1/22.
//

import Foundation

public protocol Letter {
    static var name: String { get }
}

public extension Letter {
    static var name: String {
        return String(describing: Self.self)
    }
}
