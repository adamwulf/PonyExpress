import XCTest
@testable import PonyExpress

final class ObjectMethodTests: XCTestCase {

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
            postOffice.post(12)

            XCTAssertEqual(count, 1)
            XCTAssertEqual(postOffice.count, 1)
        }

        postOffice.post(ExampleLetter(info: 12, other: 15))
        postOffice.post(12)

        XCTAssertEqual(count, 1)
        XCTAssertEqual(postOffice.count, 0)
    }

    func testRegisterMethodWithSender() {
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

    func testRegisterMethodWithoutSenderForSender() {
        class SomeSender { }
        let postOffice = PostOffice()
        let sender = SomeSender()
        var count = 0
        let block = {
            count += 1
        }

        autoreleasepool {
            let recipient = RecipientWithMethod()
            recipient.block = block

            postOffice.register(sender: sender, recipient, RecipientWithMethod.receive)
            postOffice.post(ExampleLetter(info: 12, other: 15), sender: sender)
            postOffice.post(ExampleLetter(info: 12, other: 15))
            XCTAssertEqual(count, 1)
            XCTAssertEqual(postOffice.count, 1)
        }

        postOffice.post(ExampleLetter(info: 12, other: 15))
        postOffice.post(ExampleLetter(info: 12, other: 15), sender: sender)
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
}
