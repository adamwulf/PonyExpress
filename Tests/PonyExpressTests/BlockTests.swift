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

    func testReceiveInts() throws {
        let postOffice = PostOffice()
        var count = 0

        postOffice.register { (sent: Int) -> Void in
            count = sent
        }

        postOffice.post(12)
        XCTAssertEqual(count, 12)
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

    func testMatchExactSender() throws {
        let sender1 = NSObject()
        let sender2 = NSObject()
        let postOffice = PostOffice()
        var received = 0

        postOffice.register(sender: sender1) { (_: ExampleLetter) -> Void in
            received += 1
        }

        postOffice.post(ExampleLetter(info: 12, other: 15), sender: sender1)
        postOffice.post(ExampleLetter(info: 12, other: 15), sender: sender2)
        postOffice.post(ExampleLetter(info: 12, other: 15))
        XCTAssertEqual(received, 1)
    }

    func testMatchSenderTypeExplicit() throws {
        let sender1 = NSObject()
        let sender2 = NSObject()
        let postOffice = PostOffice()
        var received = 0

        postOffice.register(sender: sender1) { (_: ExampleLetter, _: NSObject) -> Void in
            received += 1
        }

        postOffice.post(ExampleLetter(info: 12, other: 15), sender: sender1)
        postOffice.post(ExampleLetter(info: 12, other: 15), sender: sender2)
        postOffice.post(ExampleLetter(info: 12, other: 15))
        XCTAssertEqual(received, 1)
    }

    func testMatchExplicitSenderForAnyPostedSender() throws {
        let sender1 = NSObject()
        let sender2 = NSObject()
        let postOffice = PostOffice()
        var received = 0

        postOffice.register { (_: ExampleLetter, _: NSObject) -> Void in
            received += 1
        }

        postOffice.post(ExampleLetter(info: 12, other: 15), sender: sender1)
        postOffice.post(ExampleLetter(info: 12, other: 15), sender: sender2)
        postOffice.post(ExampleLetter(info: 12, other: 15))
        XCTAssertEqual(received, 2)
    }

    func testMatchSenderTypeOptional() throws {
        let sender = NSObject()
        let postOffice = PostOffice()
        var received = 0

        postOffice.register { (_: ExampleLetter, _: NSObject?) -> Void in
            received += 1
        }

        postOffice.post(ExampleLetter(info: 12, other: 15), sender: sender)
        postOffice.post(ExampleLetter(info: 12, other: 15))
        XCTAssertEqual(received, 2)
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

    func testMatchOptionalSenderType() throws {
        class SomeObject {}
        let senderType1 = SomeObject()
        let senderType2 = NSObject()
        let postOffice = PostOffice()
        var received = 0

        postOffice.register { (_: ExampleLetter, _ sender: SomeObject?) -> Void in
            received += 1
        }

        postOffice.post(ExampleLetter(info: 12, other: 15), sender: senderType1)
        postOffice.post(ExampleLetter(info: 12, other: 15), sender: senderType2)
        postOffice.post(ExampleLetter(info: 12, other: 15))
        XCTAssertEqual(received, 2)
    }

    func testMatchExplicitSenderType2() throws {
        class SomeObject {}
        let senderType1 = SomeObject()
        let senderType2 = NSObject()
        let postOffice = PostOffice()
        var received = 0

        postOffice.register { (_: ExampleLetter, _ sender: SomeObject) -> Void in
            received += 1
        }

        postOffice.post(ExampleLetter(info: 12, other: 15), sender: senderType1)
        postOffice.post(ExampleLetter(info: 12, other: 15), sender: senderType2)
        postOffice.post(ExampleLetter(info: 12, other: 15))
        XCTAssertEqual(received, 1)
    }

    func testAsync() throws {
        let postOffice = PostOffice()
        let queue = DispatchQueue(label: "any.queue")
        var received = 0
        let exp = expectation(description: "wait for letter")

        postOffice.register(queue: queue) { (_: ExampleLetter) -> Void in
            XCTAssert(!Thread.isMainThread)
            received += 1
            exp.fulfill()
        }

        XCTAssertEqual(received, 0)

        postOffice.post(ExampleLetter(info: 12, other: 15))

        wait(for: [exp], timeout: 0.1)

        XCTAssertEqual(received, 1)
    }

    func testRegisterFunction() throws {
        let postOffice = PostOffice()
        let queue = DispatchQueue(label: "any.queue")
        var received = 0

        let exp = expectation(description: "wait for letter")
        func listener(_ letter: ExampleLetter) {
            XCTAssert(!Thread.isMainThread)
            received += 1
            exp.fulfill()
        }

        postOffice.register(queue: queue, listener(_:))

        XCTAssertEqual(received, 0)

        postOffice.post(ExampleLetter(info: 12, other: 15))

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

        postOffice.post(ExampleObjectLetter(), sender: sender)
        postOffice.post(ExampleSubObjectLetter(), sender: sender)
        XCTAssertEqual(objectReceived, 2)
        XCTAssertEqual(subObjectReceived, 1)
    }

    func testSubscribeProtocol() throws {
        class MyLetter: Mail {
            var foo: Int
            init(_ foo: Int) { self.foo = foo }
        }
        class OtherLetter: Mail { }
        class OtherThing { }
        class MySender { }

        class SpecificRecipient {
            var count = 0
            func receiveLetter(letter: Mail, sender: MySender?) {
                count += 1
            }
        }

        let recipient = SpecificRecipient()
        let postOffice = PostOffice()

        postOffice.register(recipient, SpecificRecipient.receiveLetter)
        postOffice.post(MyLetter(13), sender: MySender())
        postOffice.post(OtherLetter(), sender: MySender())
        postOffice.post(OtherThing(), sender: MySender())

        XCTAssertEqual(recipient.count, 2)
    }

}
