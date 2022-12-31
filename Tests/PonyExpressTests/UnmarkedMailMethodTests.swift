import XCTest
@testable import PonyExpress

final class UnmarkedMailMethodTests: XCTestCase {
    func testMail() throws {
        let notification = ExampleUnmarked(info: 1, other: 2)
        let sender = UnmarkedSender()
        let postOffice = PostOffice()

        class SpecificRecipient {
            var count = 0
            func receiveUnmarked1(notification: ExampleUnmarked, sender: UnmarkedSender) {
                count += 1
            }
            func receiveUnmarked2(notification: ExampleUnmarked, sender: UnmarkedSender?) {
                count += 1
            }
            func receiveUnmarked3(notification: ExampleUnmarked) {
                count += 1
            }
        }

        let recipient = SpecificRecipient()

        postOffice.register(recipient, SpecificRecipient.receiveUnmarked1)
        postOffice.register(recipient, SpecificRecipient.receiveUnmarked2)
        postOffice.register(recipient, SpecificRecipient.receiveUnmarked3)

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
            func receiveUnmarked1(notification: ExampleUnmarked, sender: UnmarkedSender) {
                count += 1
            }
            func receiveUnmarked2(notification: ExampleUnmarked, sender: UnmarkedSender?) {
                count += 1
            }
            func receiveUnmarked3(notification: ExampleUnmarked) {
                count += 1
            }
        }

        let recipient = SpecificRecipient()

        let id1 = postOffice.register(recipient, SpecificRecipient.receiveUnmarked1)
        let id2 = postOffice.register(recipient, SpecificRecipient.receiveUnmarked2)
        let id3 = postOffice.register(recipient, SpecificRecipient.receiveUnmarked3)

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

    func testUnregisterByObjPostmarked() throws {
        let notification = ExampleUnmarked(info: 1, other: 2)
        let sender = UnmarkedSender()
        let postOffice = PostOffice()

        class SpecificRecipient {
            var count = 0
            func receiveUnmarked1(notification: ExampleUnmarked, sender: UnmarkedSender) {
                count += 1
            }
            func receiveUnmarked2(notification: ExampleUnmarked, sender: UnmarkedSender?) {
                count += 1
            }
            func receiveUnmarked3(notification: ExampleUnmarked) {
                count += 1
            }
        }

        let recipient = SpecificRecipient()

        postOffice.register(recipient, SpecificRecipient.receiveUnmarked1)
        postOffice.register(recipient, SpecificRecipient.receiveUnmarked2)
        postOffice.register(recipient, SpecificRecipient.receiveUnmarked3)

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
            func receiveUnmarked1(notification: ExampleUnmarked, sender: UnmarkedSender) {
                count += 1
            }
            func receiveUnmarked2(notification: ExampleUnmarked, sender: UnmarkedSender?) {
                count += 1
            }
            func receiveUnmarked3(notification: ExampleUnmarked) {
                count += 1
            }
        }

        let exp = expectation(description: "wait for notification")
        let recipient = SpecificRecipient()

        postOffice.register(queue: bgQueue, recipient, SpecificRecipient.receiveUnmarked1)
        postOffice.register(queue: bgQueue, recipient, SpecificRecipient.receiveUnmarked2)
        postOffice.register(queue: bgQueue, recipient, SpecificRecipient.receiveUnmarked3)

        bgQueue.sync {
            exp.fulfill()
        }

        postOffice.post(notification, sender: sender)

