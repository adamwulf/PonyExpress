import XCTest
@testable import PonyExpress

final class CompilerChecks: XCTestCase {
    func testVerifiedMail() throws {
        let notification = ExampleVerifiedMail(info: 1, other: 2)
        let sender = VerifiedMailSender()
        let postOffice = PostOffice()

        class SpecificRecipient {
            var count = 0
            func receiveVerifiedMail1(notification: ExampleVerifiedMail, sender: VerifiedMailSender) {
                count += 1
            }
            func receiveVerifiedMail2(notification: ExampleVerifiedMail, sender: VerifiedMailSender?) {
                count += 1
            }
            func receiveVerifiedMail3(notification: ExampleVerifiedMail) {
                count += 1
            }
        }

        let recipient = SpecificRecipient()

        postOffice.register(recipient, SpecificRecipient.receiveVerifiedMail1)
        postOffice.register(recipient, SpecificRecipient.receiveVerifiedMail2)
        postOffice.register(recipient, SpecificRecipient.receiveVerifiedMail3)

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

    func testVerifiedMailRegisterInvalidSender() throws {
        let postOffice = PostOffice()

        class SpecificRecipient {
            var count = 0
            func receiveVerifiedMail3(notification: ExampleVerifiedMail) {
                count += 1
            }
        }

        let recipient = SpecificRecipient()
        let wrongSender = MailSender()

        // the following should fail to compile. `sender1` is the wrong type
        postOffice.register(sender: wrongSender, recipient, SpecificRecipient.receiveVerifiedMail3)

        XCTAssertEqual(recipient.count, 0)
    }

    func testVerifiedMailMethodOptionalSender() throws {
        let notification = ExampleVerifiedMail(info: 1, other: 2)
        let postOffice = PostOffice()

        class SpecificRecipient {
            var count = 0
            func receiveVerifiedMail2(notification: ExampleVerifiedMail, sender: VerifiedMailSender?) {
                count += 1
            }
        }

        let recipient = SpecificRecipient()

        // Registering a VerifiedMail method with an optional sender should generate a warning
        postOffice.register(recipient, SpecificRecipient.receiveVerifiedMail2)
    }

    func testVerifiedMailBlockOptionalSender() throws {
        let notification = ExampleVerifiedMail(info: 1, other: 2)
        let sender1 = VerifiedMailSender()
        let postOffice = PostOffice()
        var count = 0

        postOffice.register { (_: ExampleVerifiedMail, _: VerifiedMailSender?) in
            count += 1
        }

        postOffice.post(notification, sender: sender1)

        XCTAssertEqual(count, 1)
    }

}
