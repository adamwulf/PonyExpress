//
//  File.swift
//  
//
//  Created by Adam Wulf on 10/1/22.
//

import Foundation

internal class AnyRecipient {
    var block: ((Any, AnyObject?) -> Void)?
    private let _canCollect: () -> Bool
    var canCollect: Bool {
        return _canCollect()
    }

    init<U, S: AnyObject>(_ block: @escaping (_ letter: U, _ sender: S?) -> Void) {
        _canCollect = { return false }
        self.block = { letter, sender in
            guard let letter = letter as? U else { return }
            if sender == nil {
                block(letter, nil)
            } else if sender != nil,
                      let sender = sender as? S {
                block(letter, sender)
            }
        }
    }

    init<T: AnyObject, U, S: AnyObject>(_ recipient: T, _ method: @escaping (T) -> (_ letter: U, _ sender: S?) -> Void) {
        weak var weakRecipient = recipient
        _canCollect = {
            guard let _ = weakRecipient else { return true }
            return false
        }
        self.block = { letter, sender in
            guard let strongRecipient = weakRecipient else { return }
            guard let letter = letter as? U else { return }
            if sender == nil {
                method(strongRecipient)(letter, nil)
            } else if sender != nil,
                      let sender = sender as? S {
                method(strongRecipient)(letter, sender)
            }
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
