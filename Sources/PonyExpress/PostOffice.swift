//
//  PostOffice.swift
//
//
//  Created by Adam Wulf on 08.27.22.
//

import Foundation
import Locks

/// A `PostOffice` is able to send strongly-typed notifications from any strongly-typed sender, and will
/// relay them to all registered recipients appropriately.
///
/// A ``default`` `PostOffice` is provided. To send a notification:
///
/// ```swift
/// PostOffice.default.post(yourNotification, sender: yourSender)
/// ```
public class PostOffice {

    // MARK: - Public

    /// A default `PostOffice`, akin to `NotificationCenter.default`.
    public static let `default` = PostOffice()

    // MARK: - Internal

    /// The number of listeners for all registered types. Used for testing only.
    internal var count: Int {
        lock.lock()
        defer { lock.unlock() }
        return listeners.reduce(0, { $0 + $1.value.count })
    }

    // MARK: - Private

    /// A key to help cache recipients into `listeners`. This provides a hashable value for an arbitrary swift type
    /// and also provides an easy method to test if any object matches a type. This helps all recipients for a specific
    /// type to be grouped together in `listeners`, and for any notification object to be quickly tested to see which
    /// groups of recipients should be notified.
    private struct Key: Hashable {
        let name: String
        let test: (Any) -> Bool

        static func == (lhs: PostOffice.Key, rhs: PostOffice.Key) -> Bool {
            return lhs.name == rhs.name
        }
        func hash(into hasher: inout Hasher) {
            hasher.combine(name)
        }

        static func key<T>(for type: T.Type) -> Key {
            return Key(name: String(describing: type),
                       test: { obj in
                return obj is T
            })
        }
    }

    /// Storage to keep the recipient and all of its metadata conveniently linked
    private struct RecipientContext {
        let recipient: AnyRecipient
        let queue: DispatchQueue?
        weak var sender: AnyObject?
        let requiresSender: Bool
        let id: RecipientId

        init(recipient: AnyRecipient, queue: DispatchQueue?, sender: AnyObject?) {
            self.recipient = recipient
            self.queue = queue
            self.sender = sender
            self.requiresSender = sender != nil
            self.id = RecipientId()
        }
    }

    private let lock = Mutex()
    private var listeners: [Key: [RecipientContext]] = [:]
    private var recipientToKey: [RecipientId: Key] = [:]

    // MARK: - Initializer

    /// A default `PostOffice` is already provided at `PostOffice.default`. If more than one `PostOffice` is required,
    /// one can be built with `PostOffice()`.
    public init() {
        // noop
    }

    // MARK: - Unregister

    /// Stops any future notifications from being sent to the recipient method or block that was registered with this ``RecipientId``.
    /// - parameter recipient: The ``RecipientId`` that was returned from a registration method.
    public func unregister(_ recipient: RecipientId) {
        lock.lock()
        defer { lock.unlock() }
        guard let name = recipientToKey.removeValue(forKey: recipient) else { return }
        listeners[name]?.removeAll(where: { $0.id == recipient })
    }

    /// Stops any future notifications from being sent to the `recipient`.
    /// - parameter recipient: The recipient object registered through ``register(queue:sender:_:_:)`` or related methods
    public func unregister<T: AnyObject>(_ recipient: T) {
        lock.lock()
        defer { lock.unlock() }
        for key in listeners.keys {
            listeners[key] = listeners[key]?.excluding({ $0.recipient.matches(recipient) })
        }
    }

    // MARK: - Register Postmarked Methods

    /// Register a recipient and method with the `PostOffice`. This method will be called if both the posted notification
    /// and `sender` match the method's parameter's type.
    ///
    /// - parameter queue: The recipient will always receive posts on this queue. If `nil`, then the post will be made
    /// on the queue of the sender.
    /// - parameter sender: Optional. Ignored if `nil`, otherwise will limit the received notifications to only those sent by the `sender`.
    /// This sender must match the `RequiredSender` of the notification type. The `sender` is held weakly.
    /// - parameter recipient: The object that will receive the posted ``PostMarked``.
    /// - parameter method: The method of the `recipient` that will be called with the posted notification. Its two arguments
    /// include the notification, and a required `sender`. The method will only be called if both the notification and `sender`
    /// types match.
    /// - returns: A ``RecipientId`` that can be used later to unregister the recipient.
    ///
    /// Example registration code:
    /// ```
    /// PostOffice.default.register(recipient, ExampleRecipient.receiveNotification)
    /// ```
    @discardableResult
    public func register<Recipient: AnyObject, Notification: PostMarked>(
        queue: DispatchQueue? = nil,
        sender: Notification.RequiredSender? = nil,
        _ recipient: Recipient,
        _ method: @escaping (Recipient) -> (Notification, Notification.RequiredSender) -> Void)
    -> RecipientId {
        return registerAny(queue: queue, sender: sender, recipient, method)
    }

