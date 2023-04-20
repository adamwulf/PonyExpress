import XCTest
@testable import PonyExpress

final class UnverifiedMailMailMethodTests: XCTestCase {
    func testMail() throws {
        let notification = ExampleUnverifiedMail(info: 1, other: 2)
        let sender = UnverifiedMailSender()
        let postOffice = PostOffice()

        class SpecificRecipient {
            var count = 0
            func receiveUnverifiedMail1(notification: ExampleUnverifiedMail, sender: UnverifiedMailSender) {
                count += 1
            }
            func receiveUnverifiedMail2(notification: ExampleUnverifiedMail, sender: UnverifiedMailSender?) {
                count += 1
            }
            func receiveUnverifiedMail3(notification: ExampleUnverifiedMail) {
                count += 1
            }
        }

        let recipient = SpecificRecipient()

        postOffice.register(recipient, SpecificRecipient.receiveUnverifiedMail1)
        postOffice.register(recipient, SpecificRecipient.receiveUnverifiedMail2)
        postOffice.register(recipient, SpecificRecipient.receiveUnverifiedMail3)

        postOffice.post(notification)
        // hit the method w/o a sender and with a nullable sender, miss the method with required sender
        XCTAssertEqual(recipient.count, 2)
        // hit all three methods
        postOffice.post(notification, sender: sender)
        XCTAssertEqual(recipient.count, 5)
    }

    func testUnregisterByIdUnverifiedMail() throws {
        let notification = ExampleUnverifiedMail(info: 1, other: 2)
        let sender = UnverifiedMailSender()
        let postOffice = PostOffice()

        class SpecificRecipient {
            var count = 0
            func receiveUnverifiedMail1(notification: ExampleUnverifiedMail, sender: UnverifiedMailSender) {
                count += 1
            }
            func receiveUnverifiedMail2(notification: ExampleUnverifiedMail, sender: UnverifiedMailSender?) {
                count += 1
            }
            func receiveUnverifiedMail3(notification: ExampleUnverifiedMail) {
                count += 1
            }
        }

        let recipient = SpecificRecipient()

        let id1 = postOffice.register(recipient, SpecificRecipient.receiveUnverifiedMail1)
        let id2 = postOffice.register(recipient, SpecificRecipient.receiveUnverifiedMail2)
        let id3 = postOffice.register(recipient, SpecificRecipient.receiveUnverifiedMail3)

        postOffice.post(notification, sender: sender)

        XCTAssertEqual(recipient.count, 3)

        postOffice.unregister(id1)
        postOffice.post(notification, sender: sender)

        XCTAssertEqual(recipient.count, 5)

        postOffice.unregister(id2)
        postOffice.post(notification, sender: sender)

        XCTAssertEqual(recipient.count, 6)

        postOffice.unregister(id3)
        postOffice.post(notification, sender: sender)

        XCTAssertEqual(recipient.count, 6)
    }

    func testUnregisterByObjUnverifiedMail() throws {
        let notification = ExampleUnverifiedMail(info: 1, other: 2)
        let sender = UnverifiedMailSender()
        let postOffice = PostOffice()

        class SpecificRecipient {
            var count = 0
            func receiveUnverifiedMail1(notification: ExampleUnverifiedMail, sender: UnverifiedMailSender) {
                count += 1
            }
            func receiveUnverifiedMail2(notification: ExampleUnverifiedMail, sender: UnverifiedMailSender?) {
                count += 1
            }
            func receiveUnverifiedMail3(notification: ExampleUnverifiedMail) {
                count += 1
            }
        }

        let recipient = SpecificRecipient()

        postOffice.register(recipient, SpecificRecipient.receiveUnverifiedMail1)
        postOffice.register(recipient, SpecificRecipient.receiveUnverifiedMail2)
        postOffice.register(recipient, SpecificRecipient.receiveUnverifiedMail3)

        postOffice.unregister(recipient)

        postOffice.post(notification, sender: sender)

        XCTAssertEqual(recipient.count, 0)
    }