        wait(for: [exp], timeout: 0.1)
        XCTAssertEqual(recipient.count, 3)
    }

    func testPostmarkedRequiredSender() throws {
        let notification = ExampleUnmarked(info: 1, other: 2)
        let sender = UnmarkedSender()
        let postOffice = PostOffice()

        class SpecificRecipient {
            var count = 0
            func receiveUnmarked1(notification: ExampleUnmarked, sender: UnmarkedSender) {
                count += 1
            }
            func receiveUnmarked2(notification: ExampleUnmarked, sender: UnmarkedSender?) {
                count += 1
            }
            func receiveUnmarked3(notification: ExampleUnmarked) {
                count += 1
            }
        }

        let recipient = SpecificRecipient()

        postOffice.register(sender: sender, recipient, SpecificRecipient.receiveUnmarked1)
        postOffice.register(sender: sender, recipient, SpecificRecipient.receiveUnmarked2)
        postOffice.register(sender: sender, recipient, SpecificRecipient.receiveUnmarked3)

        postOffice.post(notification, sender: sender)

        XCTAssertEqual(recipient.count, 3)
    }

    func testPostmarkedWrongSender() throws {
        let notification = ExampleUnmarked(info: 1, other: 2)
        let sender1 = UnmarkedSender()
        let sender2 = UnmarkedSender()
        let postOffice = PostOffice()

        class SpecificRecipient {
            var count = 0
            func receiveUnmarked1(notification: ExampleUnmarked, sender: UnmarkedSender) {
                count += 1
            }
            func receiveUnmarked2(notification: ExampleUnmarked, sender: UnmarkedSender?) {
                count += 1
            }
            func receiveUnmarked3(notification: ExampleUnmarked) {
                count += 1
            }
        }

        let recipient = SpecificRecipient()

        postOffice.register(sender: sender1, recipient, SpecificRecipient.receiveUnmarked1)
        postOffice.register(sender: sender1, recipient, SpecificRecipient.receiveUnmarked2)
        postOffice.register(sender: sender1, recipient, SpecificRecipient.receiveUnmarked3)

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
            func receiveUnmarked1(notification: ExampleUnmarked, sender: UnmarkedSender) {
                count += 1
            }
            func receiveUnmarked2(notification: ExampleUnmarked, sender: UnmarkedSender?) {
                count += 1
            }
            func receiveUnmarked3(notification: ExampleUnmarked) {
                count += 1
            }
        }

        let recipient = SpecificRecipient()

        postOffice.register(sender: sender, recipient, SpecificRecipient.receiveUnmarked1)
        postOffice.register(sender: sender, recipient, SpecificRecipient.receiveUnmarked2)
        postOffice.register(sender: sender, recipient, SpecificRecipient.receiveUnmarked3)

        postOffice.post(notification, sender: sender)

        XCTAssertEqual(recipient.count, 3)
    }

    func testSubPostmarked() throws {
        class ClassNotification: UnmarkedMail {
            typealias RequiredSender = UnmarkedSender
        }

        class SubClassNotification: ClassNotification { }
        let notification = SubClassNotification()
        let sender = UnmarkedSender()
        let postOffice = PostOffice()

        class SpecificRecipient {
            var count = 0
            func receiveUnmarked1(notification: ClassNotification, sender: UnmarkedSender) {
                count += 1
            }
            func receiveUnmarked2(notification: ClassNotification, sender: UnmarkedSender?) {
                count += 1
            }
            func receiveUnmarked3(notification: ClassNotification) {
                count += 1
            }
        }

        let recipient = SpecificRecipient()

        postOffice.register(sender: sender, recipient, SpecificRecipient.receiveUnmarked1)
        postOffice.register(sender: sender, recipient, SpecificRecipient.receiveUnmarked2)
        postOffice.register(sender: sender, recipient, SpecificRecipient.receiveUnmarked3)

        postOffice.post(notification, sender: sender)

        XCTAssertEqual(recipient.count, 3)
    }

    func testSubPostmarked2() throws {
        class ClassNotification: UnmarkedMail {
            typealias RequiredSender = UnmarkedSender
        }

        class SubClassNotification: ClassNotification { }
        let notification = ClassNotification()
        let sender = UnmarkedSender()
        let postOffice = PostOffice()

        class SpecificRecipient {
            var count = 0
            func receiveUnmarked1(notification: SubClassNotification, sender: UnmarkedSender) {
                count += 1
            }
            func receiveUnmarked2(notification: SubClassNotification, sender: UnmarkedSender?) {
                count += 1
            }
            func receiveUnmarked3(notification: SubClassNotification) {
                count += 1
            }
        }

        let recipient = SpecificRecipient()

        postOffice.register(sender: sender, recipient, SpecificRecipient.receiveUnmarked1)
        postOffice.register(sender: sender, recipient, SpecificRecipient.receiveUnmarked2)
        postOffice.register(sender: sender, recipient, SpecificRecipient.receiveUnmarked3)

        postOffice.post(notification, sender: sender)

        XCTAssertEqual(recipient.count, 0)
    }

    func testSubPostmarked3() throws {
        class ClassNotification: UnmarkedMail {
            typealias RequiredSender = UnmarkedSender
        }

        class SubClassNotification: ClassNotification { }
        let sender = UnmarkedSender()
        let postOffice = PostOffice()

        class SpecificRecipient {
            var count = 0
            func receiveUnmarked1(notification: ClassNotification, sender: UnmarkedSender) {
                count += 1
            }
            func receiveUnmarked2(notification: ClassNotification, sender: UnmarkedSender?) {
                count += 1
            }
            func receiveUnmarked3(notification: ClassNotification) {
                count += 1
            }
        }

        let recipient = SpecificRecipient()

        postOffice.register(recipient, SpecificRecipient.receiveUnmarked1)
        postOffice.register(recipient, SpecificRecipient.receiveUnmarked2)
        postOffice.register(recipient, SpecificRecipient.receiveUnmarked3)

        postOffice.post(ClassNotification(), sender: sender)
        XCTAssertEqual(recipient.count, 3)
        postOffice.post(SubClassNotification(), sender: sender)
        XCTAssertEqual(recipient.count, 6)
        postOffice.post(SubClassNotification())
        XCTAssertEqual(recipient.count, 8)
    }
}