    /// Register a recipient and method with the `PostOffice`. This method will be called if both the posted notification
    /// and `sender` match the method's parameter's type.
    ///
    /// - parameter queue: The recipient will always receive posts on this queue. If `nil`, then the post will be made
    /// on the queue of the sender.
    /// - parameter sender: Optional. Ignored if `nil`, otherwise will limit the received notifications to only those sent by the `sender`.
    /// This sender must match the `RequiredSender` of the notification type. The `sender` is held weakly.
    /// - parameter recipient: The object that will receive the posted ``PostMarked``.
    /// - parameter method: The method of the `recipient` that will be called with the posted notification. Its two arguments
    /// include the notification, and an optional `sender`. The method will only be called if both the notification and `sender`
    /// types match.
    /// - returns: A ``RecipientId`` that can be used later to unregister the recipient.
    ///
    /// Example registration code:
    /// ```
    /// PostOffice.default.register(recipient, ExampleRecipient.receiveNotification)
    /// ```
    ///
    /// - note: Since `PostMarked` notifications require a sender, registering a method with an optional `sender` is discouraged.
    @discardableResult
    @available(*, deprecated, message: "Registering a method with an optional PostMarked.RequiredSender is discouraged. Remove the registered method's sender's optional to silence this warning.")
    public func register<Recipient: AnyObject, Notification: PostMarked>(
        queue: DispatchQueue? = nil,
        sender: Notification.RequiredSender? = nil,
        _ recipient: Recipient,
        _ method: @escaping (Recipient) -> (Notification, Notification.RequiredSender?) -> Void)
    -> RecipientId {
        return registerAny(queue: queue, sender: sender, recipient, method)
    }

    /// Register a recipient and method with the `PostOffice`. This method will be called if the posted notification
    /// matches the method's parameter's type.
    ///
    /// - parameter queue: The recipient will always receive posts on this queue. If `nil`, then the post will be made
    /// on the queue of the sender.
    /// - parameter sender: Optional. Ignored if `nil`, otherwise will limit the received notifications to only those sent by the `sender`.
    /// This sender must match the `RequiredSender` of the notification type. The `sender` is held weakly.
    /// - parameter recipient: The object that will receive the posted ``PostMarked``.
    /// - parameter method: The method of the `recipient` that will be called with the posted notification. Its one argument
    /// is the posted notification. The method will only be called if the notification matches the method's argument type.
    /// - returns: A ``RecipientId`` that can be used later to unregister the recipient.
    ///
    /// Example registration code:
    /// ```
    /// PostOffice.default.register(recipient, ExampleRecipient.receiveNotification)
    /// ```
    @discardableResult
    public func register<Recipient: AnyObject, Notification: PostMarked>(
        queue: DispatchQueue? = nil,
        sender: Notification.RequiredSender? = nil,
        _ recipient: Recipient,
        _ method: @escaping (Recipient) -> (Notification) -> Void)
    -> RecipientId {
        return registerAny(queue: queue, sender: sender, recipient, method)
    }

    // MARK: - Register Postmarked Blocks

    /// Register a block for the object and sender as parameters. The block will be called if the sender matches
    /// the `sender` param, if any. If the `sender` parameter is nil, then all senders will be sent to this block.
    /// If the notification is posted without a sender, this block will not be called.
    ///
    /// - parameter queue: The recipient will always receive posts on this queue. If `nil`, then the post will be made
    /// on the queue of the sender.
    /// - parameter sender: Optional. Ignored if `nil`, otherwise will limit the received notifications to only those sent by the `sender`.
    /// - parameter block: The block that will receive the posted ``PostMarked`` and sender.
    /// - returns: A ``RecipientId`` that can be used later to unregister the recipient.
    ///
    /// ```
    /// PostOffice.default.register { (notification: MyNotification, sender: MySender) in ... }
    /// ```
    @discardableResult
    public func register<Notification: PostMarked>(
        queue: DispatchQueue? = nil,
        sender: Notification.RequiredSender? = nil,
        _ block: @escaping (Notification, Notification.RequiredSender) -> Void)
    -> RecipientId {
        return registerAny(queue: queue, sender: sender, block)
    }

