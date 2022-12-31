import XCTest
@testable import PonyExpress

final class UnmarkedMailBlockTests: XCTestCase {

    func testUnmarkedRequiredSenderBlock() throws {
        let notification = ExampleUnmarked(info: 1, other: 2)
        let sender1 = UnmarkedSender()
        let sender2 = UnmarkedSender()
        let postOffice = PostOffice()
        var count = 0

        postOffice.register { (_: ExampleUnmarked, _: UnmarkedSender) in
            count += 1
        }

        postOffice.post(notification, sender: sender1)
        postOffice.post(notification, sender: sender2)

        XCTAssertEqual(count, 2)
    }

    func testUnmarkedOptionalSenderBlock() throws {
        let notification = ExampleUnmarked(info: 1, other: 2)
        let sender1 = UnmarkedSender()
        let sender2 = UnmarkedSender()
        let postOffice = PostOffice()
        var count = 0

        postOffice.register { (_: ExampleUnmarked, _: UnmarkedSender?) in
            count += 1
        }

        postOffice.post(notification, sender: sender1)
        postOffice.post(notification, sender: sender2)

        XCTAssertEqual(count, 2)
    }

    func testUnmarkedSpecificSenderBlock() throws {
        let notification = ExampleUnmarked(info: 1, other: 2)
        let sender1 = UnmarkedSender()
        let sender2 = UnmarkedSender()
        let postOffice = PostOffice()
        var count = 0

        postOffice.register(sender: sender1) { (_: ExampleUnmarked, _: UnmarkedSender) in
            count += 1
        }

        postOffice.post(notification, sender: sender1)
        postOffice.post(notification, sender: sender2)

        XCTAssertEqual(count, 1)
    }

    func testUnmarkedSpecificQueueBlock() throws {
        let bgQueue = DispatchQueue(label: "test.queue")
        let notification = ExampleUnmarked(info: 1, other: 2)
        let sender1 = UnmarkedSender()
        let postOffice = PostOffice()
        var count = 0

        postOffice.register(queue: bgQueue) { (_: ExampleUnmarked, _: UnmarkedSender) in
            count += 1
        }

        postOffice.post(notification, sender: sender1)

        let exp = expectation(description: "wait for notification")

        bgQueue.sync {
            exp.fulfill()
        }

        wait(for: [exp], timeout: 0.1)

        XCTAssertEqual(count, 1)
    }

    func testUnmarkedIgnoredSender() throws {
        let notification = ExampleUnmarked(info: 1, other: 2)
        let sender1 = UnmarkedSender()
        let postOffice = PostOffice()
        var count = 0

        postOffice.register { (_: ExampleUnmarked) in
            count += 1
        }

        postOffice.post(notification, sender: sender1)

        XCTAssertEqual(count, 1)
    }

    func testUnmarkedIgnoredSender2() throws {
        let notification = ExampleUnmarked(info: 1, other: 2)
        let sender1 = UnmarkedSender()
        let postOffice = PostOffice()
        var count = 0

        postOffice.register(sender: sender1) { (_: ExampleUnmarked) in
            count += 1
        }

        postOffice.post(notification, sender: sender1)

        XCTAssertEqual(count, 1)
    }

    func testSubUnmarked() throws {
        class ClassNotification: UnmarkedMail {
            typealias RequiredSender = UnmarkedSender
        }

        class SubClassNotification: ClassNotification { }
        let notification = SubClassNotification()
        let sender = UnmarkedSender()
        let postOffice = PostOffice()

        var count = 0

        postOffice.register(sender: sender) { (_: ClassNotification, _: UnmarkedSender) in
            count += 1
        }
        postOffice.register(sender: sender) { (_: ClassNotification, _: UnmarkedSender?) in
            count += 1
        }
        postOffice.register(sender: sender) { (_: ClassNotification) in
            count += 1
        }

        postOffice.post(notification, sender: sender)

        XCTAssertEqual(count, 3)
    }

    func testSubUnmarked2() throws {
        class ClassNotification: UnmarkedMail {
            typealias RequiredSender = UnmarkedSender
        }

        class SubClassNotification: ClassNotification { }
        let notification = ClassNotification()
        let sender = UnmarkedSender()
        let postOffice = PostOffice()

        var count = 0

        postOffice.register(sender: sender) { (_: SubClassNotification, _: UnmarkedSender) in
            count += 1
        }
        postOffice.register(sender: sender) { (_: SubClassNotification, _: UnmarkedSender?) in
            count += 1
        }
        postOffice.register(sender: sender) { (_: SubClassNotification) in
            count += 1
        }

        postOffice.post(notification, sender: sender)

        XCTAssertEqual(count, 0)
    }

    func testSubUnmarked3() throws {
        class ClassNotification: UnmarkedMail {
            typealias RequiredSender = UnmarkedSender
        }

        class SubClassNotification: ClassNotification { }
        let sender = UnmarkedSender()
        let postOffice = PostOffice()

        var count = 0

        postOffice.register { (_: ClassNotification, _: UnmarkedSender) in
            count += 1
        }
        postOffice.register { (_: ClassNotification, _: UnmarkedSender?) in
            count += 1
        }
        postOffice.register { (_: ClassNotification) in
            count += 1
        }

        postOffice.post(ClassNotification(), sender: sender)
        XCTAssertEqual(count, 3)
        postOffice.post(SubClassNotification(), sender: sender)
        XCTAssertEqual(count, 6)
        postOffice.post(SubClassNotification())
        XCTAssertEqual(count, 8)
    }

    func testSubUnmarked4() throws {
        class ClassNotification: UnmarkedMail {
            typealias RequiredSender = UnmarkedSender
        }

        class SubClassNotification: ClassNotification { }
        let sender = UnmarkedSender()
        let postOffice = PostOffice()

        var count = 0

        postOffice.register { (_: SubClassNotification, _: UnmarkedSender) in
            count += 1
        }
        postOffice.register { (_: SubClassNotification, _: UnmarkedSender?) in
            count += 1
        }
        postOffice.register { (_: SubClassNotification) in
            count += 1
        }

        postOffice.post(ClassNotification(), sender: sender)
        XCTAssertEqual(count, 0)
        postOffice.post(SubClassNotification(), sender: sender)
        XCTAssertEqual(count, 3)
        postOffice.post(SubClassNotification())
        XCTAssertEqual(count, 5)
    }
}
