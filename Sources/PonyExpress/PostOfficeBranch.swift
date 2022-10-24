//
//  PostOfficeBranch.swift
//  
//
//  Created by Adam Wulf on 10/16/22.
//

import Foundation

/// Just like a ``PostOffice`` but also able to limit the types of posts and senders using generic types
public class PostOfficeBranch<Notification, Sender: AnyObject> {
    /// The ``PostOffice`` used to send the posts
    private let mainBranch = PostOffice()

    // MARK: - Register Method with Sender

    @discardableResult
    public func register<T: AnyObject>(queue: DispatchQueue? = nil,
                                       sender: Sender? = nil,
                                       _ recipient: T,
                                       _ method: @escaping (T) -> (Notification, Sender?) -> Void) -> RecipientId {
        mainBranch.register(queue: queue, sender: sender, recipient, method)
    }

    @discardableResult
    public func register<T: AnyObject>(queue: DispatchQueue? = nil,
                                       sender: Sender? = nil,
                                       _ recipient: T,
                                       _ method: @escaping (T) -> (Notification, Sender) -> Void) -> RecipientId {
        mainBranch.register(queue: queue, sender: sender, recipient, method)
    }

    // MARK: - Register Method without Sender

    @discardableResult
    public func register<T: AnyObject>(queue: DispatchQueue? = nil,
                                       sender: Sender,
                                       _ recipient: T,
                                       _ method: @escaping (T) -> (Notification) -> Void) -> RecipientId {
        mainBranch.register(queue: queue, sender: sender, recipient, method)
    }

    @discardableResult
    public func register<T: AnyObject>(queue: DispatchQueue? = nil,
                                       _ recipient: T,
                                       _ method: @escaping (T) -> (Notification) -> Void) -> RecipientId {
        mainBranch.register(queue: queue, recipient, method)
    }

    // MARK: - Register Block with Sender

    @discardableResult
    public func register(queue: DispatchQueue? = nil,
                         sender: Sender? = nil,
                         _ block: @escaping (Notification, Sender?) -> Void) -> RecipientId {
        mainBranch.register(queue: queue, sender: sender, block)
    }

    @discardableResult
    public func register(queue: DispatchQueue? = nil,
                         sender: Sender? = nil,
                         _ block: @escaping (Notification, Sender) -> Void) -> RecipientId {
        mainBranch.register(queue: queue, sender: sender, block)
    }

    // MARK: - Register Block without Sender

    /// Register a block with the object as the single parameter:
    ///
    /// ```
    /// PostOffice.default.register { (notification: MyNotification) in ... }
    /// ```
    @discardableResult
    public func register(queue: DispatchQueue? = nil,
                         sender: Sender?,
                         _ block: @escaping (Notification) -> Void) -> RecipientId {
        mainBranch.register(queue: queue, sender: sender, block)
    }

    /// Register a block with the object as the single parameter:
    ///
    /// ```
    /// PostOffice.default.register { (notification: ExampleNotification) in ... }
    /// ```
    @discardableResult
    public func register(queue: DispatchQueue? = nil,
                         _ block: @escaping (Notification) -> Void) -> RecipientId {
        mainBranch.register(queue: queue, block)
    }

    // MARK: - Unregister

    public func unregister(_ recipient: RecipientId) {
        mainBranch.unregister(recipient)
    }

    // MARK: - Post

    public func post(_ notification: Notification) {
        mainBranch.post(notification)
    }

    public func post(_ notification: Notification, sender: Sender? = nil) {
        mainBranch.post(notification, sender: sender)
    }
}
