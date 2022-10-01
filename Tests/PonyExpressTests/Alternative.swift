import XCTest
@testable import PonyExpress

final class AltPonyExpressTests: XCTestCase {

    var postOffice: PostOffice2?

    override func setUp() async throws {
        postOffice = PostOffice2()
    }

    func testExample() throws {
        var count = 0
        func museContextCommitted(_ note: MuseContextCommitted) {
            count += 1
        }

        postOffice?.add(listener: museContextCommitted)

        postOffice?.notify(MuseContextCommitted(scopes: [12]))
    }
}

protocol Notification {
    static var name: String { get }
}

extension Notification {
    static var name: String {
        return String(describing: Self.self)
    }
}

struct MuseContextCommitted: Notification {
    var scopes: [Int]
}

struct Listener {
    let block: (Notification) -> Void

    init<U: Notification>(_ block: @escaping (U) -> Void) {
        self.block = { notification in
            guard let notification = notification as? U else { return }
            block(notification)
        }
    }
}

class PostOffice2 {
    var listeners: [String: [Listener]] = [:]

    func add<U: Notification>(listener: @escaping (U) -> Void) {
        listeners[U.name, default: []].append(Listener(listener))
    }

    func notify<U: Notification>(_ notification: U) {
        listeners[U.name]?.forEach({ $0.block(notification) })
    }
}

class Example {

}
