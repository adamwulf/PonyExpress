import XCTest
@testable import PonyExpress

final class MailMethodTests: XCTestCase {
    func testMail() throws {
        let notification = ExampleMail(info: 1, other: 2)
        let sender = MailSender()
        let postOffice = PostOffice()

        class SpecificRecipient {
            var count = 0
            func receivePostmarked1(notification: ExampleMail, sender: MailSender) {
                count += 1
            }
            func receivePostmarked2(notification: ExampleMail, sender: MailSender?) {
                count += 1
            }
            func receivePostmarked3(notification: ExampleMail) {
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
    }

}
