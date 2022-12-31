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

        postOffice.register { (_: ExampleUnmarked, _: UnmarkedSender) in
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
//    func testMatchSenderTypeOptional() throws {
//        struct ExampleUnmarked: UnmarkedMail {
//            var info: Int
//        }
//        struct ExampleUnmarked: UnmarkedMail {
//            var info: Int
//        }
//
//        let sender = NSObject()
//        let postOffice = PostOffice()
//        var received = 0
//
//        postOffice.register { (_: ExampleMail) -> Void in
//            received += 1
//        }
//        postOffice.register { (_: ExampleUnmarked) -> Void in
//            received += 1
//        }
//
//        postOffice.post(ExampleUnmarked(info: 12), sender: sender)
//        postOffice.post(ExampleMail(info: 12))
//
//        // compiler error, Unmarked notifications that do not implement Mail /must/ be sent with a Sender
//        // postOffice.post(ExampleUnmarked(info: 12))
//        // postOffice.post(ExampleUnmarked(info: 12), sender: nil)
//        // let emptySender: NSObject? = nil
//        // postOffice.post(ExampleUnmarked(info: 12), sender: emptySender)
//
//        XCTAssertEqual(received, 2)
//    }
}
