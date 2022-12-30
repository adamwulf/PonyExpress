import XCTest
@testable import PonyExpress

final class MailMethodTests: XCTestCase {
    func testMail() throws {
        let notification = ExampleUnmarked(info: 1, other: 2)
        let sender = UnmarkedSender()
        let postOffice = PostOffice()

        class SpecificRecipient {
            var count = 0
            func receivePostmarked1(notification: ExampleUnmarked, sender: UnmarkedSender) {
                count += 1
            }
            func receivePostmarked2(notification: ExampleUnmarked, sender: UnmarkedSender?) {
                count += 1
            }
            func receivePostmarked3(notification: ExampleUnmarked) {
                count += 1
            }
        }

        let recipient = SpecificRecipient()

        postOffice.register(recipient, SpecificRecipient.receivePostmarked1)
        postOffice.register(recipient, SpecificRecipient.receivePostmarked2)
        postOffice.register(recipient, SpecificRecipient.receivePostmarked3)

        postOffice.post(notification)
        // hit the method w/o a sender and with a nullable sender, miss the method with required sender
        XCTAssertEqual(recipient.count, 2)
        // hit all three methods
        postOffice.post(notification, sender: sender)
        XCTAssertEqual(recipient.count, 5)
    }

    func testUnregisterByIdUnmarked() throws {
        let notification = ExampleUnmarked(info: 1, other: 2)
        let sender = UnmarkedSender()
        let postOffice = PostOffice()

        class SpecificRecipient {
            var count = 0
            func receivePostmarked1(notification: ExampleUnmarked, sender: UnmarkedSender) {
                count += 1
            }
            func receivePostmarked3(notification: ExampleUnmarked) {
                count += 1
            }
        }

        let recipient = SpecificRecipient()

        let id1 = postOffice.register(recipient, SpecificRecipient.receivePostmarked1)
        let id2 = postOffice.register(recipient, SpecificRecipient.receivePostmarked3)

        postOffice.post(notification, sender: sender)

        XCTAssertEqual(recipient.count, 2)

        postOffice.unregister(id1)
        postOffice.post(notification, sender: sender)

        XCTAssertEqual(recipient.count, 3)

        postOffice.unregister(id2)
        postOffice.post(notification, sender: sender)

        XCTAssertEqual(recipient.count, 3)
    }

    func testUnregisterByObjPostmarked() throws {
        let notification = ExampleUnmarked(info: 1, other: 2)
        let sender = UnmarkedSender()
        let postOffice = PostOffice()

        class SpecificRecipient {
            var count = 0
            func receivePostmarked1(notification: ExampleUnmarked, sender: UnmarkedSender) {
                count += 1
            }
            func receivePostmarked3(notification: ExampleUnmarked) {
                count += 1
            }
        }

        let recipient = SpecificRecipient()

        postOffice.register(recipient, SpecificRecipient.receivePostmarked1)
        postOffice.register(recipient, SpecificRecipient.receivePostmarked3)

        postOffice.unregister(recipient)

        postOffice.post(notification, sender: sender)

        XCTAssertEqual(recipient.count, 0)
    }

    func testPostmarkedQueue() throws {
        let bgQueue = DispatchQueue(label: "test.queue")
        let notification = ExampleUnmarked(info: 1, other: 2)
        let sender = UnmarkedSender()
        let postOffice = PostOffice()

        class SpecificRecipient {
            var count = 0
            func receivePostmarked1(notification: ExampleUnmarked, sender: UnmarkedSender) {
                count += 1
            }
            func receivePostmarked3(notification: ExampleUnmarked) {
                count += 1
            }
        }

        let exp = expectation(description: "wait for notification")
        let recipient = SpecificRecipient()

        postOffice.register(queue: bgQueue, recipient, SpecificRecipient.receivePostmarked1)
        postOffice.register(queue: bgQueue, recipient, SpecificRecipient.receivePostmarked3)

        bgQueue.sync {
            exp.fulfill()
        }

        postOffice.post(notification, sender: sender)

        wait(for: [exp], timeout: 0.1)
        XCTAssertEqual(recipient.count, 2)
    }

