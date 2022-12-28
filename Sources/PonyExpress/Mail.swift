//
//  File.swift
//
//
//  Created by Adam Wulf on 11/6/22.
//

import Foundation

/// Unlike ``Mail``, any notification that implements ``PostMarked`` is required to be
/// posted with a `sender` of `RequiredSender` type.
/// - seeAlso: ``PostOffice/post(_:)`` and ``PostOffice/post(_:sender:)``
public protocol PostMarked {
    associatedtype RequiredSender: AnyObject
}

/// All notifications sent through a ``PostOffice`` must conform to `Mail`.
public protocol Mail { }
