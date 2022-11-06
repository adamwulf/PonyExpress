import XCTest
@testable import PonyExpress

final class BlockTests: XCTestCase {
    func testSimple() throws {
        let postOffice = PostOffice()
        var received = 0

        postOffice.register { (_: ExampleNotification) -> Void in
            received += 1
        }

        postOffice.post(ExampleNotification(info: 12, other: 15))
        XCTAssertEqual(received, 1)
    }

    func testIgnoreSender() throws {
        let sender = NSObject()
        let postOffice = PostOffice()
        var received = 0

        postOffice.register { (_: ExampleNotification) -> Void in
            received += 1
        }

        postOffice.post(ExampleNotification(info: 12, other: 15), sender: sender)
        XCTAssertEqual(received, 1)
    }

    func testMatchExactSender() throws {
        let sender1 = NSObject()
        let sender2 = NSObject()
        let postOffice = PostOffice()
        var received = 0

        postOffice.register(sender: sender1) { (_: ExampleNotification) -> Void in
            received += 1
        }

        postOffice.post(ExampleNotification(info: 12, other: 15), sender: sender1)
        postOffice.post(ExampleNotification(info: 12, other: 15), sender: sender2)
        postOffice.post(ExampleNotification(info: 12, other: 15))
        XCTAssertEqual(received, 1)
    }

    func testMatchSenderTypeExplicit() throws {
        let sender1 = NSObject()
        let sender2 = NSObject()
        let postOffice = PostOffice()
        var received = 0

        postOffice.register(sender: sender1) { (_: ExampleNotification, _: NSObject) -> Void in
            received += 1
        }

        postOffice.post(ExampleNotification(info: 12, other: 15), sender: sender1)
        postOffice.post(ExampleNotification(info: 12, other: 15), sender: sender2)
        postOffice.post(ExampleNotification(info: 12, other: 15))
        XCTAssertEqual(received, 1)
    }

    func testMatchExplicitSenderForAnyPostedSender() throws {
        let sender1 = NSObject()
        let sender2 = NSObject()
        let postOffice = PostOffice()
        var received = 0

        postOffice.register { (_: ExampleNotification, _: NSObject) -> Void in
            received += 1
        }

        postOffice.post(ExampleNotification(info: 12, other: 15), sender: sender1)
        postOffice.post(ExampleNotification(info: 12, other: 15), sender: sender2)
        postOffice.post(ExampleNotification(info: 12, other: 15))
        XCTAssertEqual(received, 2)
    }

    func testMatchSenderTypeOptional() throws {
        let sender = NSObject()
        let postOffice = PostOffice()
        var received = 0

        postOffice.register { (_: ExampleNotification, _: NSObject?) -> Void in
            received += 1
        }

        postOffice.post(ExampleNotification(info: 12, other: 15), sender: sender)
        postOffice.post(ExampleNotification(info: 12, other: 15))
        XCTAssertEqual(received, 2)
    }

    func testFailedMatchSender() throws {
        let sender = NSObject()
        let other = NSObject()
        let postOffice = PostOffice()
        var received = 0

        postOffice.register(sender: sender) { (_: ExampleNotification) -> Void in
            received += 1
        }

        postOffice.post(ExampleNotification(info: 12, other: 15), sender: other)
        XCTAssertEqual(received, 0)
    }

    func testMatchOptionalSenderType() throws {
        class SomeObject {}
        let senderType1 = SomeObject()
        let senderType2 = NSObject()
        let postOffice = PostOffice()
        var received = 0

        postOffice.register { (_: ExampleNotification, _ sender: SomeObject?) -> Void in
            received += 1
        }

        postOffice.post(ExampleNotification(info: 12, other: 15), sender: senderType1)
        postOffice.post(ExampleNotification(info: 12, other: 15), sender: senderType2)
        postOffice.post(ExampleNotification(info: 12, other: 15))
        XCTAssertEqual(received, 2)
    }