    @discardableResult
    @available(*, deprecated, message: "Registering a block with an optional PostMarked.RequiredSender is discouraged. Remove the registered block's sender's optional to silence this warning.")
    public func register<Notification: PostMarked>(
        queue: DispatchQueue? = nil,
        sender: Notification.RequiredSender? = nil,
        _ block: @escaping (Notification, Notification.RequiredSender?) -> Void)
    -> RecipientId {
        return registerAny(queue: queue, sender: sender, block)
    }

    /// Register a block from an optional `sender` with the notification as the single parameter.
    ///
    /// - parameter queue: The recipient will always receive posts on this queue. If `nil`, then the post will be made
    /// on the queue of the sender.
    /// - parameter sender: Optional. Ignored if `nil`, otherwise will limit the received notifications to only those sent by the `sender`.
    /// - parameter block: The block that will receive the posted ``PostMarked``.
    /// - returns: A ``RecipientId`` that can be used later to unregister the recipient.
    ///
    /// ```
    /// PostOffice.default.register { (notification: MyNotification) in ... }
    /// ```
    @discardableResult
    public func register<Notification: PostMarked>(
        queue: DispatchQueue? = nil,
        sender: Notification.RequiredSender? = nil,
        _ block: @escaping (Notification) -> Void)
    -> RecipientId {
        return register(queue: queue, sender: sender, { (notification: Notification, _: Notification.RequiredSender) in
            block(notification)
        })
    }

    // MARK: - Post Postmarked

    /// Sends the notification to all recipients that match the notification's type. Notifications that implement ``Postmarked``
    /// but do not implement ``Mail`` _must_ be sent with a sender.
    /// - parameter notification: The notification object to send, must conform to ``PostMarked``.
    /// - parameter sender: Required for ``PostMarked`` notifications that do not implement ``Mail``
    /// - seeAlso: ``post(_:sender:)-5afi5``
    public func post<Notification: PostMarked>(_ notification: Notification, sender: Notification.RequiredSender) {
        postPostmarkedHelper(notification, sender: sender)
    }

    // MARK: - Post Mail

    /// Sends the notification to all recipients that match the notification's type. Notifications that implement ``Postmarked``
    /// but do not implement ``Mail`` _must_ be sent with a sender.
    /// - parameter notification: The notification object to send, must conform to ``Mail``.
    /// - parameter sender: Optional. Ignored if `nil`. The object that represents the sender of the notification.
    /// - seeAlso: ``post(_:sender:)-3fny7``
    public func post<Sender: AnyObject>(_ notification: Mail, sender: Sender?) {
        postMailHelper(notification, sender: sender)
    }

    /// Sends the notification to all recipients that match the notification's type.
    /// - parameter notification: The notification object to send, must conform to ``Mail``.
    ///
    /// This notification will arrive for all recipients registered without a specfiic `sender` or with a `nil` `sender`.
    public func post(_ notification: Mail) {
        let anySender: AnyObject? = nil
        postMailHelper(notification, sender: anySender)
    }
}

// MARK: - Helpers

extension PostOffice {

    // MARK: - Method Registration Helpers

    @discardableResult
    private func registerAny<Recipient: AnyObject, Notification: Any, Sender: AnyObject>(
        queue: DispatchQueue? = nil,
        sender: Sender? = nil,
        _ recipient: Recipient,
        _ method: @escaping (Recipient) -> (Notification, Sender) -> Void)
    -> RecipientId {
        lock.lock()
        defer { lock.unlock() }
        let name = Key.key(for: Notification.self)
        let context = RecipientContext(recipient: AnyRecipient(recipient, method), queue: queue, sender: sender)
        listeners[name, default: []].append(context)
        recipientToKey[context.id] = name
        return context.id
    }

    @discardableResult
    private func registerAny<Recipient: AnyObject, Notification: Any, Sender: AnyObject>(
        queue: DispatchQueue? = nil,
        sender: Sender? = nil,
        _ recipient: Recipient,
        _ method: @escaping (Recipient) -> (Notification, Sender?) -> Void)
    -> RecipientId {
        lock.lock()
        defer { lock.unlock() }
        let name = Key.key(for: Notification.self)
        let context = RecipientContext(recipient: AnyRecipient(recipient, method), queue: queue, sender: sender)
        listeners[name, default: []].append(context)
        recipientToKey[context.id] = name
        return context.id
    }

