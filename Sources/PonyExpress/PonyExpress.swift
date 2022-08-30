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
    private struct Observer {
        let postOffice: AnyPostOffice<T>
        let queue: DispatchQueue?
    }
    private let lock = Mutex()
    private var observers: [Notification.Name: [Observer]]

    public init() {
        // only allow a singleton
        observers = [:]
    }

    public func add<U: PostOffice>(name: Notification.Name, observer: U, queue: DispatchQueue? = nil) where U.MailContents == T {
        lock.lock()
        defer { lock.unlock() }
        var curr = observers[name] ?? []
        curr.append(Observer(postOffice: AnyPostOffice(observer), queue: queue))
        observers[name] = curr
    }

    public func post(name: Notification.Name, sender: AnyObject? = nil, contents: T? = nil) {
        lock.lock()
        let toNotify = observers[name]
        lock.unlock()

        toNotify?.forEach({ observer in
            if let queue = observer.queue {
                queue.async {
                    observer.postOffice.receive(mail: Letter(name: name, sender: sender, contents: contents))
                }
            } else {
                observer.postOffice.receive(mail: Letter(name: name, sender: sender, contents: contents))
            }
        })
    }
}
