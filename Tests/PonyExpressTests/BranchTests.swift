import XCTest
@testable import PonyExpress

final class BranchTests: XCTestCase {
    func testSenderSubclass() throws {
        class MyNote {
            var foo: Int
            init(_ foo: Int) { self.foo = foo }
        }
        class MySubNote: MyNote { }
        class MySender { }
        class MySubSender: MySender { }

        class SpecificRecipient {
            var count = 0
            func receive(notification: MyNote, sender: MySender?) {
                count += 1
            }
        }

        let note = MyNote(13)
        let subNote = MySubNote(12)
        let subSender = MySubSender()
        let recipient = SpecificRecipient()
        let postOffice = PostOfficeBranch<MyNote, MySender>()

        postOffice.register(recipient, SpecificRecipient.receive)
        postOffice.post(note, sender: subSender)
        postOffice.post(subNote, sender: subSender)

        XCTAssertEqual(recipient.count, 2)
    }

    func testSubscribeProtocol() throws {
        class MyNote: Mail {
            var foo: Int
            init(_ foo: Int) { self.foo = foo }
        }
        class OtherNote: Mail { }
        class MySender { }

        class SpecificRecipient {
            var count = 0
            func receive(notification: Mail, sender: MySender?) {
                count += 1
            }
        }

        let recipient = SpecificRecipient()
        let postOffice = PostOfficeBranch<Mail, MySender>()

        postOffice.register(recipient, SpecificRecipient.receive)
        postOffice.post(MyNote(13), sender: MySender())
        postOffice.post(OtherNote(), sender: MySender())

        XCTAssertEqual(recipient.count, 2)
    }

    func testNilSender() throws {
        class MyNote: Mail {
            var foo: Int
            init(_ foo: Int) { self.foo = foo }
        }
        class OtherNote: Mail { }
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
        postOffice.post(MyNote(13))

        XCTAssertEqual(recipient.count, 1)
    }

    func testSpecificSender() throws {
        class MyNote: Mail {
            var foo: Int
            init(_ foo: Int) { self.foo = foo }
        }
        class OtherNote: Mail { }
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
        postOffice.post(MyNote(13), sender: MySender())
        postOffice.post(MyNote(13), sender: sender)
        postOffice.post(MyNote(13))

        XCTAssertEqual(recipient.count, 1)
    }

    func testUnregister() {
        class MyNote: Mail {
            var foo: Int
            init(_ foo: Int) { self.foo = foo }
        }
        class OtherNote: Mail { }
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
        postOffice.post(MyNote(13), sender: sender)
        postOffice.unregister(id)
        postOffice.post(MyNote(13), sender: sender)

        XCTAssertEqual(recipient.count, 1)
    }
}
