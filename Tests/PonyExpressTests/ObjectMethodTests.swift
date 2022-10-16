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
            postOffice.post(ExampleLetter(info: 12, other: 15))
            postOffice.post(ExampleLetter(info: 12, other: 15), sender: sender1)
            postOffice.post(ExampleLetter(info: 12, other: 15), sender: sender2)
            XCTAssertEqual(count, 2)
            XCTAssertEqual(postOffice.count, 1)
        }

        postOffice.post(ExampleLetter(info: 12, other: 15))
        postOffice.post(ExampleLetter(info: 12, other: 15), sender: sender1)
        postOffice.post(ExampleLetter(info: 12, other: 15), sender: sender2)
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
            postOffice.post(ExampleLetter(info: 12, other: 15))
            postOffice.post(ExampleLetter(info: 12, other: 15), sender: sender1)
            postOffice.post(ExampleLetter(info: 12, other: 15), sender: sender2)
            XCTAssertEqual(count, 3)
            XCTAssertEqual(postOffice.count, 1)
        }

        postOffice.post(ExampleLetter(info: 12, other: 15))
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
            postOffice.post(ExampleLetter(info: 12, other: 15), sender: sender1)
            postOffice.post(ExampleLetter(info: 12, other: 15), sender: sender2)
            postOffice.post(ExampleLetter(info: 12, other: 15))
            XCTAssertEqual(count, 1)
            XCTAssertEqual(postOffice.count, 1)
        }

        postOffice.post(ExampleLetter(info: 12, other: 15))
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

            postOffice.register(recipient, ExampleRecipient.receiveWithSender)
            postOffice.post(ExampleLetter(info: 12, other: 15), sender: sender1)
            postOffice.post(ExampleLetter(info: 12, other: 15), sender: sender2)
            postOffice.post(ExampleLetter(info: 12, other: 15))
            XCTAssertEqual(count, 2)
            XCTAssertEqual(postOffice.count, 1)
        }

        postOffice.post(ExampleLetter(info: 12, other: 15))
        XCTAssertEqual(count, 2)
        XCTAssertEqual(postOffice.count, 0)
    }

    func testSpecificPostOffice() throws {
        class MyLetter {
            var foo: Int
            init(_ foo: Int) { self.foo = foo }
        }
        class MySubLetter: MyLetter { }
        class MySender { }
        class MySubSender: MySender { }

        class SpecificRecipient {
            var count = 0
            func receiveLetter(letter: MyLetter, sender: MySender?) {
                count += 1
            }
        }

        let letter = MyLetter(13)
        let subLetter = MySubLetter(12)
        let subSender = MySubSender()
        let recipient = SpecificRecipient()
        let postOffice = PostOfficeBranch<MyLetter, MySender>()

        postOffice.register(recipient, SpecificRecipient.receiveLetter)
        postOffice.post(letter, sender: subSender)
        postOffice.post(subLetter, sender: subSender)

        XCTAssertEqual(recipient.count, 2)
    }

    func testSpecificPostOffice2() throws {
        class MyLetter: Mail {
            var foo: Int
            init(_ foo: Int) { self.foo = foo }
        }
        class OtherLetter: Mail { }
        class MySender { }

        class SpecificRecipient {
            var count = 0
            func receiveLetter(letter: Mail, sender: MySender?) {
                count += 1
            }
        }

        let recipient = SpecificRecipient()
        let postOffice = PostOfficeBranch<Mail, MySender>()

        postOffice.register(recipient, SpecificRecipient.receiveLetter)
        postOffice.post(MyLetter(13), sender: MySender())
        postOffice.post(OtherLetter(), sender: MySender())

        XCTAssertEqual(recipient.count, 2)
    }
}
