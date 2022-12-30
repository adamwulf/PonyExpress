import XCTest
@testable import PonyExpress

final class CompilerChecks: XCTestCase {
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
        let wrongSender = MailSender()
        postOffice.post(notification, sender: wrongSender)
    }

    func testPostmarkedRegisterInvalidSender() throws {
        let postOffice = PostOffice()

        class SpecificRecipient {
            var count = 0
            func receivePostmarked3(notification: ExamplePostmarked) {
                count += 1
            }
        }

        let recipient = SpecificRecipient()
        let wrongSender = MailSender()

        // the following should fail to compile. `sender1` is the wrong type
        postOffice.register(sender: wrongSender, recipient, SpecificRecipient.receivePostmarked3)

        XCTAssertEqual(recipient.count, 0)
    }

    func testPostmarkedMethodOptionalSender() throws {
        let notification = ExamplePostmarked(info: 1, other: 2)
        let postOffice = PostOffice()

        class SpecificRecipient {
            var count = 0
            func receivePostmarked2(notification: ExamplePostmarked, sender: PostmarkedSender?) {
                count += 1
            }
        }

        let recipient = SpecificRecipient()

        // Registering a PostMarked method with an optional sender should generate a warning
        postOffice.register(recipient, SpecificRecipient.receivePostmarked2)
    }

    func testPostmarkedBlockOptionalSender() throws {
        let notification = ExamplePostmarked(info: 1, other: 2)
        let sender1 = PostmarkedSender()
        let postOffice = PostOffice()
        var count = 0

        postOffice.register { (_: ExamplePostmarked, _: PostmarkedSender?) in
            count += 1
        }

        postOffice.post(notification, sender: sender1)

        XCTAssertEqual(count, 1)
    }

}
