import XCTest
@testable import PonyExpress

final class MailTests: XCTestCase {

//    func testMatchSenderTypeOptional() throws {
//        struct ExampleMail: Mail {
//            var info: Int
//        }
//        struct ExamplePostmarked: PostMarked {
//            var info: Int
//        }
//
//        let sender = NSObject()
//        let postOffice = PostOffice()
//        var received = 0
//
//        postOffice.register { (_: ExampleMail) -> Void in
//            received += 1
//        }
//        postOffice.register { (_: ExamplePostmarked) -> Void in
//            received += 1
//        }
//
//        postOffice.post(ExamplePostmarked(info: 12), sender: sender)
//        postOffice.post(ExampleMail(info: 12))
//
//        // compiler error, Postmarked notifications that do not implement Mail /must/ be sent with a Sender
//        // postOffice.post(ExamplePostmarked(info: 12))
//        // postOffice.post(ExamplePostmarked(info: 12), sender: nil)
//        // let emptySender: NSObject? = nil
//        // postOffice.post(ExamplePostmarked(info: 12), sender: emptySender)
//
//        XCTAssertEqual(received, 2)
//    }
}
