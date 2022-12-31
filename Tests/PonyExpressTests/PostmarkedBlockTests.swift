import XCTest
@testable import PonyExpress

final class PostMarkedBlockTests: XCTestCase {

    func testPostmarkedRequiredSenderBlock() throws {
        let notification = ExamplePostmarked(info: 1, other: 2)
        let sender1 = PostmarkedSender()
        let sender2 = PostmarkedSender()
        let postOffice = PostOffice()
        var count = 0

        postOffice.register { (_: ExamplePostmarked, _: PostmarkedSender) in
            count += 1
        }

        postOffice.post(notification, sender: sender1)
        postOffice.post(notification, sender: sender2)

        XCTAssertEqual(count, 2)
    }

    func testPostmarkedOptionalSenderBlock() throws {
        let notification = ExamplePostmarked(info: 1, other: 2)
        let sender1 = PostmarkedSender()
        let sender2 = PostmarkedSender()
        let postOffice = PostOffice()
        var count = 0

        postOffice.register { (_: ExamplePostmarked, _: PostmarkedSender) in
            count += 1
        }

        postOffice.post(notification, sender: sender1)
        postOffice.post(notification, sender: sender2)

        XCTAssertEqual(count, 2)
    }

    func testPostmarkedSpecificSenderBlock() throws {
        let notification = ExamplePostmarked(info: 1, other: 2)
        let sender1 = PostmarkedSender()
        let sender2 = PostmarkedSender()
        let postOffice = PostOffice()
        var count = 0

        postOffice.register(sender: sender1) { (_: ExamplePostmarked, _: PostmarkedSender) in
            count += 1
        }

        postOffice.post(notification, sender: sender1)
        postOffice.post(notification, sender: sender2)

        XCTAssertEqual(count, 1)
    }

    func testPostmarkedSpecificQueueBlock() throws {
        let bgQueue = DispatchQueue(label: "test.queue")
        let notification = ExamplePostmarked(info: 1, other: 2)
        let sender1 = PostmarkedSender()
        let postOffice = PostOffice()
        var count = 0

        postOffice.register(queue: bgQueue) { (_: ExamplePostmarked, _: PostmarkedSender) in
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

    func testPostmarkedIgnoredSender() throws {
        let notification = ExamplePostmarked(info: 1, other: 2)
        let sender1 = PostmarkedSender()
        let postOffice = PostOffice()
        var count = 0

        postOffice.register { (_: ExamplePostmarked) in
            count += 1
        }

        postOffice.post(notification, sender: sender1)

        XCTAssertEqual(count, 1)
    }

    func testPostmarkedIgnoredSender2() throws {
        let notification = ExamplePostmarked(info: 1, other: 2)
        let sender1 = PostmarkedSender()
        let postOffice = PostOffice()
        var count = 0

        postOffice.register(sender: sender1) { (_: ExamplePostmarked) in
            count += 1
        }

        postOffice.post(notification, sender: sender1)

        XCTAssertEqual(count, 1)
    }
}