    func testMatchExplicitSenderType2() throws {
        class SomeObject {}
        let senderType1 = SomeObject()
        let senderType2 = NSObject()
        let postOffice = PostOffice()
        var received = 0

        postOffice.register { (_: ExampleNotification, _ sender: SomeObject) -> Void in
            received += 1
        }

        postOffice.post(ExampleNotification(info: 12, other: 15), sender: senderType1)
        postOffice.post(ExampleNotification(info: 12, other: 15), sender: senderType2)
        postOffice.post(ExampleNotification(info: 12, other: 15))
        XCTAssertEqual(received, 1)
    }

    func testAsync() throws {
        let postOffice = PostOffice()
        let queue = DispatchQueue(label: "any.queue")
        var received = 0
        let exp = expectation(description: "wait for notification")

        postOffice.register(queue: queue) { (_: ExampleNotification) -> Void in
            XCTAssert(!Thread.isMainThread)
            received += 1
            exp.fulfill()
        }

        XCTAssertEqual(received, 0)

        postOffice.post(ExampleNotification(info: 12, other: 15))

        wait(for: [exp], timeout: 0.1)

        XCTAssertEqual(received, 1)
    }

    func testRegisterFunction() throws {
        let postOffice = PostOffice()
        let queue = DispatchQueue(label: "any.queue")
        var received = 0

        let exp = expectation(description: "wait for notification")
        func listener(_ notification: ExampleNotification) {
            XCTAssert(!Thread.isMainThread)
            received += 1
            exp.fulfill()
        }

        postOffice.register(queue: queue, listener(_:))

        XCTAssertEqual(received, 0)

        postOffice.post(ExampleNotification(info: 12, other: 15))

        wait(for: [exp], timeout: 0.1)

        XCTAssertEqual(received, 1)
    }

    func testSender() throws {
        class OtherSender { }
        let sender = NSObject()
        let other = NSObject()
        let postOffice = PostOffice()
        var received = 0

        postOffice.register { (_: ExampleNotification, _: OtherSender?) in
            received += 1
        }

        postOffice.register { (_: ExampleNotification, _: NSObject?) in
            received += 1
        }

        postOffice.register(sender: sender) { (_: ExampleNotification) in
            received += 1
        }

        postOffice.post(ExampleNotification(info: 12, other: 15), sender: sender)
        postOffice.post(ExampleNotification(info: 12, other: 15), sender: other)
        XCTAssertEqual(received, 3)
    }

    func testEnumNotification() throws {
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
        class ExampleObjectNotification: Mail { }
        class ExampleSubObjectNotification: ExampleObjectNotification { }

        let sender = NSObject()
        let postOffice = PostOffice()
        var objectReceived = 0
        var subObjectReceived = 0

        postOffice.register { (_: ExampleObjectNotification) -> Void in
            objectReceived += 1
        }
        postOffice.register { (_: ExampleSubObjectNotification) -> Void in
            subObjectReceived += 1
        }

        postOffice.post(ExampleObjectNotification(), sender: sender)
        postOffice.post(ExampleSubObjectNotification(), sender: sender)
        XCTAssertEqual(objectReceived, 2)
        XCTAssertEqual(subObjectReceived, 1)
    }

    func testSubscribeProtocol() throws {
        class MyNote: Mail {
            var foo: Int
            init(_ foo: Int) { self.foo = foo }
        }
        class OtherNote: Mail { }
        class OtherThing: OtherNote { }
        class MySender { }

        class SpecificRecipient {
            var count = 0
            func receiveNotification(notification: OtherNote, sender: MySender?) {
                count += 1
            }
        }

        let recipient = SpecificRecipient()
        let postOffice = PostOffice()

        postOffice.register(recipient, SpecificRecipient.receiveNotification)
        postOffice.post(MyNote(13), sender: MySender())
        postOffice.post(OtherNote(), sender: MySender())
        postOffice.post(OtherThing(), sender: MySender())

        XCTAssertEqual(recipient.count, 2)
    }
}
