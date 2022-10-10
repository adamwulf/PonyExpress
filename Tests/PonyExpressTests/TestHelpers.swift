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

enum MultipleChoice {
    case option1
    case option2
    case option3
}

struct ExampleLetter {
    var info: Int
    var other: Float
}

class ExampleSender { }

class ExampleRecipient {
    private(set) var count = 0

    var block: (() -> Void)?

    func receiveWithOptSender(letter: ExampleLetter, sender: AnyObject?) {
        count += 1
        block?()
    }

    func receiveWithSender(letter: ExampleLetter, sender: AnyObject) {
        count += 1
        block?()
    }

    func receiveWithoutSender(letter: ExampleLetter) {
        count += 1
        block?()
    }
}

class OtherRecipient {
    private(set) var count = 0

    var testBlock: (() -> Void)?

    func receiveWithSender(letter: ExampleLetter, sender: AnyObject?) {
        count += 1
        testBlock?()
    }
}
