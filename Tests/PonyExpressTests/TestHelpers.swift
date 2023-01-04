//
//  File.swift
//
//
//  Created by Adam Wulf on 8/27/22.
//

import Foundation
import PonyExpress

struct ExampleUnverifiedMail: UnverifiedMail {
    var info: Int
    var other: Float
}

struct ExampleVerifiedMail: VerifiedMail {
    typealias RequiredSender = VerifiedMailSender
    var info: Int
    var other: Float
}

class UnverifiedMailSender { }

class VerifiedMailSender { }

// enum MultipleChoice: UnverifiedMail {
//    case option1
//    case option2
//    case option3
// }
//
// class SomeSender { }
//
// class ExampleRecipient {
//    fileprivate(set) var count = 0
//
//    var testBlock: (() -> Void)?
//
//    func receiveWithAnySender(notification: ExampleNotification, sender: AnyObject?) {
//        count += 1
//        testBlock?()
//    }
//
//    func receiveWithOptSender(notification: ExampleNotification, sender: ExampleSender?) {
//        count += 1
//        testBlock?()
//    }
//
//    func receiveWithSender(notification: ExampleNotification, sender: ExampleSender) {
//        count += 1
//        testBlock?()
//    }
//
//    func receiveWithoutSender(notification: ExampleNotification) {
//        count += 1
//        testBlock?()
//    }
// }
//
// class SubclassExampleRecipient: ExampleRecipient {
//    override func receiveWithSender(notification: ExampleNotification, sender: ExampleSender) {
//        count += 1
//        super.receiveWithSender(notification: notification, sender: sender)
//    }
// }
