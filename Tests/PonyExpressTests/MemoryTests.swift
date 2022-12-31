import XCTest
@testable import PonyExpress

final class MemoryTests: XCTestCase {
    func testPostmarkedWeakSender() throws {
        class SpecificRecipient {
            var count = 0
            func receivePostmarked1(notification: ExamplePostmarked, sender: PostmarkedSender) {
                count += 1
            }
            func receivePostmarked3(notification: ExamplePostmarked) {
                count += 1
            }
        }

        let postOffice = PostOffice()
        let sender2 = PostmarkedSender()
        let notification = ExamplePostmarked(info: 1, other: 2)
        let recipient = SpecificRecipient()

        autoreleasepool {
            let sender1 = PostmarkedSender()

            postOffice.register(sender: sender1, recipient, SpecificRecipient.receivePostmarked1)
            postOffice.register(sender: sender1, recipient, SpecificRecipient.receivePostmarked3)

            postOffice.post(notification, sender: sender1)

            XCTAssertEqual(postOffice.count, 2)
        }

        // While the senders have dealloc'd, we still hold RecipientIds for the registered listeners
        // that will cleanup after a notification is sent to that key again
        XCTAssertEqual(postOffice.count, 2)

        postOffice.post(notification, sender: sender2)

        XCTAssertEqual(postOffice.count, 0)
    }

    func testPostmarkedWeakRecipient() throws {
        let postOffice = PostOffice()
        let sender1 = PostmarkedSender()
        let notification = ExamplePostmarked(info: 1, other: 2)

        autoreleasepool {
            class SpecificRecipient {
                var count = 0
                func receivePostmarked1(notification: ExamplePostmarked, sender: PostmarkedSender) {
                    count += 1
                }
                func receivePostmarked3(notification: ExamplePostmarked) {
                    count += 1
                }
            }

            let recipient = SpecificRecipient()

            postOffice.register(sender: sender1, recipient, SpecificRecipient.receivePostmarked1)
            postOffice.register(sender: sender1, recipient, SpecificRecipient.receivePostmarked3)

            postOffice.post(notification, sender: sender1)

            XCTAssertEqual(postOffice.count, 2)
        }

        // While the senders have dealloc'd, we still hold RecipientIds for the registered listeners
        // that will cleanup after a notification is sent to that key again
        XCTAssertEqual(postOffice.count, 2)

        postOffice.post(notification, sender: sender1)

        XCTAssertEqual(postOffice.count, 0)
    }

    func testUnmarkedWeakSender() throws {
        class SpecificRecipient {
            var count = 0
            func receivePostmarked1(notification: ExampleUnmarked, sender: UnmarkedSender) {
                count += 1
            }
            func receivePostmarked3(notification: ExampleUnmarked) {
                count += 1
            }
        }

        let postOffice = PostOffice()
        let sender2 = UnmarkedSender()
        let notification = ExampleUnmarked(info: 1, other: 2)
        let recipient = SpecificRecipient()

        autoreleasepool {
            let sender1 = UnmarkedSender()

            postOffice.register(sender: sender1, recipient, SpecificRecipient.receivePostmarked1)
            postOffice.register(sender: sender1, recipient, SpecificRecipient.receivePostmarked3)

            postOffice.post(notification, sender: sender1)

            XCTAssertEqual(postOffice.count, 2)
        }

        // While the senders have dealloc'd, we still hold RecipientIds for the registered listeners
        // that will cleanup after a notification is sent to that key again
        XCTAssertEqual(postOffice.count, 2)

        postOffice.post(notification, sender: sender2)

        XCTAssertEqual(postOffice.count, 0)
    }

    func testUnmarkedWeakRecipient() throws {
        let postOffice = PostOffice()
        let sender1 = UnmarkedSender()
        let notification = ExampleUnmarked(info: 1, other: 2)

        autoreleasepool {
            class SpecificRecipient {
                var count = 0
                func receivePostmarked1(notification: ExampleUnmarked, sender: UnmarkedSender) {
                    count += 1
                }
                func receivePostmarked3(notification: ExampleUnmarked) {
                    count += 1
                }
            }

            let recipient = SpecificRecipient()

            postOffice.register(sender: sender1, recipient, SpecificRecipient.receivePostmarked1)
            postOffice.register(sender: sender1, recipient, SpecificRecipient.receivePostmarked3)

            postOffice.post(notification, sender: sender1)

            XCTAssertEqual(postOffice.count, 2)
        }

        // While the senders have dealloc'd, we still hold RecipientIds for the registered listeners
        // that will cleanup after a notification is sent to that key again
        XCTAssertEqual(postOffice.count, 2)

        postOffice.post(notification, sender: sender1)

        XCTAssertEqual(postOffice.count, 0)
    }
}
