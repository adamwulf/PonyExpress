import XCTest
@testable import PonyExpress

final class VerifiedMethodTests: XCTestCase {
    func testVerifiedMail() throws {
        let notification = ExampleVerifiedMail(info: 1, other: 2)
        let sender = VerifiedMailSender()
        let postOffice = PostOffice()

        class SpecificRecipient {
            var count = 0
            func receiveVerifiedMail1(notification: ExampleVerifiedMail, sender: VerifiedMailSender) {
                count += 1
            }
            func receiveVerifiedMail2(notification: ExampleVerifiedMail) {
                count += 1
            }
        }

        let recipient = SpecificRecipient()

        postOffice.register(recipient, SpecificRecipient.receiveVerifiedMail1)
        postOffice.register(recipient, SpecificRecipient.receiveVerifiedMail2)

        postOffice.post(notification, sender: sender)
        // hit the method with and without a sender
        XCTAssertEqual(recipient.count, 2)
        // hit all methods
        postOffice.post(notification, sender: sender)
        XCTAssertEqual(recipient.count, 4)
    }

    func testUnregisterByIdVerifiedMail() throws {
        let notification = ExampleVerifiedMail(info: 1, other: 2)
        let sender = VerifiedMailSender()
        let postOffice = PostOffice()

        class SpecificRecipient {
            var count = 0
            func receiveVerifiedMail1(notification: ExampleVerifiedMail, sender: VerifiedMailSender) {
                count += 1
            }
            func receiveVerifiedMail3(notification: ExampleVerifiedMail) {
                count += 1
            }
        }

        let recipient = SpecificRecipient()

        let id1 = postOffice.register(recipient, SpecificRecipient.receiveVerifiedMail1)
        let id2 = postOffice.register(recipient, SpecificRecipient.receiveVerifiedMail3)

        postOffice.post(notification, sender: sender)

        XCTAssertEqual(recipient.count, 2)

        postOffice.unregister(id1)
        postOffice.post(notification, sender: sender)

        XCTAssertEqual(recipient.count, 3)

        postOffice.unregister(id2)
        postOffice.post(notification, sender: sender)

        XCTAssertEqual(recipient.count, 3)
    }

    func testUnregisterByObjVerifiedMail() throws {
        let notification = ExampleVerifiedMail(info: 1, other: 2)
        let sender = VerifiedMailSender()
        let postOffice = PostOffice()

        class SpecificRecipient {
            var count = 0
            func receiveVerifiedMail1(notification: ExampleVerifiedMail, sender: VerifiedMailSender) {
                count += 1
            }
            func receiveVerifiedMail3(notification: ExampleVerifiedMail) {
                count += 1
            }
        }

        let recipient = SpecificRecipient()

        postOffice.register(recipient, SpecificRecipient.receiveVerifiedMail1)
        postOffice.register(recipient, SpecificRecipient.receiveVerifiedMail3)

        postOffice.unregister(recipient)

        postOffice.post(notification, sender: sender)

        XCTAssertEqual(recipient.count, 0)
    }

    func testVerifiedMailQueue() throws {
        let bgQueue = DispatchQueue(label: "test.queue")
        let notification = ExampleVerifiedMail(info: 1, other: 2)
        let sender = VerifiedMailSender()
        let postOffice = PostOffice()

        class SpecificRecipient {
            var count = 0
            func receiveVerifiedMail1(notification: ExampleVerifiedMail, sender: VerifiedMailSender) {
                count += 1
            }
            func receiveVerifiedMail3(notification: ExampleVerifiedMail) {
                count += 1
            }
        }

        let exp = expectation(description: "wait for notification")
        let recipient = SpecificRecipient()

        postOffice.register(queue: bgQueue, recipient, SpecificRecipient.receiveVerifiedMail1)
        postOffice.register(queue: bgQueue, recipient, SpecificRecipient.receiveVerifiedMail3)

        bgQueue.sync {
            exp.fulfill()
        }

        postOffice.post(notification, sender: sender)

        wait(for: [exp], timeout: 0.1)
        XCTAssertEqual(recipient.count, 2)
    }

    func testVerifiedMailRequiredSender() throws {
        let notification = ExampleVerifiedMail(info: 1, other: 2)
        let sender = VerifiedMailSender()
        let postOffice = PostOffice()

        class SpecificRecipient {
            var count = 0
            func receiveVerifiedMail1(notification: ExampleVerifiedMail, sender: VerifiedMailSender) {
                count += 1
            }
            func receiveVerifiedMail3(notification: ExampleVerifiedMail) {
                count += 1
            }
        }

        let recipient = SpecificRecipient()

        postOffice.register(sender: sender, recipient, SpecificRecipient.receiveVerifiedMail1)
        postOffice.register(sender: sender, recipient, SpecificRecipient.receiveVerifiedMail3)

        postOffice.post(notification, sender: sender)

        XCTAssertEqual(recipient.count, 2)
    }

