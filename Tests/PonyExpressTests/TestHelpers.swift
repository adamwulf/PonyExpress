//
//  File.swift
//  
//
//  Created by Adam Wulf on 8/27/22.
//

import Foundation
import PonyExpress

// Create a static shared PonyExpress
let globalShared = PonyExpress<Int>()
public extension PonyExpress {
    static var shared: PonyExpress<Int> {
        return globalShared
    }
}

enum UserInfo {
    case specificInfo(objectKeys: Set<Int>)
}

class TestObserver: PostOffice {
    typealias MailContents=UserInfo

    var observe: ((Letter<UserInfo>) -> Void)?

    func receive(mail: Letter<UserInfo>) {
        observe?(mail)
    }
}
