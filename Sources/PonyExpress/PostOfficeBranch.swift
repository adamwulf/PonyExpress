//
//  PostOfficeBranch.swift
//  
//
//  Created by Adam Wulf on 10/16/22.
//

import Foundation

/// Just like a ``PostOffice`` but also able to limit the types of posts and senders.
class PostOfficeBranch<Letter, Sender: AnyObject> {
    /// The ``PostOffice`` used to send the posts
    private let mainBranch = PostOffice()

    // MARK: - Register Method with Sender

    @discardableResult
    public func register<T: AnyObject>(queue: DispatchQueue? = nil,
                                       sender: Sender? = nil,
                                       _ recipient: T,
                                       _ method: @escaping (T) -> (Letter, Sender?) -> Void) -> RecipientId {
        mainBranch.register(queue: queue, sender: sender, recipient, method)
    }

    @discardableResult
    public func register<T: AnyObject>(queue: DispatchQueue? = nil,
                                       sender: Sender? = nil,
                                       _ recipient: T,
                                       _ method: @escaping (T) -> (Letter, Sender) -> Void) -> RecipientId {
        mainBranch.register(queue: queue, sender: sender, recipient, method)
    }

    // MARK: - Register Method without Sender

    @discardableResult
    public func register<T: AnyObject>(queue: DispatchQueue? = nil,
                                       sender: Sender?,
                                       _ recipient: T,
                                       _ method: @escaping (T) -> (Letter) -> Void) -> RecipientId {
        mainBranch.register(queue: queue, sender: sender, recipient, method)
    }

    @discardableResult
    public func register<T: AnyObject>(queue: DispatchQueue? = nil,
                                       _ recipient: T,
                                       _ method: @escaping (T) -> (Letter) -> Void) -> RecipientId {
        mainBranch.register(queue: queue, recipient, method)
    }

    // MARK: - Register Block with Sender

    @discardableResult
    public func register(queue: DispatchQueue? = nil,
                         sender: Sender? = nil,
                         _ block: @escaping (Letter, Sender?) -> Void) -> RecipientId {
        mainBranch.register(queue: queue, sender: sender, block)
    }

    @discardableResult
    public func register(queue: DispatchQueue? = nil,
                         sender: Sender? = nil,
                         _ block: @escaping (Letter, Sender) -> Void) -> RecipientId {
        mainBranch.register(queue: queue, sender: sender, block)
    }

    // MARK: - Register Block without Sender

    /// Register a block with the object as the single parameter:
    ///
    /// ```
    /// PostOffice.default.register { (letter: MyNotification) in ... }
    /// ```
    @discardableResult
    public func register(queue: DispatchQueue? = nil,
                         sender: Sender?,
                         _ block: @escaping (Letter) -> Void) -> RecipientId {
        mainBranch.register(queue: queue, sender: sender, block)
    }

    /// Register a block with the object as the single parameter:
    ///
    /// ```
    /// PostOffice.default.register { (letter: ExampleLetter) in ... }
    /// ```
    @discardableResult
    public func register(queue: DispatchQueue? = nil,
                         _ block: @escaping (Letter) -> Void) -> RecipientId {
        mainBranch.register(queue: queue, block)
    }

    // MARK: - Unregister

    public func unregister(_ recipient: RecipientId) {
        mainBranch.unregister(recipient)
    }

    // MARK: - Post

    public func post(_ letter: Letter) {
        mainBranch.post(letter)
    }

    public func post(_ letter: Letter, sender: Sender? = nil) {
        mainBranch.post(letter, sender: sender)
    }
}
