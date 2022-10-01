//
//  PostOffice.swift
//
//
//  Created by Adam Wulf on 08.27.22.
//
//

import Foundation
import Locks

protocol Letter {
    static var name: String { get }
}

extension Letter {
    static var name: String {
        return String(describing: Self.self)
    }
}

struct ExampleNotification: Letter {
    var info: Int
    var other: Float
}

public class PostOffice {
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
    private var listeners: [String: [(recipient: Recipient, queue: DispatchQueue?)]] = [:]

    public init() {
        // noop
    }

    func register<U: Letter>(queue: DispatchQueue? = nil, _ recipient: @escaping (U, AnyObject?) -> Void) {
        lock.lock()
        defer { lock.unlock() }
        listeners[U.name, default: []].append((recipient: Recipient(recipient), queue: queue))
    }

    func register<U: Letter>(queue: DispatchQueue? = nil, _ recipient: @escaping (U) -> Void) {
        register(queue: queue) { letter, _ in
            recipient(letter)
        }
    }

    func post<U: Letter>(_ notification: U, sender: AnyObject? = nil) {
        lock.lock()
        defer { lock.unlock() }
        guard let listeners = listeners[U.name] else { return }

        for listener in listeners {
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