    func testVerifiedMailWrongSender() throws {
        let notification = ExampleVerifiedMail(info: 1, other: 2)
        let sender1 = VerifiedMailSender()
        let sender2 = VerifiedMailSender()
        let postOffice = PostOffice()

        class SpecificRecipient {
            var count = 0
            func receiveVerifiedMail1(notification: ExampleVerifiedMail, sender: VerifiedMailSender) {
                count += 1
            }
            func receiveVerifiedMail3(notification: ExampleVerifiedMail) {
                count += 1
            }
        }

        let recipient = SpecificRecipient()

        postOffice.register(sender: sender1, recipient, SpecificRecipient.receiveVerifiedMail1)
        postOffice.register(sender: sender1, recipient, SpecificRecipient.receiveVerifiedMail3)

        postOffice.post(notification, sender: sender2)

        XCTAssertEqual(recipient.count, 0)
    }

    func testVerifiedMailSubSender() throws {
        class SubSender: VerifiedMailSender { }
        let notification = ExampleVerifiedMail(info: 1, other: 2)
        let sender = SubSender()
        let postOffice = PostOffice()

        class SpecificRecipient {
            var count = 0
            func receiveVerifiedMail1(notification: ExampleVerifiedMail, sender: VerifiedMailSender) {
                count += 1
            }
            func receiveVerifiedMail3(notification: ExampleVerifiedMail) {
                count += 1
            }
        }

        let recipient = SpecificRecipient()

        postOffice.register(sender: sender, recipient, SpecificRecipient.receiveVerifiedMail1)
        postOffice.register(sender: sender, recipient, SpecificRecipient.receiveVerifiedMail3)

        postOffice.post(notification, sender: sender)

        XCTAssertEqual(recipient.count, 2)
    }

    func testSubVerifiedMail() throws {
        class ClassNotification: VerifiedMail {
            typealias RequiredSender = VerifiedMailSender
        }

        class SubClassNotification: ClassNotification { }
        let notification = SubClassNotification()
        let sender = VerifiedMailSender()
        let postOffice = PostOffice()

        class SpecificRecipient {
            var count = 0
            func receiveVerifiedMail1(notification: ClassNotification, sender: VerifiedMailSender) {
                count += 1
            }
            func receiveVerifiedMail3(notification: ClassNotification) {
                count += 1
            }
        }

        let recipient = SpecificRecipient()

        postOffice.register(sender: sender, recipient, SpecificRecipient.receiveVerifiedMail1)
        postOffice.register(sender: sender, recipient, SpecificRecipient.receiveVerifiedMail3)

        postOffice.post(notification, sender: sender)

        XCTAssertEqual(recipient.count, 2)
    }

    func testSubVerifiedMail2() throws {
        class ClassNotification: VerifiedMail {
            typealias RequiredSender = VerifiedMailSender
        }

        class SubClassNotification: ClassNotification { }
        let notification = ClassNotification()
        let sender = VerifiedMailSender()
        let postOffice = PostOffice()

        class SpecificRecipient {
            var count = 0
            func receiveVerifiedMail1(notification: SubClassNotification, sender: VerifiedMailSender) {
                count += 1
            }
            func receiveVerifiedMail3(notification: SubClassNotification) {
                count += 1
            }
        }

        let recipient = SpecificRecipient()

        postOffice.register(sender: sender, recipient, SpecificRecipient.receiveVerifiedMail1)
        postOffice.register(sender: sender, recipient, SpecificRecipient.receiveVerifiedMail3)

        postOffice.post(notification, sender: sender)

        XCTAssertEqual(recipient.count, 0)
    }

    func testRegisteredCount() throws {
        let postOffice = PostOffice()

        class SpecificRecipient {
            var count = 0
            func receiveVerifiedMail1(notification: ExampleVerifiedMail, sender: VerifiedMailSender) {
                count += 1
            }
            func receiveVerifiedMail2(notification: ExampleVerifiedMail) {
                count += 1
            }
        }

        let recipient = SpecificRecipient()

        postOffice.register(recipient, SpecificRecipient.receiveVerifiedMail1)
        XCTAssertEqual(postOffice.count, 1)
        postOffice.register(recipient, SpecificRecipient.receiveVerifiedMail2)
        XCTAssertEqual(postOffice.count, 2)
        postOffice.unregister(recipient)
        XCTAssertEqual(postOffice.count, 0)
    }
}
