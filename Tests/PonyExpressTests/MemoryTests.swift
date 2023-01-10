import XCTest
@testable import PonyExpress

final class MemoryTests: XCTestCase {
    func testVerifiedMailWeakSender() throws {
        class SpecificRecipient {
            var count = 0
            func receiveVerifiedMail1(notification: ExampleVerifiedMail, sender: VerifiedMailSender) {
                count += 1
            }
            func receiveVerifiedMail3(notification: ExampleVerifiedMail) {
                count += 1
            }
        }

        let postOffice = PostOffice()
        let sender2 = VerifiedMailSender()
        let notification = ExampleVerifiedMail(info: 1, other: 2)
        let recipient = SpecificRecipient()

        autoreleasepool {
            let sender1 = VerifiedMailSender()

            postOffice.register(sender: sender1, recipient, SpecificRecipient.receiveVerifiedMail1)

            postOffice.post(notification, sender: sender1)

            XCTAssertEqual(postOffice.count, 1)
        }

        // While the senders have dealloc'd, we still hold RecipientIds for the registered listeners
        // that will cleanup after a notification is sent to that key again
        XCTAssertEqual(postOffice.count, 1)

        postOffice.post(notification, sender: sender2)

        XCTAssertEqual(postOffice.count, 0)
    }

    func testVerifiedMailWeakRecipient() throws {
        let postOffice = PostOffice()
        let sender1 = VerifiedMailSender()
        let notification = ExampleVerifiedMail(info: 1, other: 2)

        autoreleasepool {
            class SpecificRecipient {
                var count = 0
                func receiveVerifiedMail1(notification: ExampleVerifiedMail, sender: VerifiedMailSender) {
                    count += 1
                }
                func receiveVerifiedMail3(notification: ExampleVerifiedMail) {
                    count += 1
                }
            }

            let recipient = SpecificRecipient()

            postOffice.register(sender: sender1, recipient, SpecificRecipient.receiveVerifiedMail1)

            postOffice.post(notification, sender: sender1)

            XCTAssertEqual(postOffice.count, 1)
        }

        // While the senders have dealloc'd, we still hold RecipientIds for the registered listeners
        // that will cleanup after a notification is sent to that key again
        XCTAssertEqual(postOffice.count, 1)

        postOffice.post(notification, sender: sender1)

        XCTAssertEqual(postOffice.count, 0)
    }

    func testVerifiedMailWeakSenderBlock() throws {
        let postOffice = PostOffice()
        let notification = ExampleVerifiedMail(info: 1, other: 2)
        let sender2 = VerifiedMailSender()

        autoreleasepool {
            let sender1 = VerifiedMailSender()

            postOffice.register(sender: sender1) { (_: ExampleVerifiedMail, _: VerifiedMailSender) in
                // noop
            }

            postOffice.post(notification, sender: sender1)

            XCTAssertEqual(postOffice.count, 1)
        }

        // While the senders have dealloc'd, we still hold RecipientIds for the registered listeners
        // that will cleanup after a notification is sent to that key again
        XCTAssertEqual(postOffice.count, 1)

        postOffice.post(notification, sender: sender2)

        XCTAssertEqual(postOffice.count, 0)
    }

    func testUnverifiedMailWeakSender() throws {
        class SpecificRecipient {
            var count = 0
            func receiveVerifiedMail1(notification: ExampleUnverifiedMail, sender: UnverifiedMailSender) {
                count += 1
            }
            func receiveVerifiedMail3(notification: ExampleUnverifiedMail) {
                count += 1
            }
        }

        let postOffice = PostOffice()
        let sender2 = UnverifiedMailSender()
        let notification = ExampleUnverifiedMail(info: 1, other: 2)
        let recipient = SpecificRecipient()

        autoreleasepool {
            let sender1 = UnverifiedMailSender()

            postOffice.register(sender: sender1, recipient, SpecificRecipient.receiveVerifiedMail1)

            postOffice.post(notification, sender: sender1)

            XCTAssertEqual(postOffice.count, 1)
        }

        // While the senders have dealloc'd, we still hold RecipientIds for the registered listeners
        // that will cleanup after a notification is sent to that key again
        XCTAssertEqual(postOffice.count, 1)

        postOffice.post(notification, sender: sender2)

        XCTAssertEqual(postOffice.count, 0)
    }

    func testUnverifiedMailWeakRecipient() throws {
        let postOffice = PostOffice()
        let sender1 = UnverifiedMailSender()
        let notification = ExampleUnverifiedMail(info: 1, other: 2)

        autoreleasepool {
            class SpecificRecipient {
                var count = 0
                func receiveVerifiedMail1(notification: ExampleUnverifiedMail, sender: UnverifiedMailSender) {
                    count += 1
                }
                func receiveVerifiedMail3(notification: ExampleUnverifiedMail) {
                    count += 1
                }
            }

            let recipient = SpecificRecipient()

            postOffice.register(sender: sender1, recipient, SpecificRecipient.receiveVerifiedMail1)

            postOffice.post(notification, sender: sender1)

            XCTAssertEqual(postOffice.count, 1)
        }

        // While the senders have dealloc'd, we still hold RecipientIds for the registered listeners
        // that will cleanup after a notification is sent to that key again
        XCTAssertEqual(postOffice.count, 1)

        postOffice.post(notification, sender: sender1)

        XCTAssertEqual(postOffice.count, 0)
    }

    func testUnverifiedMailWeakSenderBlock() throws {
        let postOffice = PostOffice()
        let notification = ExampleUnverifiedMail(info: 1, other: 2)
        let sender2 = UnverifiedMailSender()

        autoreleasepool {
            let sender1 = UnverifiedMailSender()

            postOffice.register(sender: sender1) { (_: ExampleUnverifiedMail, _: UnverifiedMailSender) in
                // noop
            }

            postOffice.post(notification, sender: sender1)

            XCTAssertEqual(postOffice.count, 1)
        }

        // While the senders have dealloc'd, we still hold RecipientIds for the registered listeners
        // that will cleanup after a notification is sent to that key again
        XCTAssertEqual(postOffice.count, 1)

        postOffice.post(notification, sender: sender2)

        XCTAssertEqual(postOffice.count, 0)
    }

}
