//
//  File.swift
//  
//
//  Created by Adam Wulf on 10/1/22.
//

import Foundation

public protocol Recipient<Letter> {
    associatedtype Letter: PonyExpress.Letter

    func receive(letter: Letter, sender: AnyObject?)
}

internal struct AnyRecipient {
    let block: (Letter, AnyObject?) -> Void

    init<U: Letter>(_ block: @escaping (_ letter: U, _ sender: AnyObject?) -> Void) {
        self.block = { notification, sender in
            guard let notification = notification as? U else { return }
            block(notification, sender)
        }
    }

    init<U: Letter>(_ recipient: any Recipient<U>) {
        self.block = { notification, sender in
            guard let notification = notification as? U else { return }
            recipient.receive(letter: notification, sender: sender)
        }
    }
}
