//
//  File.swift
//  
//
//  Created by Adam Wulf on 8/27/22.
//

import Foundation
import PonyExpress

// Create a static shared PostOffice
private let globalShared = PostOffice<Int>()
public extension PostOffice {
    static var shared: PostOffice<Int> {
        return globalShared
    }
}

enum UserInfo {
    case specificInfo(objectKeys: Set<Int>)
}

class TestObserver: MailRecipient {
    typealias MailContents = UserInfo

    var observe: ((Letter<UserInfo>) -> Void)?

    func receive(mail: Letter<UserInfo>) {
        observe?(mail)
    }
}