    func testUnverifiedMailQueue() throws {
        let bgQueue = DispatchQueue(label: "test.queue")
        let notification = ExampleUnverifiedMail(info: 1, other: 2)
        let sender = UnverifiedMailSender()
        let postOffice = PostOffice()

        class SpecificRecipient {
            var count = 0
            func receiveUnverifiedMail1(notification: ExampleUnverifiedMail, sender: UnverifiedMailSender) {
                count += 1
            }
            func receiveUnverifiedMail2(notification: ExampleUnverifiedMail, sender: UnverifiedMailSender?) {
                count += 1
            }
            func receiveUnverifiedMail3(notification: ExampleUnverifiedMail) {
                count += 1
            }
        }

        let exp = expectation(description: "wait for notification")
        let recipient = SpecificRecipient()

        postOffice.register(queue: bgQueue, recipient, SpecificRecipient.receiveUnverifiedMail1)
        postOffice.register(queue: bgQueue, recipient, SpecificRecipient.receiveUnverifiedMail2)
        postOffice.register(queue: bgQueue, recipient, SpecificRecipient.receiveUnverifiedMail3)

        bgQueue.sync {
            exp.fulfill()
        }

        postOffice.post(notification, sender: sender)

        wait(for: [exp], timeout: 0.1)
        XCTAssertEqual(recipient.count, 3)
    }

    func testUnverifiedMailRequiredSender() throws {
        let notification = ExampleUnverifiedMail(info: 1, other: 2)
        let sender = UnverifiedMailSender()
        let postOffice = PostOffice()

        class SpecificRecipient {
            var count = 0
            func receiveUnverifiedMail1(notification: ExampleUnverifiedMail, sender: UnverifiedMailSender) {
                count += 1
            }
            func receiveUnverifiedMail2(notification: ExampleUnverifiedMail, sender: UnverifiedMailSender?) {
                count += 1
            }
            func receiveUnverifiedMail3(notification: ExampleUnverifiedMail) {
                count += 1
            }
        }

        let recipient = SpecificRecipient()

        postOffice.register(sender: sender, recipient, SpecificRecipient.receiveUnverifiedMail1)
        postOffice.register(sender: sender, recipient, SpecificRecipient.receiveUnverifiedMail2)
        postOffice.register(sender: sender, recipient, SpecificRecipient.receiveUnverifiedMail3)

        postOffice.post(notification, sender: sender)

        XCTAssertEqual(recipient.count, 3)
    }

    func testUnverifiedMailWrongSender() throws {
        let notification = ExampleUnverifiedMail(info: 1, other: 2)
        let sender1 = UnverifiedMailSender()
        let sender2 = UnverifiedMailSender()
        let postOffice = PostOffice()

        class SpecificRecipient {
            var count = 0
            func receiveUnverifiedMail1(notification: ExampleUnverifiedMail, sender: UnverifiedMailSender) {
                count += 1
            }
            func receiveUnverifiedMail2(notification: ExampleUnverifiedMail, sender: UnverifiedMailSender?) {
                count += 1
            }
            func receiveUnverifiedMail3(notification: ExampleUnverifiedMail) {
                count += 1
            }
        }

        let recipient = SpecificRecipient()

        postOffice.register(sender: sender1, recipient, SpecificRecipient.receiveUnverifiedMail1)
        postOffice.register(sender: sender1, recipient, SpecificRecipient.receiveUnverifiedMail2)
        postOffice.register(sender: sender1, recipient, SpecificRecipient.receiveUnverifiedMail3)

        postOffice.post(notification, sender: sender2)

        XCTAssertEqual(recipient.count, 0)
    }

    func testUnverifiedMailSubSender() throws {
        class SubSender: UnverifiedMailSender { }
        let notification = ExampleUnverifiedMail(info: 1, other: 2)
        let sender = SubSender()
        let postOffice = PostOffice()

        class SpecificRecipient {
            var count = 0
            func receiveUnverifiedMail1(notification: ExampleUnverifiedMail, sender: UnverifiedMailSender) {
                count += 1
            }
            func receiveUnverifiedMail2(notification: ExampleUnverifiedMail, sender: UnverifiedMailSender?) {
                count += 1
            }
            func receiveUnverifiedMail3(notification: ExampleUnverifiedMail) {
                count += 1
            }
        }

        let recipient = SpecificRecipient()

        postOffice.register(sender: sender, recipient, SpecificRecipient.receiveUnverifiedMail1)
        postOffice.register(sender: sender, recipient, SpecificRecipient.receiveUnverifiedMail2)
        postOffice.register(sender: sender, recipient, SpecificRecipient.receiveUnverifiedMail3)

        postOffice.post(notification, sender: sender)

        XCTAssertEqual(recipient.count, 3)
    }

