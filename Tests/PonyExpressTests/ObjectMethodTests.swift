import XCTest
@testable import PonyExpress

final class ObjectMethodTests: XCTestCase {

    func testObjectHeldWeakly() throws {
        let postOffice = PostOffice()
        var count = 0
        let block = {
            count += 1
        }
        autoreleasepool {
            let recipient = ExampleRecipient()
            recipient.testBlock = block
            postOffice.register(recipient, ExampleRecipient.receiveWithOptSender)

            postOffice.post(ExampleNotification(info: 12, other: 15))
            postOffice.post(12)

            XCTAssertEqual(count, 1)
            XCTAssertEqual(postOffice.count, 1)
        }

        postOffice.post(ExampleNotification(info: 12, other: 15))
        postOffice.post(12)

        XCTAssertEqual(count, 1)
        XCTAssertEqual(postOffice.count, 0)
    }

    func testRegisterMethodWithOptSender() {
        let sender1 = ExampleSender()
        let sender2 = SomeSender()
        let postOffice = PostOffice()
        var count = 0
        let block = {
            count += 1
        }

        autoreleasepool {
            let recipient = ExampleRecipient()
            recipient.testBlock = block

            postOffice.register(recipient, ExampleRecipient.receiveWithOptSender)
            postOffice.post(ExampleNotification(info: 12, other: 15))
            postOffice.post(ExampleNotification(info: 12, other: 15), sender: sender1)
            postOffice.post(ExampleNotification(info: 12, other: 15), sender: sender2)
            XCTAssertEqual(count, 2)
            XCTAssertEqual(postOffice.count, 1)
        }

        postOffice.post(ExampleNotification(info: 12, other: 15))
        postOffice.post(ExampleNotification(info: 12, other: 15), sender: sender1)
        postOffice.post(ExampleNotification(info: 12, other: 15), sender: sender2)
        XCTAssertEqual(count, 2)
        XCTAssertEqual(postOffice.count, 0)
    }

    func testRegisterMethodWithoutSender() {
        let sender1 = ExampleSender()
        let sender2 = SomeSender()
        let postOffice = PostOffice()
        var count = 0
        let block = {
            count += 1
        }

        autoreleasepool {
            let recipient = ExampleRecipient()
            recipient.testBlock = block

            postOffice.register(recipient, ExampleRecipient.receiveWithoutSender)
            postOffice.post(ExampleNotification(info: 12, other: 15))
            postOffice.post(ExampleNotification(info: 12, other: 15), sender: sender1)
            postOffice.post(ExampleNotification(info: 12, other: 15), sender: sender2)
            XCTAssertEqual(count, 3)
            XCTAssertEqual(postOffice.count, 1)
        }

        postOffice.post(ExampleNotification(info: 12, other: 15))
        XCTAssertEqual(count, 3)
        XCTAssertEqual(postOffice.count, 0)
    }

    func testRegisterMethodSpecificSender() {
        let postOffice = PostOffice()
        let sender1 = ExampleSender()
        let sender2 = ExampleSender()
        var count = 0
        let block = {
            count += 1
        }

        autoreleasepool {
            let recipient = ExampleRecipient()
            recipient.testBlock = block

            postOffice.register(sender: sender1, recipient, ExampleRecipient.receiveWithSender)
            postOffice.post(ExampleNotification(info: 12, other: 15), sender: sender1)
            postOffice.post(ExampleNotification(info: 12, other: 15), sender: sender2)
            postOffice.post(ExampleNotification(info: 12, other: 15))
            XCTAssertEqual(count, 1)
            XCTAssertEqual(postOffice.count, 1)
        }

        postOffice.post(ExampleNotification(info: 12, other: 15))
        XCTAssertEqual(count, 1)
        XCTAssertEqual(postOffice.count, 0)
    }

    func testRegisterMethodSpecificSenderWithoutPostedSender() {
        let postOffice = PostOffice()
        let sender1 = ExampleSender()
        let sender2 = ExampleSender()
        var count = 0
        let block = {
            count += 1
        }

        autoreleasepool {
            let recipient = ExampleRecipient()
            recipient.testBlock = block

            postOffice.register(sender: sender1, recipient, ExampleRecipient.receiveWithoutSender)
            postOffice.post(ExampleNotification(info: 12, other: 15), sender: sender1)
            postOffice.post(ExampleNotification(info: 12, other: 15), sender: sender2)
            postOffice.post(ExampleNotification(info: 12, other: 15))
            XCTAssertEqual(count, 1)
            XCTAssertEqual(postOffice.count, 1)
        }

        postOffice.post(ExampleNotification(info: 12, other: 15), sender: sender1)
        XCTAssertEqual(count, 1)
        XCTAssertEqual(postOffice.count, 0)
    }

    func testUnregister() {
        let postOffice = PostOffice()
        let sender1 = ExampleSender()
        let sender2 = ExampleSender()
        var count = 0
        let block = {
            count += 1
        }

        let recipient = ExampleRecipient()
        recipient.testBlock = block

        let id = postOffice.register(sender: sender1, recipient, ExampleRecipient.receiveWithoutSender)
        postOffice.post(ExampleNotification(info: 12, other: 15), sender: sender1)
        postOffice.post(ExampleNotification(info: 12, other: 15), sender: sender2)
        postOffice.post(ExampleNotification(info: 12, other: 15))
        XCTAssertEqual(count, 1)
        XCTAssertEqual(postOffice.count, 1)
        postOffice.unregister(id)

        postOffice.post(ExampleNotification(info: 12, other: 15), sender: sender1)
        XCTAssertEqual(count, 1)
        XCTAssertEqual(postOffice.count, 0)
    }
}
