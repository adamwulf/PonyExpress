//
//  File.swift
//
//
//  Created by Adam Wulf on 11/6/22.
//

import Foundation

/// Unlike ``UnverifiedMail``, any notification that implements ``VerifiedMail`` is required to be
/// posted with a `sender` of `RequiredSender` type.
/// - seeAlso: ``PostOffice/post(_:)`` and ``PostOffice/post(_:sender:)``
public protocol VerifiedMail {
    associatedtype RequiredSender: AnyObject
}

/// Notifications that do not require a specific sender type, or can be sent with a `nil` sender, must implement `UnverifiedMail`.
public protocol UnverifiedMail { }
