//
//  PostOffice.swift
//
//
//  Created by Adam Wulf on 08.27.22.
//
//

import Foundation
import Locks

/// Register `MailRecipient`s with the `PostOffice` to receive `Letter`s when they are posted.
public class PostOffice<Contents> {
    /// A block that can receive a `Letter`
    public typealias PostOfficeBlock = (Letter<Contents>) -> Void

    private enum Observer {
        case postOffice(_ postOffice: any MailRecipient<Contents>, queue: DispatchQueue?)
        case block(_ block: PostOfficeBlock, queue: DispatchQueue?)
    }
    private let lock = Mutex()
    private var observers: [Notification.Name: [Observer]]

    /// Create a new `PostOffice` for a particular `Letter` type.
    ///
    /// The following code will create a `PostOffice` that can post `Int`s as the contents of the `Letter`
    /// ```
    /// let ponyExpress = PostOffice<Int>()
    /// ```
    public init() {
        // only allow a singleton
        observers = [:]
    }

    /// Add a `MailRecipient` to receive letters for the given `Notification.Name`.
    /// - parameter name: The name of the `Letter` to receive.
    /// - parameter queue: The optional queue to receive the `Letter` when posted. If `nil`, then the `Letter` will arrive on the same thread that posted it.
    /// - parameter observer: The `MailRecipient` that will receive the `Letter` when it is posted.
    public func add<U: MailRecipient>(name: Notification.Name, queue: DispatchQueue? = nil, recipient: U) where U.MailContents == Contents {
        lock.lock()
        defer { lock.unlock() }
        var curr = observers[name] ?? []
        curr.append(.postOffice(recipient, queue: queue))
        observers[name] = curr
    }

    /// Add a `PostOfficeBlock` to receive letters for the given `Notification.Name`
    /// - parameter name: The name of the `Letter` to receive.
    /// - parameter queue: Optional. The queue to receive the `Letter` when posted. If `nil`, then the `Letter` will arrive on the same thread that posted it.
    /// - parameter block: The `PostOfficeBlock` that will receive the `Letter` when it is posted.
    public func add(name: Notification.Name, queue: DispatchQueue? = nil, recipient: @escaping PostOfficeBlock) {
        lock.lock()
        defer { lock.unlock() }
        var curr = observers[name] ?? []
        curr.append(.block(recipient, queue: queue))
        observers[name] = curr
    }

    /// Posts a `Letter` to all `PostOffice`s that have registered to observer the input `name`.
    /// - parameter name: The name of the `Letter` to receive.
    /// - parameter sender: Optional. The objct that is sending the `Letter`.
    /// - parameter contents: Optional. The contents of the `Letter` being posted.
    public func post(name: Notification.Name, sender: AnyObject? = nil, contents: Contents? = nil) {
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
