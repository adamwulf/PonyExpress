//
//  Letter.swift
//  
//
//  Created by Adam Wulf on 8/27/22.
//

import Foundation

/// `Letter` encapsulates information broadcast to observers via a `PostOffice`.
public struct Letter<T> {
    public let name: Notification.Name
    public let sender: AnyObject?
    public let contents: T?
}
