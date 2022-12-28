import XCTest
@testable import PonyExpress

final class ObjectMethodTests: XCTestCase {

    func testPostmarked() throws {
        let notification = ExamplePostmarked(info: 1, other: 2)
        let sender = PostmarkedSender()
        let postOffice = PostOffice()

        class SpecificRecipient {
            var count = 0
            func receivePostmarked1(notification: ExamplePostmarked, sender: PostmarkedSender) {
                count += 1
            }
            func receivePostmarked2(notification: ExamplePostmarked, sender: PostmarkedSender?) {
                count += 1
            }
            func receivePostmarked3(notification: ExamplePostmarked) {
                count += 1
            }
        }

        let recipient = SpecificRecipient()

        postOffice.register(recipient, SpecificRecipient.receivePostmarked1)
        postOffice.register(recipient, SpecificRecipient.receivePostmarked2)
        postOffice.register(recipient, SpecificRecipient.receivePostmarked3)

        postOffice.post(notification)
        // hit the method w/o a sender and with a nullable sender, miss the method with required sender
        XCTAssertEqual(recipient.count, 2)
        // hit all three methods
        postOffice.post(notification, sender: sender)
        XCTAssertEqual(recipient.count, 5)

        // the following should fail to compile
//        let wrongSender = MailSender()
//        postOffice.post(notification, sender: wrongSender)
    }