    func testPostmarkedRequiredSender() throws {
        let notification = ExampleUnmarked(info: 1, other: 2)
        let sender = UnmarkedSender()
        let postOffice = PostOffice()

        class SpecificRecipient {
            var count = 0
            func receivePostmarked1(notification: ExampleUnmarked, sender: UnmarkedSender) {
                count += 1
            }
            func receivePostmarked3(notification: ExampleUnmarked) {
                count += 1
            }
        }

        let recipient = SpecificRecipient()

        postOffice.register(sender: sender, recipient, SpecificRecipient.receivePostmarked1)
        postOffice.register(sender: sender, recipient, SpecificRecipient.receivePostmarked3)

        postOffice.post(notification, sender: sender)

        XCTAssertEqual(recipient.count, 2)
    }

    func testPostmarkedWrongSender() throws {
        let notification = ExampleUnmarked(info: 1, other: 2)
        let sender1 = UnmarkedSender()
        let sender2 = UnmarkedSender()
        let postOffice = PostOffice()

        class SpecificRecipient {
            var count = 0
            func receivePostmarked1(notification: ExampleUnmarked, sender: UnmarkedSender) {
                count += 1
            }
            func receivePostmarked3(notification: ExampleUnmarked) {
                count += 1
            }
        }

        let recipient = SpecificRecipient()

        postOffice.register(sender: sender1, recipient, SpecificRecipient.receivePostmarked1)
        postOffice.register(sender: sender1, recipient, SpecificRecipient.receivePostmarked3)

        postOffice.post(notification, sender: sender2)

        XCTAssertEqual(recipient.count, 0)
    }

    func testPostmarkedSubSender() throws {
        class SubSender: UnmarkedSender { }
        let notification = ExampleUnmarked(info: 1, other: 2)
        let sender = SubSender()
        let postOffice = PostOffice()

        class SpecificRecipient {
            var count = 0
            func receivePostmarked1(notification: ExampleUnmarked, sender: UnmarkedSender) {
                count += 1
            }
            func receivePostmarked3(notification: ExampleUnmarked) {
                count += 1
            }
        }

        let recipient = SpecificRecipient()

        postOffice.register(sender: sender, recipient, SpecificRecipient.receivePostmarked1)
        postOffice.register(sender: sender, recipient, SpecificRecipient.receivePostmarked3)

        postOffice.post(notification, sender: sender)

        XCTAssertEqual(recipient.count, 2)
    }

    func testSubPostmarked() throws {
        class ClassNotification: PostmarkedMail {
            typealias RequiredSender = UnmarkedSender
        }

        class SubClassNotification: ClassNotification { }
        let notification = SubClassNotification()
        let sender = UnmarkedSender()
        let postOffice = PostOffice()

        class SpecificRecipient {
            var count = 0
            func receivePostmarked1(notification: ClassNotification, sender: UnmarkedSender) {
                count += 1
            }
            func receivePostmarked3(notification: ClassNotification) {
                count += 1
            }
        }

        let recipient = SpecificRecipient()

        postOffice.register(sender: sender, recipient, SpecificRecipient.receivePostmarked1)
        postOffice.register(sender: sender, recipient, SpecificRecipient.receivePostmarked3)

        postOffice.post(notification, sender: sender)

        XCTAssertEqual(recipient.count, 2)
    }

    func testSubPostmarked2() throws {
        class ClassNotification: PostmarkedMail {
            typealias RequiredSender = UnmarkedSender
        }

        class SubClassNotification: ClassNotification { }
        let notification = ClassNotification()
        let sender = UnmarkedSender()
        let postOffice = PostOffice()

        class SpecificRecipient {
            var count = 0
            func receivePostmarked1(notification: SubClassNotification, sender: UnmarkedSender) {
                count += 1
            }
            func receivePostmarked3(notification: SubClassNotification) {
                count += 1
            }
        }

        let recipient = SpecificRecipient()

        postOffice.register(sender: sender, recipient, SpecificRecipient.receivePostmarked1)
        postOffice.register(sender: sender, recipient, SpecificRecipient.receivePostmarked3)

        postOffice.post(notification, sender: sender)

        XCTAssertEqual(recipient.count, 0)
    }
}
