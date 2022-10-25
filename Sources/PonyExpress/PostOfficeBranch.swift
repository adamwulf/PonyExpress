//
//  PostOfficeBranch.swift
//  
//
//  Created by Adam Wulf on 10/16/22.
//

import Foundation

/// Just like a ``PostOffice`` but also able to limit the types of posts and senders using generic types
/// - note: All notifications sent through this `PostOfficeBranch` must conform to `Notification`,
/// and all senders using this `PostOfficeBranch` must conform to `Sender`.
///
/// Define a `PostOfficeBranch` to more narrowly define what types of notifications can be sent from
/// specific types of senders. While observers are strictly typed in ``PostOffice``, the sent notifications
/// and senders are not type constrained. Using a `PostOfficeBranch` can add constraints to the
/// notifications and senders, which helps prevent sending incorrect notification objects or senders due to
/// typos or other common coding mistakes.
///
/// ```swift
/// let myBranch = PostOfficeBranch<MySpecificEvents, MySender>()
/// ```
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
