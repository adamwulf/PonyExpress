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
    public func register<U: Letter>(queue: DispatchQueue? = nil,
                                    sender: AnyObject? = nil,
                                    _ recipient: any Recipient<U>) -> RecipientId {
        lock.lock()
        defer { lock.unlock() }
        let context = RecipientContext(recipient: AnyRecipient(recipient), queue: queue, sender: sender)
        listeners[U.name, default: []].append(context)
        recipientToName[context.id] = U.name
        return context.id
    }

    @discardableResult
    public func register<U: Letter>(queue: DispatchQueue? = nil,
                                    sender: AnyObject? = nil,
                                    _ recipient: @escaping (U, AnyObject?) -> Void) -> RecipientId {
        lock.lock()
        defer { lock.unlock() }
        let context = RecipientContext(recipient: AnyRecipient(recipient), queue: queue, sender: sender)
        listeners[U.name, default: []].append(context)
        recipientToName[context.id] = U.name
        return context.id
    }

    @discardableResult
    public func register<U: Letter>(queue: DispatchQueue? = nil,
                                    sender: AnyObject? = nil,
                                    _ recipient: @escaping (U) -> Void) -> RecipientId {
        return register(queue: queue, sender: sender) { letter, _ in
            recipient(letter)
        }
    }

    public func register<T, U: Letter>(recipient: T, _ method: @escaping (T) -> (U, AnyObject?) -> Void) {

    }

    public func unregister(_ recipient: RecipientId) {
        lock.lock()
        defer { lock.unlock() }
        guard let name = recipientToName.removeValue(forKey: recipient) else { return }
        listeners[name]?.removeAll(where: { $0.id == recipient })
    }

    public func post<U: Letter>(_ notification: U, sender: AnyObject? = nil) {
        lock.lock()
        guard let listeners = listeners[U.name] else {
            lock.unlock()
            return
        }
        self.listeners[U.name] = listeners.filter({ !$0.recipient.canCollect })
        lock.unlock()

        for listener in listeners {
            guard sender == nil || listener.sender == nil || listener.sender === sender else { continue }
            if let queue = listener.queue {
                queue.async {
                    listener.recipient.block?(notification, sender)
                }
            } else {
                listener.recipient.block?(notification, sender)
            }
        }
    }
}
