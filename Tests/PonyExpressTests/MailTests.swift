import XCTest
@testable import PonyExpress

final class MailTests: XCTestCase {

    func testMatchSenderTypeOptional() throws {

        struct ExampleMail: Mail {
            var info: Int
        }
        struct ExamplePostmarked: PostMarked {
            var info: Int
        }

        let sender = NSObject()
        let postOffice = PostOffice()
        var received = 0

        postOffice.register { (_: ExampleMail) -> Void in
            received += 1
        }
        postOffice.register { (_: ExamplePostmarked) -> Void in
            received += 1
        }

        postOffice.post(ExamplePostmarked(info: 12), sender: sender)
        postOffice.post(ExampleMail(info: 12))
        XCTAssertEqual(received, 2)
    }
}
