import XCTest
@testable import PonyExpress

final class PostMarkedMethodTests: XCTestCase {
    func testPostmarked() throws {
        let notification = ExamplePostmarked(info: 1, other: 2)
        let sender = PostmarkedSender()
        let postOffice = PostOffice()

        class SpecificRecipient {
            var count = 0
            func receivePostmarked1(notification: ExamplePostmarked, sender: PostmarkedSender) {
                count += 1
            }
            func receivePostmarked2(notification: ExamplePostmarked) {
                count += 1
            }
        }

        let recipient = SpecificRecipient()

        postOffice.register(recipient, SpecificRecipient.receivePostmarked1)
        postOffice.register(recipient, SpecificRecipient.receivePostmarked2)

        postOffice.post(notification, sender: sender)
        // hit the method with and without a sender
        XCTAssertEqual(recipient.count, 2)
        // hit all methods
        postOffice.post(notification, sender: sender)
        XCTAssertEqual(recipient.count, 4)
    }

    func testUnregisterByIdPostmarked() throws {
        let notification = ExamplePostmarked(info: 1, other: 2)
        let sender = PostmarkedSender()
        let postOffice = PostOffice()

        class SpecificRecipient {
            var count = 0
            func receivePostmarked1(notification: ExamplePostmarked, sender: PostmarkedSender) {
                count += 1
            }
            func receivePostmarked3(notification: ExamplePostmarked) {
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
        let notification = ExamplePostmarked(info: 1, other: 2)
        let sender = PostmarkedSender()
        let postOffice = PostOffice()

        class SpecificRecipient {
            var count = 0
            func receivePostmarked1(notification: ExamplePostmarked, sender: PostmarkedSender) {
                count += 1
            }
            func receivePostmarked3(notification: ExamplePostmarked) {
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
        let notification = ExamplePostmarked(info: 1, other: 2)
        let sender = PostmarkedSender()
        let postOffice = PostOffice()

        class SpecificRecipient {
            var count = 0
            func receivePostmarked1(notification: ExamplePostmarked, sender: PostmarkedSender) {
                count += 1
            }
            func receivePostmarked3(notification: ExamplePostmarked) {
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
        let notification = ExamplePostmarked(info: 1, other: 2)
        let sender = PostmarkedSender()
        let postOffice = PostOffice()

        class SpecificRecipient {
            var count = 0
            func receivePostmarked1(notification: ExamplePostmarked, sender: PostmarkedSender) {
                count += 1
            }
            func receivePostmarked3(notification: ExamplePostmarked) {
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
        let notification = ExamplePostmarked(info: 1, other: 2)
        let sender1 = PostmarkedSender()
        let sender2 = PostmarkedSender()
        let postOffice = PostOffice()

        class SpecificRecipient {
            var count = 0
            func receivePostmarked1(notification: ExamplePostmarked, sender: PostmarkedSender) {
                count += 1
            }
            func receivePostmarked3(notification: ExamplePostmarked) {
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
        class SubSender: PostmarkedSender { }
        let notification = ExamplePostmarked(info: 1, other: 2)
        let sender = SubSender()
        let postOffice = PostOffice()

        class SpecificRecipient {
            var count = 0
            func receivePostmarked1(notification: ExamplePostmarked, sender: PostmarkedSender) {
                count += 1
            }
            func receivePostmarked3(notification: ExamplePostmarked) {
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
            typealias RequiredSender = PostmarkedSender
        }

        class SubClassNotification: ClassNotification { }
        let notification = SubClassNotification()
        let sender = PostmarkedSender()
        let postOffice = PostOffice()

        class SpecificRecipient {
            var count = 0
            func receivePostmarked1(notification: ClassNotification, sender: PostmarkedSender) {
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
            typealias RequiredSender = PostmarkedSender
        }

        class SubClassNotification: ClassNotification { }
        let notification = ClassNotification()
        let sender = PostmarkedSender()
        let postOffice = PostOffice()

        class SpecificRecipient {
            var count = 0
            func receivePostmarked1(notification: SubClassNotification, sender: PostmarkedSender) {
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

    func testRegisteredCount() throws {
        let postOffice = PostOffice()

        class SpecificRecipient {
            var count = 0
            func receivePostmarked1(notification: ExamplePostmarked, sender: PostmarkedSender) {
                count += 1
            }
            func receivePostmarked2(notification: ExamplePostmarked) {
                count += 1
            }
        }

        let recipient = SpecificRecipient()

        postOffice.register(recipient, SpecificRecipient.receivePostmarked1)
        XCTAssertEqual(postOffice.count, 1)
        postOffice.register(recipient, SpecificRecipient.receivePostmarked2)
        XCTAssertEqual(postOffice.count, 2)
        postOffice.unregister(recipient)
        XCTAssertEqual(postOffice.count, 0)
    }
}
