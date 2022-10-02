import XCTest
@testable import PonyExpress

final class PonyExpressTests: XCTestCase {
    func testSimple() throws {
        let ponyExpress = PostOffice()
        var received = 0

        ponyExpress.register({ (_: ExampleNotification) -> Void in
            received += 1
        })

        ponyExpress.post(ExampleNotification(info: 12, other: 15))
        XCTAssertEqual(received, 1)
    }

    func testIgnoreSender() throws {
        let sender = NSObject()
        let ponyExpress = PostOffice()
        var received = 0

        ponyExpress.register({ (_: ExampleNotification) -> Void in
            received += 1
        })

        ponyExpress.post(ExampleNotification(info: 12, other: 15), sender: sender)
        XCTAssertEqual(received, 1)
    }

    func testMatchSender() throws {
        let sender = NSObject()
        let ponyExpress = PostOffice()
        var received = 0

        ponyExpress.register(sender: sender, { (_: ExampleNotification) -> Void in
            received += 1
        })

        ponyExpress.post(ExampleNotification(info: 12, other: 15), sender: sender)
        XCTAssertEqual(received, 1)
    }

    func testFailedMatchSender() throws {
        let sender = NSObject()
        let other = NSObject()
        let ponyExpress = PostOffice()
        var received = 0

        ponyExpress.register(sender: sender, { (_: ExampleNotification) -> Void in
            received += 1
        })

        ponyExpress.post(ExampleNotification(info: 12, other: 15), sender: other)
        XCTAssertEqual(received, 0)
    }

    func testAsync() throws {
        let ponyExpress = PostOffice()
        let queue = DispatchQueue(label: "any.queue")
        var received = 0

        ponyExpress.register(queue: queue, { (_: ExampleNotification) -> Void in
            received += 1
        })

        XCTAssertEqual(received, 0)

        ponyExpress.post(ExampleNotification(info: 12, other: 15))

        let exp = expectation(description: "wait for notification")
        queue.async {
            exp.fulfill()
        }
        wait(for: [exp], timeout: 0.1)

        XCTAssertEqual(received, 1)
    }

    func testRegisterFunction() throws {
        let ponyExpress = PostOffice()
        let queue = DispatchQueue(label: "any.queue")
        var received = 0

        func listener(_ letter: ExampleNotification) {
            received += 1
        }

        ponyExpress.register(queue: queue, listener(_:))

        XCTAssertEqual(received, 0)

        ponyExpress.post(ExampleNotification(info: 12, other: 15))

        let exp = expectation(description: "wait for notification")
        queue.async {
            exp.fulfill()
        }
        wait(for: [exp], timeout: 0.1)

        XCTAssertEqual(received, 1)
    }

    func testSender() throws {
        let sender = NSObject()
        let other = NSObject()
        let ponyExpress = PostOffice()
        var received = 0

        ponyExpress.register { (_: ExampleNotification, _: AnyObject?) in
            received += 1
        }

        ponyExpress.register(sender: sender, { (_: ExampleNotification) in
            received += 1
        })

        ponyExpress.post(ExampleNotification(info: 12, other: 15), sender: sender)
        ponyExpress.post(ExampleNotification(info: 12, other: 15), sender: other)
        XCTAssertEqual(received, 3)
    }
}
