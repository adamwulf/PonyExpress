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
    private let lock = Mutex()
    private var observers: [Notification.Name: [AnyPostOffice<T>]]

    public init() {
        // only allow a singleton
        observers = [:]
    }

    public func add<U: PostOffice>(name: Notification.Name, observer: U) where U.MailContents == T {
        lock.lock()
        defer { lock.unlock() }
        var curr = observers[name] ?? []
        curr.append(AnyPostOffice(observer))
        observers[name] = curr
    }

    public func post(name: Notification.Name, sender: AnyObject? = nil, contents: T? = nil) {
        lock.lock()
        let toNotify = observers[name]
        lock.unlock()

        toNotify?.forEach({ office in
            office.receive(mail: Letter(name: name, sender: sender, contents: contents))
        })
    }
}
