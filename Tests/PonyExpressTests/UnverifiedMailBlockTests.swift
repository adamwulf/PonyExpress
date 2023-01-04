import XCTest
@testable import PonyExpress

final class UnverifiedMailMailBlockTests: XCTestCase {

    func testUnverifiedMailRequiredSenderBlock() throws {
        let notification = ExampleUnverifiedMail(info: 1, other: 2)
        let sender1 = UnverifiedMailSender()
        let sender2 = UnverifiedMailSender()
        let postOffice = PostOffice()
        var count = 0

        postOffice.register { (_: ExampleUnverifiedMail, _: UnverifiedMailSender) in
            count += 1
        }

        postOffice.post(notification, sender: sender1)
        postOffice.post(notification, sender: sender2)

        XCTAssertEqual(count, 2)
    }

    func testUnverifiedMailOptionalSenderBlock() throws {
        let notification = ExampleUnverifiedMail(info: 1, other: 2)
        let sender1 = UnverifiedMailSender()
        let sender2 = UnverifiedMailSender()
        let postOffice = PostOffice()
        var count = 0

        postOffice.register { (_: ExampleUnverifiedMail, _: UnverifiedMailSender?) in
            count += 1
        }

        postOffice.post(notification, sender: sender1)
        postOffice.post(notification, sender: sender2)

        XCTAssertEqual(count, 2)
    }

    func testUnverifiedMailSpecificSenderBlock() throws {
        let notification = ExampleUnverifiedMail(info: 1, other: 2)
        let sender1 = UnverifiedMailSender()
        let sender2 = UnverifiedMailSender()
        let postOffice = PostOffice()
        var count = 0

        postOffice.register(sender: sender1) { (_: ExampleUnverifiedMail, _: UnverifiedMailSender) in
            count += 1
        }

        postOffice.post(notification, sender: sender1)
        postOffice.post(notification, sender: sender2)

        XCTAssertEqual(count, 1)
    }

    func testUnverifiedMailSpecificQueueBlock() throws {
        let bgQueue = DispatchQueue(label: "test.queue")
        let notification = ExampleUnverifiedMail(info: 1, other: 2)
        let sender1 = UnverifiedMailSender()
        let postOffice = PostOffice()
        var count = 0

        postOffice.register(queue: bgQueue) { (_: ExampleUnverifiedMail, _: UnverifiedMailSender) in
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

    func testUnverifiedMailIgnoredSender() throws {
        let notification = ExampleUnverifiedMail(info: 1, other: 2)
        let sender1 = UnverifiedMailSender()
        let postOffice = PostOffice()
        var count = 0

        postOffice.register { (_: ExampleUnverifiedMail) in
            count += 1
        }

        postOffice.post(notification, sender: sender1)

        XCTAssertEqual(count, 1)
    }

    func testUnverifiedMailIgnoredSender2() throws {
        let notification = ExampleUnverifiedMail(info: 1, other: 2)
        let sender1 = UnverifiedMailSender()
        let postOffice = PostOffice()
        var count = 0

        postOffice.register(sender: sender1) { (_: ExampleUnverifiedMail) in
            count += 1
        }

        postOffice.post(notification, sender: sender1)

        XCTAssertEqual(count, 1)
    }

    func testSubUnverifiedMail() throws {
        class ClassNotification: UnverifiedMail {
            typealias RequiredSender = UnverifiedMailSender
        }

        class SubClassNotification: ClassNotification { }
        let notification = SubClassNotification()
        let sender = UnverifiedMailSender()
        let postOffice = PostOffice()

        var count = 0

        postOffice.register(sender: sender) { (_: ClassNotification, _: UnverifiedMailSender) in
            count += 1
        }
        postOffice.register(sender: sender) { (_: ClassNotification, _: UnverifiedMailSender?) in
            count += 1
        }
        postOffice.register(sender: sender) { (_: ClassNotification) in
            count += 1
        }

        postOffice.post(notification, sender: sender)

        XCTAssertEqual(count, 3)
    }

    func testSubUnverifiedMail2() throws {
        class ClassNotification: UnverifiedMail {
            typealias RequiredSender = UnverifiedMailSender
        }

        class SubClassNotification: ClassNotification { }
        let notification = ClassNotification()
        let sender = UnverifiedMailSender()
        let postOffice = PostOffice()

        var count = 0

        postOffice.register(sender: sender) { (_: SubClassNotification, _: UnverifiedMailSender) in
            count += 1
        }
        postOffice.register(sender: sender) { (_: SubClassNotification, _: UnverifiedMailSender?) in
            count += 1
        }
        postOffice.register(sender: sender) { (_: SubClassNotification) in
            count += 1
        }

        postOffice.post(notification, sender: sender)

        XCTAssertEqual(count, 0)
    }

    func testSubUnverifiedMail3() throws {
        class ClassNotification: UnverifiedMail {
            typealias RequiredSender = UnverifiedMailSender
        }

        class SubClassNotification: ClassNotification { }
        let sender = UnverifiedMailSender()
        let postOffice = PostOffice()

        var count = 0

        postOffice.register { (_: ClassNotification, _: UnverifiedMailSender) in
            count += 1
        }
        postOffice.register { (_: ClassNotification, _: UnverifiedMailSender?) in
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

    func testSubUnverifiedMail4() throws {
        class ClassNotification: UnverifiedMail {
            typealias RequiredSender = UnverifiedMailSender
        }

        class SubClassNotification: ClassNotification { }
        let sender = UnverifiedMailSender()
        let postOffice = PostOffice()

        var count = 0

        postOffice.register { (_: SubClassNotification, _: UnverifiedMailSender) in
            count += 1
        }
        postOffice.register { (_: SubClassNotification, _: UnverifiedMailSender?) in
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
