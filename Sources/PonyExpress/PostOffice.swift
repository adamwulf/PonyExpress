//
//  PostOffice.swift
//
//
//  Created by Adam Wulf on 08.27.22.
//
//

import Foundation
import Locks

public struct RecipientId: Hashable {
    static var nextIdentifier: UInt = 0

    let value: UInt

    init() {
        self.value = Self.nextIdentifier
        Self.nextIdentifier += 1
    }
}

public class PostOffice {

    static let `default` = PostOffice()

    private static func name<T>(for type: T.Type) -> String {
        // build a string to represent the Type. This will be something like "ExampleClass.Type"
        return String(describing: Mirror(reflecting: type).subjectType)
    }

    /// Using a Mirror of the object, create a Mirror for each type in its ancestry and build names from those types
    private static func names<T>(for object: T) -> [String] {
        var ret: [String] = []
        // get a mirror of the object, if we use this Mirror to build a String, it would be "ExampleClass"
        var mirror: Mirror? = Mirror(reflecting: object)
        while let concrete = mirror {
            // we need to build Mirrors for the /type/, not for the object itself
            // This will build a string for the type like "ExampleClass.Type"
            let name = String(describing: Mirror(reflecting: concrete.subjectType).subjectType)
            ret.append(name)
            // now iterate up the parent class chain and repeat until we're done
            mirror = concrete.superclassMirror
        }
        return ret
    }

    private struct RecipientContext {
        let recipient: AnyRecipient
        let queue: DispatchQueue?
        let sender: AnyObject?
        let id: RecipientId

        init(recipient: AnyRecipient, queue: DispatchQueue?, sender: AnyObject?) {
            self.recipient = recipient
            self.queue = queue
            self.sender = sender
            self.id = RecipientId()
        }
    }

    private let lock = Mutex()
    private var listeners: [String: [RecipientContext]] = [:]
    private var recipientToName: [RecipientId: String] = [:]

    public var count: Int {
        lock.lock()
        defer { lock.unlock() }
        return listeners.reduce(0, { $0 + $1.value.count })
    }

    public init() {
        // noop
    }

    @discardableResult
    public func register<T: AnyObject, U, S: AnyObject>(queue: DispatchQueue? = nil,
                                          sender: S? = nil,
                                          _ recipient: T,
                                          _ method: @escaping (T) -> (U, S?) -> Void) -> RecipientId {
        lock.lock()
        defer { lock.unlock() }
        let name = Self.name(for: U.self)
        let context = RecipientContext(recipient: AnyRecipient(recipient, method), queue: queue, sender: sender)
        listeners[name, default: []].append(context)
        recipientToName[context.id] = name
        return context.id
    }

    @discardableResult
    public func register<T: AnyObject, U, S: AnyObject>(queue: DispatchQueue? = nil,
                                          sender: S? = nil,
                                          _ recipient: T,
                                          _ method: @escaping (T) -> (U, S) -> Void) -> RecipientId {
        lock.lock()
        defer { lock.unlock() }
        let name = Self.name(for: U.self)
        let context = RecipientContext(recipient: AnyRecipient(recipient, method), queue: queue, sender: sender)
        listeners[name, default: []].append(context)
        recipientToName[context.id] = name
        return context.id
    }

    // MARK: - Register Method Without Sender

    @discardableResult
    public func register<T: AnyObject, U, S: AnyObject>(queue: DispatchQueue? = nil,
                                          sender: S?,
                                          _ recipient: T,
                                          _ method: @escaping (T) -> (U) -> Void) -> RecipientId {
        lock.lock()
        defer { lock.unlock() }
        let name = Self.name(for: U.self)
        let context = RecipientContext(recipient: AnyRecipient(recipient, method), queue: queue, sender: sender)
        listeners[name, default: []].append(context)
        recipientToName[context.id] = name
        return context.id
    }

    @discardableResult
    public func register<T: AnyObject, U>(queue: DispatchQueue? = nil,
                                          _ recipient: T,
                                          _ method: @escaping (T) -> (U) -> Void) -> RecipientId {
        lock.lock()
        defer { lock.unlock() }
        let sender: AnyObject? = nil
        let name = Self.name(for: U.self)
        let context = RecipientContext(recipient: AnyRecipient(recipient, method), queue: queue, sender: sender)
        listeners[name, default: []].append(context)
        recipientToName[context.id] = name
        return context.id
    }

