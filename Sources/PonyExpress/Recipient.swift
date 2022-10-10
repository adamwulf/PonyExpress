//
//  File.swift
//  
//
//  Created by Adam Wulf on 10/1/22.
//

import Foundation

internal protocol Recipient<Letter>: AnyObject {
    associatedtype Letter

    func receive(letter: Letter, sender: AnyObject?)
}

internal class AnyRecipient {
    var block: ((Any, AnyObject?) -> Void)?
    private let _canCollect: () -> Bool
    var canCollect: Bool {
        return _canCollect()
    }

    init<U>(_ block: @escaping (_ letter: U, _ sender: AnyObject?) -> Void) {
        _canCollect = { return false }
        self.block = { letter, sender in
            guard let letter = letter as? U else { return }
            block(letter, sender)
        }
    }

    init<U>(_ recipient: any Recipient<U>) {
        weak var weakRecipient = recipient
        _canCollect = {
            guard let _ = weakRecipient else { return true }
            return false
        }
        self.block = { letter, sender in
            guard let strongRecipient = weakRecipient else { return }
            guard let letter = letter as? U else { return }
            strongRecipient.receive(letter: letter, sender: sender)
        }
    }

    init<T: AnyObject, U>(_ recipient: T, _ method: @escaping (T) -> (_ letter: U, _ sender: AnyObject?) -> Void) {
        weak var weakRecipient = recipient
        _canCollect = {
            guard let _ = weakRecipient else { return true }
            return false
        }
        self.block = { letter, sender in
            guard let strongRecipient = weakRecipient else { return }
            guard let letter = letter as? U else { return }
            method(strongRecipient)(letter, sender)
        }
    }

    init<T: AnyObject, U>(_ recipient: T, _ method: @escaping (T) -> (_ letter: U) -> Void) {
        weak var weakRecipient = recipient
        _canCollect = {
            guard let _ = weakRecipient else { return true }
            return false
        }
        self.block = { letter, _ in
            guard let strongRecipient = weakRecipient else { return }
            guard let letter = letter as? U else { return }
            method(strongRecipient)(letter)
        }
    }
}