    func testSubUnverifiedMail() throws {
        class ClassNotification: UnverifiedMail {
        }

        class SubClassNotification: ClassNotification { }
        let notification = SubClassNotification()
        let sender = UnverifiedMailSender()
        let postOffice = PostOffice()

        class SpecificRecipient {
            var count = 0
            func receiveUnverifiedMail1(notification: ClassNotification, sender: UnverifiedMailSender) {
                count += 1
            }
            func receiveUnverifiedMail2(notification: ClassNotification, sender: UnverifiedMailSender?) {
                count += 1
            }
            func receiveUnverifiedMail3(notification: ClassNotification) {
                count += 1
            }
        }

        let recipient = SpecificRecipient()

        postOffice.register(sender: sender, recipient, SpecificRecipient.receiveUnverifiedMail1)
        postOffice.register(sender: sender, recipient, SpecificRecipient.receiveUnverifiedMail2)
        postOffice.register(sender: sender, recipient, SpecificRecipient.receiveUnverifiedMail3)

        postOffice.post(notification, sender: sender)

        XCTAssertEqual(recipient.count, 3)
    }

    func testSubUnverifiedMail2() throws {
        class ClassNotification: UnverifiedMail {
        }

        class SubClassNotification: ClassNotification { }
        let notification = ClassNotification()
        let sender = UnverifiedMailSender()
        let postOffice = PostOffice()

        class SpecificRecipient {
            var count = 0
            func receiveUnverifiedMail1(notification: SubClassNotification, sender: UnverifiedMailSender) {
                count += 1
            }
            func receiveUnverifiedMail2(notification: SubClassNotification, sender: UnverifiedMailSender?) {
                count += 1
            }
            func receiveUnverifiedMail3(notification: SubClassNotification) {
                count += 1
            }
        }

        let recipient = SpecificRecipient()

        postOffice.register(sender: sender, recipient, SpecificRecipient.receiveUnverifiedMail1)
        postOffice.register(sender: sender, recipient, SpecificRecipient.receiveUnverifiedMail2)
        postOffice.register(sender: sender, recipient, SpecificRecipient.receiveUnverifiedMail3)

        postOffice.post(notification, sender: sender)

        XCTAssertEqual(recipient.count, 0)
    }

    func testSubUnverifiedMail3() throws {
        class ClassNotification: UnverifiedMail {
        }

        class SubClassNotification: ClassNotification { }
        let sender = UnverifiedMailSender()
        let postOffice = PostOffice()

        class SpecificRecipient {
            var count = 0
            func receiveUnverifiedMail1(notification: ClassNotification, sender: UnverifiedMailSender) {
                count += 1
            }
            func receiveUnverifiedMail2(notification: ClassNotification, sender: UnverifiedMailSender?) {
                count += 1
            }
            func receiveUnverifiedMail3(notification: ClassNotification) {
                count += 1
            }
        }

        let recipient = SpecificRecipient()

        postOffice.register(recipient, SpecificRecipient.receiveUnverifiedMail1)
        postOffice.register(recipient, SpecificRecipient.receiveUnverifiedMail2)
        postOffice.register(recipient, SpecificRecipient.receiveUnverifiedMail3)

        postOffice.post(ClassNotification(), sender: sender)
        XCTAssertEqual(recipient.count, 3)
        postOffice.post(SubClassNotification(), sender: sender)
        XCTAssertEqual(recipient.count, 6)
        postOffice.post(SubClassNotification())
        XCTAssertEqual(recipient.count, 8)
    }

    func testSubUnverifiedMail4() throws {
        class ClassNotification: UnverifiedMail {
        }

        class SubClassNotification: ClassNotification { }
        let sender = UnverifiedMailSender()
        let postOffice = PostOffice()

        class SpecificRecipient {
            var count = 0
            func receiveUnverifiedMail1(notification: SubClassNotification, sender: UnverifiedMailSender) {
                count += 1
            }
            func receiveUnverifiedMail2(notification: SubClassNotification, sender: UnverifiedMailSender?) {
                count += 1
            }
            func receiveUnverifiedMail3(notification: SubClassNotification) {
                count += 1
            }
        }

        let recipient = SpecificRecipient()

        postOffice.register(recipient, SpecificRecipient.receiveUnverifiedMail1)
        postOffice.register(recipient, SpecificRecipient.receiveUnverifiedMail2)
        postOffice.register(recipient, SpecificRecipient.receiveUnverifiedMail3)

        postOffice.post(ClassNotification(), sender: sender)
        XCTAssertEqual(recipient.count, 0)
        postOffice.post(SubClassNotification(), sender: sender)
        XCTAssertEqual(recipient.count, 3)
        postOffice.post(SubClassNotification())
        XCTAssertEqual(recipient.count, 5)
    }
}