    @discardableResult
    private func registerAny<Recipient: AnyObject, Notification, Sender: AnyObject>(
        queue: DispatchQueue? = nil,
        sender: Sender? = nil,
        _ recipient: Recipient,
        _ method: @escaping (Recipient) -> (Notification) -> Void)
    -> RecipientId {
        lock.lock()
        defer { lock.unlock() }
        let name = Key.key(for: Notification.self)
        let context = RecipientContext(recipient: AnyRecipient(recipient, method), queue: queue, sender: sender)
        listeners[name, default: []].append(context)
        recipientToKey[context.id] = name
        return context.id
    }

    @discardableResult
    private func registerAny<Recipient: AnyObject, Notification>(
        queue: DispatchQueue? = nil,
        _ recipient: Recipient,
        _ method: @escaping (Recipient) -> (Notification) -> Void)
    -> RecipientId {
        lock.lock()
        defer { lock.unlock() }
        let sender: AnyObject? = nil
        let name = Key.key(for: Notification.self)
        let context = RecipientContext(recipient: AnyRecipient(recipient, method), queue: queue, sender: sender)
        listeners[name, default: []].append(context)
        recipientToKey[context.id] = name
        return context.id
    }

    // MARK: - Block Registration Helpers

    @discardableResult
    private func registerAny<Notification, Sender: AnyObject>(queue: DispatchQueue? = nil,
                                                              sender: Sender? = nil,
                                                              _ block: @escaping (Notification, Sender) -> Void) -> RecipientId {
        lock.lock()
        defer { lock.unlock() }
        let name = Key.key(for: Notification.self)
        let optBlock = { (note: Notification, sender: Sender?) in
            guard let sender = sender else { return }
            block(note, sender)
        }
        let context = RecipientContext(recipient: AnyRecipient(optBlock), queue: queue, sender: sender)
        listeners[name, default: []].append(context)
        recipientToKey[context.id] = name
        return context.id
    }

    @discardableResult
    private func registerAny<Notification, Sender: AnyObject>(queue: DispatchQueue? = nil,
                                                              sender: Sender? = nil,
                                                              _ block: @escaping (Notification, Sender?) -> Void)
    -> RecipientId {
        lock.lock()
        defer { lock.unlock() }
        let name = Key.key(for: Notification.self)
        let context = RecipientContext(recipient: AnyRecipient(block), queue: queue, sender: sender)
        listeners[name, default: []].append(context)
        recipientToKey[context.id] = name
        return context.id
    }

    // MARK: - Post Helpers

    private func postMailHelper<Sender: AnyObject>(_ notification: Mail, sender: Sender?) {
        lock.lock()
        var allListeners: [RecipientContext] = []
        for key in listeners.keys {
            if key.test(notification),
               let typeListeners = listeners[key] {
                allListeners.append(contentsOf: typeListeners)
                listeners[key] = typeListeners.excluding({
                    return $0.recipient.canCollect || ($0.sender == nil && $0.requiresSender)
                })
            }
        }
        guard !allListeners.isEmpty else {
            lock.unlock()
            return
        }
        lock.unlock()

        for listener in allListeners {
            guard (listener.sender == nil && !listener.requiresSender) || listener.sender === sender else { continue }
            if let queue = listener.queue {
                queue.async {
                    listener.recipient.block?(notification, sender)
                }
            } else {
                listener.recipient.block?(notification, sender)
            }
        }
    }

    private func postPostmarkedHelper<Notification: PostMarked>(_ notification: Notification, sender: Notification.RequiredSender?) {
        lock.lock()
        var allListeners: [RecipientContext] = []
        for key in listeners.keys {
            if key.test(notification),
               let typeListeners = listeners[key] {
                allListeners.append(contentsOf: typeListeners)
                listeners[key] = typeListeners.excluding({
                    return $0.recipient.canCollect || ($0.sender == nil && $0.requiresSender)
                })
            }
        }
        guard !allListeners.isEmpty else {
            lock.unlock()
            return
        }
        lock.unlock()

        for listener in allListeners {
            guard (listener.sender == nil && !listener.requiresSender) || listener.sender === sender else { continue }
            if let queue = listener.queue {
                queue.async {
                    listener.recipient.block?(notification, sender)
                }
            } else {
                listener.recipient.block?(notification, sender)
            }
        }
    }
}
