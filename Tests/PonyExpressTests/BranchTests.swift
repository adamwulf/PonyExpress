import XCTest
@testable import PonyExpress

final class BranchTests: XCTestCase {
    func testSenderSubclass() throws {
        class MyLetter {
            var foo: Int
            init(_ foo: Int) { self.foo = foo }
        }
        class MySubLetter: MyLetter { }
        class MySender { }
        class MySubSender: MySender { }

        class SpecificRecipient {
            var count = 0
            func receiveLetter(notification: MyLetter, sender: MySender?) {
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

    func testSubscribeProtocol() throws {
        class MyLetter: Mail {
            var foo: Int
            init(_ foo: Int) { self.foo = foo }
        }
        class OtherLetter: Mail { }
        class MySender { }

        class SpecificRecipient {
            var count = 0
            func receiveLetter(notification: Mail, sender: MySender?) {
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

    func testNilSender() throws {
        class MyLetter: Mail {
            var foo: Int
            init(_ foo: Int) { self.foo = foo }
        }
        class OtherLetter: Mail { }
        class MySender { }

        class SpecificRecipient {
            var count = 0
            func receiveLetter(notification: Mail, sender: MySender?) {
                count += 1
            }
        }

        let recipient = SpecificRecipient()
        let postOffice = PostOfficeBranch<Mail, MySender>()

        postOffice.register(recipient, SpecificRecipient.receiveLetter)
        postOffice.post(MyLetter(13))

        XCTAssertEqual(recipient.count, 1)
    }

    func testSpecificSender() throws {
        class MyLetter: Mail {
            var foo: Int
            init(_ foo: Int) { self.foo = foo }
        }
        class OtherLetter: Mail { }
        class MySender { }

        class SpecificRecipient {
            var count = 0
            func receiveLetter(notification: Mail, sender: MySender?) {
                count += 1
            }
        }

        let sender = MySender()
        let recipient = SpecificRecipient()
        let postOffice = PostOfficeBranch<Mail, MySender>()

        postOffice.register(sender: sender, recipient, SpecificRecipient.receiveLetter)
        postOffice.post(MyLetter(13), sender: MySender())
        postOffice.post(MyLetter(13), sender: sender)
        postOffice.post(MyLetter(13))

        XCTAssertEqual(recipient.count, 1)
    }

    func testUnregister() {
        class MyLetter: Mail {
            var foo: Int
            init(_ foo: Int) { self.foo = foo }
        }
        class OtherLetter: Mail { }
        class MySender { }

        class SpecificRecipient {
            var count = 0
            func receiveLetter(notification: Mail, sender: MySender?) {
                count += 1
            }
        }

        let sender = MySender()
        let recipient = SpecificRecipient()
        let postOffice = PostOfficeBranch<Mail, MySender>()

        let id = postOffice.register(sender: sender, recipient, SpecificRecipient.receiveLetter)
        postOffice.post(MyLetter(13), sender: sender)
        postOffice.unregister(id)
        postOffice.post(MyLetter(13), sender: sender)

        XCTAssertEqual(recipient.count, 1)
    }
}
