//
//  File.swift
//
//
//  Created by Adam Wulf on 10/1/22.
//

import Foundation
import Locks

/// An opaque value that represents a specific recipient registered at a ``PostOffice``.
/// - SeeAlso: ``PostOffice/unregister(_:)``
public struct RecipientId: Hashable {
    @Atomic static var nextIdentifier: UInt = 0

    let value: UInt

    init() {
        self.value = Self.nextIdentifier
        Self.nextIdentifier += 1
    }
}

internal class AnyRecipient {
    var block: ((Any, AnyObject?) -> Void)?
    private let _canCollect: () -> Bool
    var canCollect: Bool {
        return _canCollect()
    }
    private var matchesObject: ((AnyObject) -> Bool)

    func matches(_ anObject: AnyObject) -> Bool {
        return matchesObject(anObject)
    }

    init<U, S: AnyObject>(_ block: @escaping (_ notification: U, _ sender: S?) -> Void) {
        _canCollect = { return false }
        self.matchesObject = { _ in return false }
        self.block = { notification, sender in
            guard let notification = notification as? U else { return }
            if sender == nil {
                block(notification, nil)
            } else if sender != nil,
                      let sender = sender as? S {
                block(notification, sender)
            }
        }
    }

    init<T: AnyObject, U, S: AnyObject>(_ recipient: T, _ method: @escaping (T) -> (_ notification: U, _ sender: S?) -> Void) {
        weak var weakRecipient = recipient
        _canCollect = {
            guard weakRecipient != nil else { return true }
            return false
        }
        self.matchesObject = { obj in weakRecipient === obj }
        self.block = { notification, sender in
            guard let strongRecipient = weakRecipient else { return }
            guard let notification = notification as? U else { return }
            if sender == nil {
                method(strongRecipient)(notification, nil)
            } else if sender != nil,
                      let sender = sender as? S {
                method(strongRecipient)(notification, sender)
            }
        }
    }

    init<T: AnyObject, U, S: AnyObject>(_ recipient: T, _ method: @escaping (T) -> (_ notification: U, _ sender: S) -> Void) {
        weak var weakRecipient = recipient
        _canCollect = {
            guard weakRecipient != nil else { return true }
            return false
        }
        self.matchesObject = { obj in weakRecipient === obj }
        self.block = { notification, sender in
            guard let strongRecipient = weakRecipient else { return }
            guard let notification = notification as? U else { return }
            if let sender = sender as? S {
                method(strongRecipient)(notification, sender)
            }
        }
    }

    init<T: AnyObject, U>(_ recipient: T, _ method: @escaping (T) -> (_ notification: U) -> Void) {
        weak var weakRecipient = recipient
        _canCollect = {
            guard weakRecipient != nil else { return true }
            return false
        }
        self.matchesObject = { obj in weakRecipient === obj }
        self.block = { notification, _ in
            guard let strongRecipient = weakRecipient else { return }
            guard let notification = notification as? U else { return }
            method(strongRecipient)(notification)
        }
    }

    init<T: AnyObject, U>(_ recipient: T, _ notification: U.Type, _ method: @escaping (T) -> () -> Void) {
        weak var weakRecipient = recipient
        _canCollect = {
            guard weakRecipient != nil else { return true }
            return false
        }
        self.matchesObject = { obj in weakRecipient === obj }
        self.block = { notification, _ in
            guard let strongRecipient = weakRecipient else { return }
            guard notification as? U != nil else { return }
            method(strongRecipient)()
        }
    }
}
