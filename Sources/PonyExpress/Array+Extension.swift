//
//  File.swift
//
//
//  Created by Adam Wulf on 12/13/22.
//

import Foundation

extension Array {
    @inlinable func excluding(_ isExcluded: (Element) throws -> Bool) rethrows -> [Element] {
        return try filter({ try !isExcluded($0) })
    }
}
