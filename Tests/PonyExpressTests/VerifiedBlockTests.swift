import XCTest
@testable import PonyExpress

final class VerifiedBlockTests: XCTestCase {

    func testVerifiedMailRequiredSenderBlock() throws {
        let notification = ExampleVerifiedMail(info: 1, other: 2)
        let sender1 = VerifiedMailSender()
        let sender2 = VerifiedMailSender()
        let postOffice = PostOffice()
        var count = 0

        postOffice.register { (_: ExampleVerifiedMail, _: VerifiedMailSender) in
            count += 1
        }

        postOffice.post(notification, sender: sender1)
        postOffice.post(notification, sender: sender2)

        XCTAssertEqual(count, 2)
    }

    func testVerifiedMailSpecificSenderBlock() throws {
        let notification = ExampleVerifiedMail(info: 1, other: 2)
        let sender1 = VerifiedMailSender()
        let sender2 = VerifiedMailSender()
        let postOffice = PostOffice()
        var count = 0

        postOffice.register(sender: sender1) { (_: ExampleVerifiedMail, _: VerifiedMailSender) in
            count += 1
        }

        postOffice.post(notification, sender: sender1)
        postOffice.post(notification, sender: sender2)

        XCTAssertEqual(count, 1)
    }

    func testVerifiedMailSpecificQueueBlock() throws {
        let bgQueue = DispatchQueue(label: "test.queue")
        let notification = ExampleVerifiedMail(info: 1, other: 2)
        let sender1 = VerifiedMailSender()
        let postOffice = PostOffice()
        var count = 0

        postOffice.register(queue: bgQueue) { (_: ExampleVerifiedMail, _: VerifiedMailSender) in
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

    func testVerifiedMailIgnoredSender() throws {
        let notification = ExampleVerifiedMail(info: 1, other: 2)
        let sender1 = VerifiedMailSender()
        let postOffice = PostOffice()
        var count = 0

        postOffice.register { (_: ExampleVerifiedMail) in
            count += 1
        }

        postOffice.post(notification, sender: sender1)

        XCTAssertEqual(count, 1)
    }

    func testVerifiedMailIgnoredSender2() throws {
        let notification = ExampleVerifiedMail(info: 1, other: 2)
        let sender1 = VerifiedMailSender()
        let postOffice = PostOffice()
        var count = 0

        postOffice.register(sender: sender1) { (_: ExampleVerifiedMail) in
            count += 1
        }

        postOffice.post(notification, sender: sender1)

        XCTAssertEqual(count, 1)
    }
}