    // MARK: - Register Block With Sender

    /// Register a block for the object and sender as parameters
    ///
    /// ```
    /// PostOffice.default.register { letter, sender in ... }
    /// ```
    @discardableResult
    public func register<U, S: AnyObject>(queue: DispatchQueue? = nil,
                            sender: S? = nil,
                            _ block: @escaping (U, S?) -> Void) -> RecipientId {
        lock.lock()
        defer { lock.unlock() }
        let name = Self.name(for: U.self)
        let context = RecipientContext(recipient: AnyRecipient(block), queue: queue, sender: sender)
        listeners[name, default: []].append(context)
        recipientToName[context.id] = name
        return context.id
    }

    /// Register a block for the object and sender as parameters
    ///
    /// ```
    /// PostOffice.default.register { letter, sender in ... }
    /// ```
    @discardableResult
    public func register<U, S: AnyObject>(queue: DispatchQueue? = nil,
                            sender: S? = nil,
                            _ block: @escaping (U, S) -> Void) -> RecipientId {
        lock.lock()
        defer { lock.unlock() }
        let name = Self.name(for: U.self)
        let optBlock = { (note: U, sender: S?) in
            guard let sender = sender else { return }
            block(note, sender)
        }
        let context = RecipientContext(recipient: AnyRecipient(optBlock), queue: queue, sender: sender)
        listeners[name, default: []].append(context)
        recipientToName[context.id] = name
        return context.id
    }

    // MARK: - Register Block Without Sender

    /// Register a block with the object as the single parameter:
    ///
    /// ```
    /// PostOffice.default.register { (letter: ExampleLetter) in ... }
    /// ```
    @discardableResult
    public func register<U, S: AnyObject>(queue: DispatchQueue? = nil,
                            sender: S?,
                            _ block: @escaping (U) -> Void) -> RecipientId {
        return register(queue: queue, sender: sender) { (letter: U, _: S?) in
            block(letter)
        }
    }

    /// Register a block with the object as the single parameter:
    ///
    /// ```
    /// PostOffice.default.register { (letter: ExampleLetter) in ... }
    /// ```
    @discardableResult
    public func register<U>(queue: DispatchQueue? = nil,
                            _ block: @escaping (U) -> Void) -> RecipientId {
        let anySender: AnyObject? = nil
        return register(queue: queue, sender: anySender) { letter in
            block(letter)
        }
    }

    // MARK: - Unregister

    public func unregister(_ recipient: RecipientId) {
        lock.lock()
        defer { lock.unlock() }
        guard let name = recipientToName.removeValue(forKey: recipient) else { return }
        listeners[name]?.removeAll(where: { $0.id == recipient })
    }

    public func post<U>(_ letter: U) {
        let names = Self.names(for: letter)
        lock.lock()
        var allListeners: [RecipientContext] = []
        for name in names {
            if let typeListeners = listeners[name] {
                allListeners.append(contentsOf: typeListeners)
                listeners[name] = typeListeners.filter({ !$0.recipient.canCollect })
            }
        }
        guard !allListeners.isEmpty else {
            lock.unlock()
            return
        }
        lock.unlock()

        for listener in allListeners {
            guard listener.sender == nil else { continue }
            if let queue = listener.queue {
                queue.async {
                    listener.recipient.block?(letter, nil)
                }
            } else {
                listener.recipient.block?(letter, nil)
            }
        }
    }

    public func post<U, S: AnyObject>(_ letter: U, sender: S? = nil) {
        let names = Self.names(for: letter)
        lock.lock()
        var allListeners: [RecipientContext] = []
        for name in names {
            if let typeListeners = listeners[name] {
                allListeners.append(contentsOf: typeListeners)
                listeners[name] = typeListeners.filter({ !$0.recipient.canCollect })
            }
        }
        guard !allListeners.isEmpty else {
            lock.unlock()
            return
        }
        lock.unlock()

        for listener in allListeners {
            guard listener.sender == nil || listener.sender === sender else { continue }
            if let queue = listener.queue {
                queue.async {
                    listener.recipient.block?(letter, sender)
                }
            } else {
                listener.recipient.block?(letter, sender)
            }
        }
    }
}
