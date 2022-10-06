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

struct ExampleLetter: Letter {
    var info: Int
    var other: Float
}

class ExampleObjectLetter: Letter {
    var info: Int
    var other: Float

    init(info: Int, other: Float) {
        self.info = info
        self.other = other
    }
}

class ExampleSubObjectLetter: ExampleObjectLetter {
    var stuff: Double

    init(info: Int, other: Float, stuff: Double) {
        self.stuff = stuff
        super.init(info: info, other: other)
    }
}

class ExampleRecipient: Recipient {
    typealias Letter = ExampleLetter
    private(set) var count = 0

    var block: (() -> Void)?

    func receive(letter: ExampleLetter, sender: AnyObject?) {
        count += 1
        block?()
    }
}

class OtherRecipient {
    private(set) var count = 0

    var block: (() -> Void)?

    func receive(letter: ExampleLetter, sender: AnyObject?) {
        count += 1
        block?()
    }
}
