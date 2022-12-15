//
//  File.swift
//
//
//  Created by Adam Wulf on 11/6/22.
//

import Foundation

/// All notifications sent through a ``PostOffice`` must conform to `Mail`.
/// - seeAlso: ``PostOffice/post(_:)`` and ``PostOffice/post(_:sender:)``
public protocol Mail: PostMarked { }

public protocol PostMarked { }
