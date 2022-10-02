import XCTest
@testable import PonyExpress

final class PonyExpressTests: XCTestCase {
    func testSimple() throws {
        let ponyExpress = PostOffice()
        var received = 0

        ponyExpress.register { (_: ExampleNotification) -> Void in
            received += 1
        }

        ponyExpress.post(ExampleNotification(info: 12, other: 15))
        XCTAssertEqual(received, 1)
    }

    func testIgnoreSender() throws {
        let sender = NSObject()
        let ponyExpress = PostOffice()
        var received = 0

        ponyExpress.register { (_: ExampleNotification) -> Void in
            received += 1
        }

        ponyExpress.post(ExampleNotification(info: 12, other: 15), sender: sender)
        XCTAssertEqual(received, 1)
    }

    func testMatchSender() throws {
        let sender = NSObject()
        let ponyExpress = PostOffice()
        var received = 0

        ponyExpress.register(sender: sender) { (_: ExampleNotification) -> Void in
            received += 1
        }

        ponyExpress.post(ExampleNotification(info: 12, other: 15), sender: sender)
        XCTAssertEqual(received, 1)
    }

    func testFailedMatchSender() throws {
        let sender = NSObject()
        let other = NSObject()
        let ponyExpress = PostOffice()
        var received = 0

        ponyExpress.register(sender: sender) { (_: ExampleNotification) -> Void in
            received += 1
        }

        ponyExpress.post(ExampleNotification(info: 12, other: 15), sender: other)
        XCTAssertEqual(received, 0)
    }

    func testAsync() throws {
        let ponyExpress = PostOffice()
        let queue = DispatchQueue(label: "any.queue")
        var received = 0

        ponyExpress.register(queue: queue) { (_: ExampleNotification) -> Void in
            received += 1
        }

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

        ponyExpress.register(sender: sender) { (_: ExampleNotification) in
            received += 1
        }

        ponyExpress.post(ExampleNotification(info: 12, other: 15), sender: sender)
        ponyExpress.post(ExampleNotification(info: 12, other: 15), sender: other)
        XCTAssertEqual(received, 3)
    }

    func testEnumLetter() throws {
        let ponyExpress = PostOffice()
        var received = 0

        ponyExpress.register { (_: MultipleChoice) in
            received += 1
        }

        ponyExpress.post(MultipleChoice.option1)
        ponyExpress.post(MultipleChoice.option2)
        XCTAssertEqual(received, 2)
    }

    func testRecipient() throws {
        let ponyExpress = PostOffice()
        let recipient = ExampleRecipient()

        ponyExpress.register(recipient)
        ponyExpress.post(ExampleNotification(info: 12, other: 15))
        ponyExpress.post(Package<Int>(contents: 12))

        XCTAssertEqual(recipient.count, 1)
    }

    func testUnregsiterRecipient() throws {
        let ponyExpress = PostOffice()
        let recipient = ExampleRecipient()

        let id = ponyExpress.register(recipient)

        ponyExpress.post(ExampleNotification(info: 12, other: 15))
        ponyExpress.post(Package<Int>(contents: 12))

        ponyExpress.unregister(id)

        ponyExpress.post(ExampleNotification(info: 12, other: 15))
        ponyExpress.post(Package<Int>(contents: 12))

        XCTAssertEqual(recipient.count, 1)
    }

    func testWeakRecipient() throws {
        let ponyExpress = PostOffice()
        var count = 0
        let block = {
            count += 1
        }
        autoreleasepool {
            let recipient = ExampleRecipient()
            recipient.block = block
            ponyExpress.register(recipient)

            ponyExpress.post(ExampleNotification(info: 12, other: 15))
            ponyExpress.post(Package<Int>(contents: 12))

            XCTAssertEqual(count, 1)
            XCTAssertEqual(ponyExpress.count, 1)
        }

        ponyExpress.post(ExampleNotification(info: 12, other: 15))
        ponyExpress.post(Package<Int>(contents: 12))

        XCTAssertEqual(count, 1)
        XCTAssertEqual(ponyExpress.count, 0)
    }
}
