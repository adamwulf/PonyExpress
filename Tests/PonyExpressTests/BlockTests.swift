import XCTest
@testable import PonyExpress

final class BlockTests: XCTestCase {
    func testSimple() throws {
        let postOffice = PostOffice()
        var received = 0

        postOffice.register { (_: ExampleLetter) -> Void in
            received += 1
        }

        postOffice.post(ExampleLetter(info: 12, other: 15))
        XCTAssertEqual(received, 1)
    }

    func testIgnoreSender() throws {
        let sender = NSObject()
        let postOffice = PostOffice()
        var received = 0

        postOffice.register { (_: ExampleLetter) -> Void in
            received += 1
        }

        postOffice.post(ExampleLetter(info: 12, other: 15), sender: sender)
        XCTAssertEqual(received, 1)
    }

    func testMatchSender() throws {
        let sender = NSObject()
        let postOffice = PostOffice()
        var received = 0

        postOffice.register(sender: sender) { (_: ExampleLetter) -> Void in
            received += 1
        }

        postOffice.post(ExampleLetter(info: 12, other: 15), sender: sender)
        XCTAssertEqual(received, 1)
    }

    func testFailedMatchSender() throws {
        let sender = NSObject()
        let other = NSObject()
        let postOffice = PostOffice()
        var received = 0

        postOffice.register(sender: sender) { (_: ExampleLetter) -> Void in
            received += 1
        }

        postOffice.post(ExampleLetter(info: 12, other: 15), sender: other)
        XCTAssertEqual(received, 0)
    }

    func testMatchSenderType() throws {
        class SomeObject {}
        let sender = SomeObject()
        let other = NSObject()
        let postOffice = PostOffice()
        var received = 0

        postOffice.register { (_: ExampleLetter, _ sender: SomeObject?) -> Void in
            received += 1
        }

        postOffice.post(ExampleLetter(info: 12, other: 15), sender: sender)
        postOffice.post(ExampleLetter(info: 12, other: 15), sender: other)
        postOffice.post(ExampleLetter(info: 12, other: 15))
        XCTAssertEqual(received, 2)
    }

    func testMatchSenderType2() throws {
        class SomeObject {}
        let sender = SomeObject()
        let other = NSObject()
        let postOffice = PostOffice()
        var received = 0

        postOffice.register { (_: ExampleLetter, _ sender: SomeObject) -> Void in
            received += 1
        }

        postOffice.post(ExampleLetter(info: 12, other: 15), sender: sender)
        postOffice.post(ExampleLetter(info: 12, other: 15), sender: other)
        postOffice.post(ExampleLetter(info: 12, other: 15))
        XCTAssertEqual(received, 1)
    }

    func testAsync() throws {
        let postOffice = PostOffice()
        let queue = DispatchQueue(label: "any.queue")
        var received = 0

        postOffice.register(queue: queue) { (_: ExampleLetter) -> Void in
            received += 1
        }

        XCTAssertEqual(received, 0)

        postOffice.post(ExampleLetter(info: 12, other: 15))

        let exp = expectation(description: "wait for letter")
        queue.async {
            exp.fulfill()
        }
        wait(for: [exp], timeout: 0.1)

        XCTAssertEqual(received, 1)
    }

    func testRegisterFunction() throws {
        let postOffice = PostOffice()
        let queue = DispatchQueue(label: "any.queue")
        var received = 0

        func listener(_ letter: ExampleLetter) {
            received += 1
        }

        postOffice.register(queue: queue, listener(_:))

        XCTAssertEqual(received, 0)

        postOffice.post(ExampleLetter(info: 12, other: 15))

        let exp = expectation(description: "wait for letter")
        queue.async {
            exp.fulfill()
        }
        wait(for: [exp], timeout: 0.1)

        XCTAssertEqual(received, 1)
    }

    func testSender() throws {
        class OtherSender { }
        let sender = NSObject()
        let other = NSObject()
        let postOffice = PostOffice()
        var received = 0

        postOffice.register { (_: ExampleLetter, _: OtherSender?) in
            received += 1
        }

        postOffice.register { (_: ExampleLetter, _: NSObject?) in
            received += 1
        }

        postOffice.register(sender: sender) { (_: ExampleLetter) in
            received += 1
        }

        postOffice.post(ExampleLetter(info: 12, other: 15), sender: sender)
        postOffice.post(ExampleLetter(info: 12, other: 15), sender: other)
        XCTAssertEqual(received, 3)
    }

    func testEnumLetter() throws {
        let postOffice = PostOffice()
        var received = 0

        postOffice.register { (_: MultipleChoice) in
            received += 1
        }

        postOffice.post(MultipleChoice.option1)
        postOffice.post(MultipleChoice.option2)
        XCTAssertEqual(received, 2)
    }

    func testRegisterSubclass() throws {
        class ExampleObjectLetter { }
        class ExampleSubObjectLetter: ExampleObjectLetter { }

        let sender = NSObject()
        let postOffice = PostOffice()
        var objectReceived = 0
        var subObjectReceived = 0

        postOffice.register { (_: ExampleObjectLetter) -> Void in
            objectReceived += 1
        }
        postOffice.register { (_: ExampleSubObjectLetter) -> Void in
            subObjectReceived += 1
        }

        postOffice.post(ExampleSubObjectLetter(), sender: sender)
        XCTAssertEqual(objectReceived, 1)
        XCTAssertEqual(subObjectReceived, 1)
    }

    func testReceiveInts() throws {
        let postOffice = PostOffice()
        var count = 0

        postOffice.register { (sent: Int) -> Void in
            count = sent
        }

        postOffice.post(12)
        XCTAssertEqual(count, 12)
    }
}
