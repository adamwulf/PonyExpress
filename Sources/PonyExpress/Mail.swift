//
//  File.swift
//
//
//  Created by Adam Wulf on 11/6/22.
//

import Foundation

/// Unlike ``Postmarked``, any notification that implements ``Mail`` is not required to be
/// posted with a `sender`.
/// - seeAlso: ``PostOffice/post(_:)`` and ``PostOffice/post(_:sender:)``
public protocol Mail: PostMarked { }

/// All notifications sent through a ``PostOffice`` must conform to `Postmarked`.
/// If a notification object implements ``Postmarked`` but does not implement ``Mail``, then it
/// _must_ be posted with a `sender`.
/// - seeAlso: ``PostOffice/post(_:)`` and ``PostOffice/post(_:sender:)``
public protocol PostMarked { }
