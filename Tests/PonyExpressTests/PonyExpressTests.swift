import XCTest
@testable import PonyExpress

final class PonyExpressTests: XCTestCase {
    func testExample() throws {
        let ponyExpress = PostOffice<UserInfo>()
        var received = 0
        let graph = TestObserver()
        graph.observe = { letter in
            guard case .specificInfo(let objectKeys) = letter.contents else {
                XCTFail()
                return
            }
            XCTAssertEqual(letter.name, .NSCalendarDayChanged)
            XCTAssertNil(letter.sender)
            XCTAssertEqual(objectKeys, Set([12, 13]))
            received += 1
        }

        ponyExpress.add(name: .NSCalendarDayChanged, recipient: graph)
        ponyExpress.post(name: .NSCalendarDayChanged, sender: nil, contents: .specificInfo(objectKeys: Set([12, 13])))
        XCTAssertEqual(received, 1)
    }

    func testExampleBlock() throws {
        let ponyExpress = PostOffice<UserInfo>()
        var received = 0

        ponyExpress.add(name: .NSCalendarDayChanged) { letter in
            guard case .specificInfo(let objectKeys) = letter.contents else {
                XCTFail()
                return
            }
            XCTAssertEqual(letter.name, .NSCalendarDayChanged)
            XCTAssertNil(letter.sender)
            XCTAssertEqual(objectKeys, Set([12, 13]))
            received += 1
        }
        ponyExpress.post(name: .NSCalendarDayChanged, sender: nil, contents: .specificInfo(objectKeys: Set([12, 13])))

        XCTAssertEqual(received, 1)
    }

    func testAsync() throws {
        let ponyExpress = PostOffice<UserInfo>()
        let queue = DispatchQueue(label: "any.queue")
        var received = 0
        let graph = TestObserver()
        graph.observe = { letter in
            guard case .specificInfo(let objectKeys) = letter.contents else {
                XCTFail()
                return
            }
            XCTAssertEqual(letter.name, .NSCalendarDayChanged)
            XCTAssertNil(letter.sender)
            XCTAssertEqual(objectKeys, Set([12, 13]))
            received += 1
        }

        ponyExpress.add(name: .NSCalendarDayChanged, queue: queue, recipient: graph)

        XCTAssertEqual(received, 0)

        ponyExpress.post(name: .NSCalendarDayChanged, sender: nil, contents: .specificInfo(objectKeys: Set([12, 13])))

        let exp = expectation(description: "wait for notification")
        queue.async {
            exp.fulfill()
        }
        wait(for: [exp], timeout: 0.1)

        XCTAssertEqual(received, 1)
    }

    func testAsyncBlock() throws {
        let ponyExpress = PostOffice<UserInfo>()
        let queue = DispatchQueue(label: "any.queue")
        var received = 0

        ponyExpress.add(name: .NSCalendarDayChanged, queue: queue) { letter in
            guard case .specificInfo(let objectKeys) = letter.contents else {
                XCTFail()
                return
            }
            XCTAssertEqual(letter.name, .NSCalendarDayChanged)
            XCTAssertNil(letter.sender)
            XCTAssertEqual(objectKeys, Set([12, 13]))
            received += 1
        }

        XCTAssertEqual(received, 0)

        ponyExpress.post(name: .NSCalendarDayChanged, sender: nil, contents: .specificInfo(objectKeys: Set([12, 13])))

        let exp = expectation(description: "wait for notification")
        queue.async {
            exp.fulfill()
        }
        wait(for: [exp], timeout: 0.1)

        XCTAssertEqual(received, 1)
    }

    func testSendingClosure() throws {
        let ponyExpress = PostOffice<UserInfo>()
        let queue = DispatchQueue(label: "any.queue")
        var received = 0

        func listener(_ letter: Letter<UserInfo>) {
            guard case .specificInfo(let objectKeys) = letter.contents else {
                XCTFail()
                return
            }
            XCTAssertEqual(letter.name, .NSCalendarDayChanged)
            XCTAssertNil(letter.sender)
            XCTAssertEqual(objectKeys, Set([12, 13]))
            received += 1
        }

        ponyExpress.add(name: .NSCalendarDayChanged, queue: queue, recipient: listener)

        XCTAssertEqual(received, 0)

        ponyExpress.post(name: .NSCalendarDayChanged, sender: nil, contents: .specificInfo(objectKeys: Set([12, 13])))

        let exp = expectation(description: "wait for notification")
        queue.async {
            exp.fulfill()
        }
        wait(for: [exp], timeout: 0.1)

        XCTAssertEqual(received, 1)
    }

    /// Instead of sending an `MailRecipient` as the `recipient`, a method or block that matches the `MailContents` can be sent instead.
    func testExampleWithMethod() throws {

        class TestObserverWithMethod {
            var observe: ((Letter<UserInfo>) -> Void)?

            func receive(_ mail: Letter<UserInfo>) {
                observe?(mail)
            }
        }

        let ponyExpress = PostOffice<UserInfo>()
        var received = 0
        let recipient = TestObserverWithMethod()

        recipient.observe = { _ in
            received += 1
        }

        ponyExpress.add(name: .NSCalendarDayChanged, recipient: recipient.receive)
        ponyExpress.post(name: .NSCalendarDayChanged, sender: nil, contents: .specificInfo(objectKeys: Set([12, 13])))
        XCTAssertEqual(received, 1)
    }
}
