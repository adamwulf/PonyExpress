//
//  File.swift
//  
//
//  Created by Adam Wulf on 8/27/22.
//

import Foundation

class AnyPostOffice<Contents>: PostOffice {
    typealias MailContents = Contents
    let receive: (Letter<Contents>) -> Void
    let checkEmpty: () -> Bool

    init<U: PostOffice>(_ postOffice: U) where U.MailContents == Contents {
        receive = { [weak postOffice] letter in
            postOffice?.receive(mail: letter)
        }
        checkEmpty = { [weak postOffice] in
            return postOffice == nil
        }
    }

    func receive(mail: Letter<Contents>) {
        self.receive(mail)
    }

    var isEmpty: Bool {
        return self.checkEmpty()
    }
}
