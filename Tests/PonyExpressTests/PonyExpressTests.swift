import XCTest
@testable import PonyExpress

final class PonyExpressTests: XCTestCase {
    func testExample() throws {
        let ponyExpress = PostOffice()
        var received = 0

        ponyExpress.register({ (_: ExampleNotification) -> Void in
            received += 1
        })

        ponyExpress.post(ExampleNotification(info: 12, other: 15))
        XCTAssertEqual(received, 1)
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

    func testSendingClosure() throws {
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
}