    func testUnregisterPostmarked() throws {
        let notification = ExamplePostmarked(info: 1, other: 2)
        let sender = PostmarkedSender()
        let postOffice = PostOffice()

        class SpecificRecipient {
            var count = 0
            func receivePostmarked1(notification: ExamplePostmarked, sender: PostmarkedSender) {
                count += 1
            }
            func receivePostmarked2(notification: ExamplePostmarked, sender: PostmarkedSender?) {
                count += 1
            }
            func receivePostmarked3(notification: ExamplePostmarked) {
                count += 1
            }
        }

        let recipient = SpecificRecipient()

        let id1 = postOffice.register(recipient, SpecificRecipient.receivePostmarked1)
        let id2 = postOffice.register(recipient, SpecificRecipient.receivePostmarked2)
        let id3 = postOffice.register(recipient, SpecificRecipient.receivePostmarked3)

        postOffice.unregister(id1)
        postOffice.unregister(id2)
        postOffice.unregister(id3)

        postOffice.post(notification, sender: sender)

        XCTAssertEqual(recipient.count, 0)
    }

//    func testNotificationSubtype() throws {
//        class MyNote: OtherNote {
//            var foo: Int
//            init(_ foo: Int) { self.foo = foo }
//        }
//        class OtherNote: Mail { }
//        class SubNote: OtherNote { }
//        class MySender { }
//
//        class SpecificRecipient {
//            var count = 0
//            func receiveMail(notification: OtherNote, sender: MySender?) {
//                count += 1
//            }
//            func receiveOtherNote(notification: SubNote, sender: MySender?) {
//                count += 1
//            }
//        }
//
//        let recipient = SpecificRecipient()
//        let postOffice = PostOffice()
//
//        postOffice.register(recipient, SpecificRecipient.receiveMail)
//        postOffice.register(recipient, SpecificRecipient.receiveOtherNote)
//        postOffice.post(MyNote(12))
//        postOffice.post(SubNote())
//
//        XCTAssertEqual(recipient.count, 3)
//    }
//
//    func testSubscribeProtocol() throws {
//        class MyNote: Mail {
//            var foo: Int
//            init(_ foo: Int) { self.foo = foo }
//        }
//        class OtherNote: Mail { }
//        class OtherThing: OtherNote { }
//        class MySender { }
//
//        class SpecificRecipient {
//            var count = 0
//            func receiveNotification(notification: OtherNote, sender: MySender?) {
//                count += 1
//            }
//        }
//
//        let recipient = SpecificRecipient()
//        let postOffice = PostOffice()
//
//        postOffice.register(recipient, SpecificRecipient.receiveNotification)
//        postOffice.post(MyNote(13), sender: MySender())
//        postOffice.post(OtherNote(), sender: MySender())
//        postOffice.post(OtherThing(), sender: MySender())
//
//        XCTAssertEqual(recipient.count, 2)
//    }
//
//    func testObjectHeldWeakly() throws {
//        let postOffice = PostOffice()
//        var count = 0
//        let block = {
//            count += 1
//        }
//        autoreleasepool {
//            let recipient = ExampleRecipient()
//            recipient.testBlock = block
//            postOffice.register(recipient, ExampleRecipient.receiveWithOptSender)
//
//            postOffice.post(ExampleNotification(info: 12, other: 15))
//
//            XCTAssertEqual(count, 1)
//            XCTAssertEqual(postOffice.count, 1)
//        }
//
//        postOffice.post(ExampleNotification(info: 12, other: 15))
//
//        XCTAssertEqual(count, 1)
//        XCTAssertEqual(postOffice.count, 0)
//    }
//
//    func testRegisterMethodWithOptSender() {
//        let sender1 = ExampleSender()
//        let sender2 = SomeSender()
//        let postOffice = PostOffice()
//        var count = 0
//        let block = {
//            count += 1
//        }
//
//        autoreleasepool {
//            let recipient = ExampleRecipient()
//            recipient.testBlock = block
//
//            postOffice.register(recipient, ExampleRecipient.receiveWithOptSender)
//            postOffice.post(ExampleNotification(info: 12, other: 15))
//            postOffice.post(ExampleNotification(info: 12, other: 15), sender: sender1)
//            postOffice.post(ExampleNotification(info: 12, other: 15), sender: sender2)
//            XCTAssertEqual(count, 2)
//            XCTAssertEqual(postOffice.count, 1)
//        }
//
//        postOffice.post(ExampleNotification(info: 12, other: 15))
//        postOffice.post(ExampleNotification(info: 12, other: 15), sender: sender1)
//        postOffice.post(ExampleNotification(info: 12, other: 15), sender: sender2)
//        XCTAssertEqual(count, 2)
//        XCTAssertEqual(postOffice.count, 0)
//    }
//
//    func testRegisterMethodSpecificSender() {
//        let postOffice = PostOffice()
//        let sender1 = ExampleSender()
//        let sender2 = ExampleSender()
//        var count = 0
//        let block = {
//            count += 1
//        }
//
//        autoreleasepool {
//            let recipient = ExampleRecipient()
//            recipient.testBlock = block
//
//            postOffice.register(sender: sender1, recipient, ExampleRecipient.receiveWithSender)
//            postOffice.post(ExampleNotification(info: 12, other: 15), sender: sender1)
//            postOffice.post(ExampleNotification(info: 12, other: 15), sender: sender2)
//            postOffice.post(ExampleNotification(info: 12, other: 15))
//            XCTAssertEqual(count, 1)
//            XCTAssertEqual(postOffice.count, 1)
//        }
//
//        postOffice.post(ExampleNotification(info: 12, other: 15))
//        XCTAssertEqual(count, 1)
//        XCTAssertEqual(postOffice.count, 0)
//    }
//
//    func testRegisterMethodSpecificSenderWithoutPostedSender() {
//        let postOffice = PostOffice()
//        let sender1 = ExampleSender()
//        let sender2 = ExampleSender()
//        var count = 0
//        let block = {
//            count += 1
//        }
//
//        autoreleasepool {
//            let recipient = ExampleRecipient()
//            recipient.testBlock = block
//
//            postOffice.register(sender: sender1, recipient, ExampleRecipient.receiveWithoutSender)
//            postOffice.post(ExampleNotification(info: 12, other: 15), sender: sender1)
//            postOffice.post(ExampleNotification(info: 12, other: 15), sender: sender2)
//            postOffice.post(ExampleNotification(info: 12, other: 15))
//            XCTAssertEqual(count, 1)
//            XCTAssertEqual(postOffice.count, 1)
//        }
//
//        postOffice.post(ExampleNotification(info: 12, other: 15), sender: sender1)
//        XCTAssertEqual(count, 1)
//        XCTAssertEqual(postOffice.count, 0)
//    }
//
//    func testUnregister() {
//        let postOffice = PostOffice()
//        let sender1 = ExampleSender()
//        let sender2 = ExampleSender()
//        var count = 0
//        let block = {
//            count += 1
//        }
//
//        let recipient = ExampleRecipient()
//        recipient.testBlock = block
//
//        let id = postOffice.register(sender: sender1, recipient, ExampleRecipient.receiveWithoutSender)
//        postOffice.post(ExampleNotification(info: 12, other: 15), sender: sender1)
//        postOffice.post(ExampleNotification(info: 12, other: 15), sender: sender2)
//        postOffice.post(ExampleNotification(info: 12, other: 15))
//        XCTAssertEqual(count, 1)
//        XCTAssertEqual(postOffice.count, 1)
//        postOffice.unregister(id)
//
//        postOffice.post(ExampleNotification(info: 12, other: 15), sender: sender1)
//        XCTAssertEqual(count, 1)
//        XCTAssertEqual(postOffice.count, 0)
//    }
//
//    func testUnregisterObject() {
//        let postOffice = PostOffice()
//        let sender1 = ExampleSender()
//        let sender2 = ExampleSender()
//        var count = 0
//        let block = {
//            count += 1
//        }
//
//        let recipient1 = ExampleRecipient()
//        recipient1.testBlock = block
//        let recipient2 = ExampleRecipient()
//        recipient2.testBlock = block
//
//        postOffice.register(sender: sender1, recipient1, ExampleRecipient.receiveWithoutSender)
//        postOffice.register(sender: sender1, recipient2, ExampleRecipient.receiveWithoutSender)
//        postOffice.post(ExampleNotification(info: 12, other: 15), sender: sender1)
//        postOffice.post(ExampleNotification(info: 12, other: 15), sender: sender2)
//        postOffice.post(ExampleNotification(info: 12, other: 15))
//        XCTAssertEqual(count, 2)
//        XCTAssertEqual(postOffice.count, 2)
//        postOffice.unregister(recipient1)
//        XCTAssertEqual(postOffice.count, 1)
//
//        postOffice.post(ExampleNotification(info: 12, other: 15), sender: sender1)
//        XCTAssertEqual(count, 3)
//        XCTAssertEqual(postOffice.count, 1)
//    }
//
//    func testRegisterNilSender() {
//        let postOffice = PostOffice()
//        let sender1: ExampleSender? = nil
//        var count = 0
//        let block = {
//            count += 1
//        }
//
//        let recipient = ExampleRecipient()
//        recipient.testBlock = block
//
//        let id1 = postOffice.register(sender: sender1, recipient, ExampleRecipient.receiveWithoutSender)
//        postOffice.register(sender: sender1, recipient, ExampleRecipient.receiveWithOptSender)
//        postOffice.post(ExampleNotification(info: 12, other: 15), sender: sender1)
//        XCTAssertEqual(count, 2)
//        XCTAssertEqual(postOffice.count, 2)
//        postOffice.unregister(id1)
//
//        postOffice.post(ExampleNotification(info: 12, other: 15), sender: sender1)
//        XCTAssertEqual(count, 3)
//        XCTAssertEqual(postOffice.count, 1)
//    }
//
//    func testRegisterMethodWithoutSender() {
//        let sender1 = ExampleSender()
//        let sender2 = SomeSender()
//        let postOffice = PostOffice()
//        var count = 0
//        let block = {
//            count += 1
//        }
//
//        autoreleasepool {
//            let recipient = ExampleRecipient()
//            recipient.testBlock = block
//
//            postOffice.register(recipient, ExampleRecipient.receiveWithoutSender)
//            postOffice.post(ExampleNotification(info: 12, other: 15))
//            postOffice.post(ExampleNotification(info: 12, other: 15), sender: sender1)
//            postOffice.post(ExampleNotification(info: 12, other: 15), sender: sender2)
//            XCTAssertEqual(count, 3)
//            XCTAssertEqual(postOffice.count, 1)
//        }
//
//        postOffice.post(ExampleNotification(info: 12, other: 15))
//        XCTAssertEqual(count, 3)
//        XCTAssertEqual(postOffice.count, 0)
//    }
//
//    func testRegisterSubclassMethodWithoutSender() {
//        let sender1 = ExampleSender()
//        let postOffice = PostOffice()
//        var count = 0
//        let block = {
//            count += 1
//        }
//
//        autoreleasepool {
//            let recipient: ExampleRecipient = SubclassExampleRecipient()
//            recipient.testBlock = block
//
//            postOffice.register(recipient, ExampleRecipient.receiveWithSender)
//            postOffice.post(ExampleNotification(info: 12, other: 15), sender: sender1)
//            XCTAssertEqual(count, 1)
//            XCTAssertEqual(postOffice.count, 1)
//            XCTAssertEqual(recipient.count, 2) // we increment the recipient's count twice in the subclass
//        }
//
//        postOffice.post(ExampleNotification(info: 12, other: 15))
//        XCTAssertEqual(count, 1)
//        XCTAssertEqual(postOffice.count, 0)
//    }
//
//    func testDeallocSender() {
//        let postOffice = PostOffice()
//
//        var count = 0
//        let block = {
//            count += 1
//        }
//
//        let recipient1 = ExampleRecipient()
//        recipient1.testBlock = block
//
//        autoreleasepool {
//            let sender = ExampleSender()
//            postOffice.register(sender: sender, recipient1, ExampleRecipient.receiveWithoutSender)
//            postOffice.post(ExampleNotification(info: 12, other: 15), sender: sender)
//            XCTAssertEqual(count, 1)
//            XCTAssertEqual(postOffice.count, 1)
//        }
//        postOffice.post(ExampleNotification(info: 12, other: 15))
//
//        XCTAssertEqual(postOffice.count, 0)
//    }
}
