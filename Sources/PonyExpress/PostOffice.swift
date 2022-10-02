//
//  PostOffice.swift
//
//
//  Created by Adam Wulf on 08.27.22.
//
//

import Foundation
import Locks

public protocol Letter {
    static var name: String { get }
}

public extension Letter {
    static var name: String {
        return String(describing: Self.self)
    }
}

public struct Package<T>: Letter {
    public let contents: T
}

public class PostOffice {

    static let `default` = PostOffice()

    private typealias RecipientContext = (recipient: Recipient, queue: DispatchQueue?, sender: AnyObject?)

    private struct Recipient {
        let block: (Letter, AnyObject?) -> Void

        init<U: Letter>(_ block: @escaping (_ letter: U, _ sender: AnyObject?) -> Void) {
            self.block = { notification, sender in
                guard let notification = notification as? U else { return }
                block(notification, sender)
            }
        }
    }

    private let lock = Mutex()
    private var listeners: [String: [RecipientContext]] = [:]

    public init() {
        // noop
    }

    public func register<U: Letter>(queue: DispatchQueue? = nil, sender: AnyObject? = nil, _ recipient: @escaping (U, AnyObject?) -> Void) {
        lock.lock()
        defer { lock.unlock() }
        listeners[U.name, default: []].append((recipient: Recipient(recipient), queue: queue, sender: sender))
    }

    public func register<U: Letter>(queue: DispatchQueue? = nil, sender: AnyObject? = nil, _ recipient: @escaping (U) -> Void) {
        register(queue: queue, sender: sender) { letter, _ in
            recipient(letter)
        }
    }

    public func post<U: Letter>(_ notification: U, sender: AnyObject? = nil) {
        lock.lock()
        defer { lock.unlock() }
        guard let listeners = listeners[U.name] else { return }

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
