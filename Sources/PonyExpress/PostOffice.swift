//
//  PostOffice.swift
//
//
//  Created by Adam Wulf on 08.27.22.
//
//

import Foundation
import Locks

public class PostOffice {

    static let `default` = PostOffice()

    private typealias RecipientContext = (recipient: AnyRecipient, queue: DispatchQueue?, sender: AnyObject?)

    private let lock = Mutex()
    private var listeners: [String: [RecipientContext]] = [:]

    public init() {
        // noop
    }

    public func register<U: Letter>(queue: DispatchQueue? = nil, sender: AnyObject? = nil, _ recipient: any Recipient<U>) {
        lock.lock()
        defer { lock.unlock() }
        listeners[U.name, default: []].append((recipient: AnyRecipient(recipient), queue: queue, sender: sender))
    }

    public func register<U: Letter>(queue: DispatchQueue? = nil, sender: AnyObject? = nil, _ recipient: @escaping (U, AnyObject?) -> Void) {
        lock.lock()
        defer { lock.unlock() }
        listeners[U.name, default: []].append((recipient: AnyRecipient(recipient), queue: queue, sender: sender))
    }

    public func register<U: Letter>(queue: DispatchQueue? = nil, sender: AnyObject? = nil, _ recipient: @escaping (U) -> Void) {
        register(queue: queue, sender: sender) { letter, _ in
            recipient(letter)
        }
    }

    public func post<U: Letter>(_ notification: U, sender: AnyObject? = nil) {
        lock.lock()
        guard let listeners = listeners[U.name] else {
            lock.unlock()
            return
        }
        lock.unlock()

        for listener in listeners {
            guard sender == nil || listener.sender == nil || listener.sender === sender else { continue }
            if let queue = listener.queue {
                queue.async {
                    listener.recipient.block(notification, sender)
                }
            } else {
                listener.recipient.block(notification, sender)
            }
        }
    }
}
