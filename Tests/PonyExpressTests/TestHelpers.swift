//
//  File.swift
//
//
//  Created by Adam Wulf on 8/27/22.
//

import Foundation
import PonyExpress

struct ExampleUnmarked: UnmarkedMail {
    var info: Int
    var other: Float
}

struct ExamplePostmarked: PostmarkedMail {
    typealias RequiredSender = PostmarkedSender
    var info: Int
    var other: Float
}

class MailSender { }

class PostmarkedSender { }

// enum MultipleChoice: UnmarkedMail {
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
