//
//  File.swift
//
//
//  Created by Adam Wulf on 8/27/22.
//

import Foundation
import PonyExpress

enum MultipleChoice: Mail {
    case option1
    case option2
    case option3
}

struct ExampleNotification: Mail {
    var info: Int
    var other: Float
}

class SomeSender { }

class ExampleSender { }

class ExampleRecipient {
    private(set) var count = 0

    var testBlock: (() -> Void)?

    func receiveWithAnySender(notification: ExampleNotification, sender: AnyObject?) {
        count += 1
        testBlock?()
    }

    func receiveWithOptSender(notification: ExampleNotification, sender: ExampleSender?) {
        count += 1
        testBlock?()
    }

    func receiveWithSender(notification: ExampleNotification, sender: ExampleSender) {
        count += 1
        testBlock?()
    }

    func receiveWithoutSender(notification: ExampleNotification) {
        count += 1
        testBlock?()
    }
}
