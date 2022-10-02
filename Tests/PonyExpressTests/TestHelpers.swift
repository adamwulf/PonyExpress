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

enum MultipleChoice: Letter {
    case option1
    case option2
    case option3
}

struct ExampleNotification: Letter {
    var info: Int
    var other: Float
}

struct OtherNotification: Letter {
    var fumble: Int
    var bumble: String
}

class ExampleRecipient: Recipient {
    typealias Letter = ExampleNotification
    private(set) var count = 0

    var block: (() -> Void)?

    func receive(letter: ExampleNotification, sender: AnyObject?) {
        count += 1
        block?()
    }
}
