import XCTest
@testable import PonyExpress

final class PonyExpressTests: XCTestCase {
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
        let sender = NSObject()
        let other = NSObject()
        let postOffice = PostOffice()
        var received = 0

        postOffice.register { (_: ExampleLetter, _: AnyObject?) in
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

    func testRecipient() throws {
        let postOffice = PostOffice()
        let recipient = ExampleRecipient()

        postOffice.register(recipient)
        postOffice.post(ExampleLetter(info: 12, other: 15))
        postOffice.post(Package<Int>(contents: 12))

        XCTAssertEqual(recipient.count, 1)
    }

    func testUnregsiterRecipient() throws {
        let postOffice = PostOffice()
        let recipient = ExampleRecipient()

        let id = postOffice.register(recipient)

        postOffice.post(ExampleLetter(info: 12, other: 15))
        postOffice.post(Package<Int>(contents: 12))

        postOffice.unregister(id)

        postOffice.post(ExampleLetter(info: 12, other: 15))
        postOffice.post(Package<Int>(contents: 12))

        XCTAssertEqual(recipient.count, 1)
    }

    func testWeakRecipient() throws {
        let postOffice = PostOffice()
        var count = 0
        let block = {
            count += 1
        }
        autoreleasepool {
            let recipient = ExampleRecipient()
            recipient.block = block
            postOffice.register(recipient)

            postOffice.post(ExampleLetter(info: 12, other: 15))
            postOffice.post(Package<Int>(contents: 12))

            XCTAssertEqual(count, 1)
            XCTAssertEqual(postOffice.count, 1)
        }

        postOffice.post(ExampleLetter(info: 12, other: 15))
        postOffice.post(Package<Int>(contents: 12))

        XCTAssertEqual(count, 1)
        XCTAssertEqual(postOffice.count, 0)
    }

    func testTypedSelector() throws {
        let postOffice = PostOffice()
        var count = 0
        let block = {
            count += 1
        }
        autoreleasepool {
            let recipient = OtherRecipient()
            recipient.block = block
            postOffice.register(recipient, OtherRecipient.receive)

            postOffice.post(ExampleLetter(info: 12, other: 15))
            postOffice.post(Package<Int>(contents: 12))

            XCTAssertEqual(count, 1)
            XCTAssertEqual(postOffice.count, 1)
        }

        postOffice.post(ExampleLetter(info: 12, other: 15))
        postOffice.post(Package<Int>(contents: 12))

        XCTAssertEqual(count, 1)
        XCTAssertEqual(postOffice.count, 0)
    }

    func testRegisterMethodWithSender() {
        class RecipientWithMethod {
            var block: (() -> Void)?

            func receive(letter: ExampleLetter, sender: AnyObject?) {
                block?()
            }
        }

        let postOffice = PostOffice()
        var count = 0
        let block = {
            count += 1
        }

        autoreleasepool {
            let recipient = RecipientWithMethod()
            recipient.block = block

            postOffice.register(recipient, RecipientWithMethod.receive)
            postOffice.post(ExampleLetter(info: 12, other: 15))
            XCTAssertEqual(count, 1)
            XCTAssertEqual(postOffice.count, 1)
        }

        postOffice.post(ExampleLetter(info: 12, other: 15))
        XCTAssertEqual(count, 1)
        XCTAssertEqual(postOffice.count, 0)
    }

    func testRegisterMethodWithoutSender() {
        class RecipientWithMethod {
            var block: (() -> Void)?

            func receive(letter: ExampleLetter) {
                block?()
            }
        }

        let postOffice = PostOffice()
        var count = 0
        let block = {
            count += 1
        }

        autoreleasepool {
            let recipient = RecipientWithMethod()
            recipient.block = block

            postOffice.register(recipient, RecipientWithMethod.receive)
            postOffice.post(ExampleLetter(info: 12, other: 15))
            XCTAssertEqual(count, 1)
            XCTAssertEqual(postOffice.count, 1)
        }

        postOffice.post(ExampleLetter(info: 12, other: 15))
        XCTAssertEqual(count, 1)
        XCTAssertEqual(postOffice.count, 0)
    }

    func testRegisterMethodSpecificSender() {
        let postOffice = PostOffice()
        let sender = NSObject()
        var count = 0
        let block = {
            count += 1
        }

        autoreleasepool {
            let recipient = ExampleRecipient()
            recipient.block = block

            postOffice.register(sender: sender, recipient, ExampleRecipient.receive)
            postOffice.post(ExampleLetter(info: 12, other: 15), sender: sender)
            postOffice.post(ExampleLetter(info: 12, other: 15))
            XCTAssertEqual(count, 1)
            XCTAssertEqual(postOffice.count, 1)
        }

        postOffice.post(ExampleLetter(info: 12, other: 15))
        XCTAssertEqual(count, 1)
        XCTAssertEqual(postOffice.count, 0)
    }

    func testRegisterForPackage() {
        class RecipientWithMethod {
            var block: (() -> Void)?

            func receive(package: Package<Int>) {
                block?()
            }
        }

        let postOffice = PostOffice()
        var count = 0
        let block = {
            count += 1
        }

        autoreleasepool {
            let recipient = RecipientWithMethod()
            recipient.block = block

            postOffice.register(recipient, RecipientWithMethod.receive)
            postOffice.post(Package<Int>(contents: 12))
            XCTAssertEqual(count, 1)
            XCTAssertEqual(postOffice.count, 1)
        }

        postOffice.post(Package<Int>(contents: 13))
        XCTAssertEqual(count, 1)
        XCTAssertEqual(postOffice.count, 0)
    }

    func testRegisterSubclass() throws {
        class ExampleObjectLetter: Letter { }
        class ExampleSubObjectLetter: ExampleObjectLetter { }

        let sender = NSObject()
        let postOffice = PostOffice()
        var received = 0

        postOffice.register { (_: ExampleObjectLetter) -> Void in
            received += 1
        }

        postOffice.post(ExampleSubObjectLetter(), sender: sender)
        XCTAssertEqual(received, 1) // fails :(
    }
}
