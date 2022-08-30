//
//  PonyExpress.swift
//
//
//  Created by Adam Wulf on 08.27.22.
//
//

import Foundation
import Locks

public class PonyExpress<T> {
    public typealias PostOfficeBlock = (Letter<T>) -> Void

    private enum Observer {
        case postOffice(_ postOffice: AnyPostOffice<T>, queue: DispatchQueue?)
        case block(_ block: PostOfficeBlock, queue: DispatchQueue?)
    }
    private let lock = Mutex()
    private var observers: [Notification.Name: [Observer]]

    public init() {
        // only allow a singleton
        observers = [:]
    }

    public func add<U: PostOffice>(name: Notification.Name, queue: DispatchQueue? = nil, observer: U) where U.MailContents == T {
        lock.lock()
        defer { lock.unlock() }
        var curr = observers[name] ?? []
        curr.append(.postOffice(AnyPostOffice(observer), queue: queue))
        observers[name] = curr
    }

    public func add(name: Notification.Name, queue: DispatchQueue? = nil, block: @escaping PostOfficeBlock) {
        lock.lock()
        defer { lock.unlock() }
        var curr = observers[name] ?? []
        curr.append(.block(block, queue: queue))
        observers[name] = curr
    }

    public func post(name: Notification.Name, sender: AnyObject? = nil, contents: T? = nil) {
        lock.lock()
        let toNotify = observers[name]
        lock.unlock()

        guard let toNotify = toNotify else { return }
        let letter = Letter(name: name, sender: sender, contents: contents)

        for observer in toNotify {
            switch observer {
            case .postOffice(let postOffice, let queue):
                if let queue = queue {
                    queue.async {
                        postOffice.receive(mail: letter)
                    }
                } else {
                    postOffice.receive(mail: letter)
                }
            case .block(let block, queue: let queue):
                if let queue = queue {
                    queue.async {
                        block(letter)
                    }
                } else {
                    block(letter)
                }
            }
        }
    }
}
