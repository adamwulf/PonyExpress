# ``PonyExpress``

`PonyExpress` provides a type-safe alternative to `NotificationCenter`. Inspired by
https://en.wikipedia.org/wiki/Pony_Express.

## Quick Start

Any object or value can be sent as a notification. The observer registers a handler
method for the type of object to receive.

An example:

```swift
struct ExampleNotification {
    var info: Int
    var other: Float
}

class ExampleRecipient {
    init() {
        PostOffice.default.register(self, ExampleRecipient.receive)
    }

    func receive(notification: ExampleNotification) {
        // ... process the notification
    }
}

// Send the notification ...
PostOffice.default.post(ExampleNotification(info: 12, other: 15))
```

## Observing notifications

There are multiple ways to receive notifications.

### Option 1: Register an object and method

Just as in `NotificationCenter`, the object is held weakly, and does not need to
be explicitly unregistered when the object deallocs. 

```swift
class MyClass {
    func init() {
        PostOffice.default.register(self, MyClass.receive) 
    }
    
    func receive(notification: ExampleNotification) {
        // process the notification
    }
}
```

### Option 2: Register a block

A block or method can be passed into the ``PostOffice`` to observe notifications. Blocks
are held strongly inside the ``PostOffice``, and must be unregistered explicitly.

```swift
class MyClass {
    var token: RecipientId? 
    
    func init() {
        PostOffice.default.register { [weak self] (notification: ExampleNotification) in
            // process the notification
        }
    }
}
```

## Unregistering

Every `register()` method will return a `RecipientId`, which can be used to unregister the
recipient.


```swift
let recipient = ExampleRecipient()
let id = PostOffice.default.register(recipient)
...
PostOffice.default.unregister(id)
```

## Senders

Sending a notification can optionally include a `sender` as well. This is similar to `NotificationCenter`,
where recipients can optionally register for notifications sent only from a specific sender. In PonyExpress,
both the notification and sender are strongly typed.

Recipients can choose to include or exclude the sender parameter from the receiving block or method.

```swift
class ExampleRecipient {
    init() {
        PostOffice.default.register(self, ExampleRecipient.receiveWithOptionalSender)
        PostOffice.default.register(self, ExampleRecipient.receiveWithSender)
        PostOffice.default.register(self, ExampleRecipient.receiveWithoutSender)
    }

    // An optional sender will require that the sender of the notification either
    // a) match the type of the `sender`, or b) be `nil`
    func receiveWithOptionalSender(notification: ExampleNotification, sender: ExampleSender?) {
        // ... process the notification
    }

    // An non-optional sender will require that the sender of the notification either match
    // the `sender` type
    func receiveWithSender(notification: ExampleNotification, sender: ExampleSender) {
        // ... process the notification
    }

    // Omitting a `sender` parameter will receive notifications for senders of any type, even nil senders
    func receiveWithoutSender(notification: ExampleNotification) {
        // ... process the notification
    }
}

// recipients can also register to receive notifications from a singular exact-match sender
let sender = ExampleSender()
let recipient = ExampleRecipient()
PostOffice.default.register(sender: sender, recipient, ExampleRecipient.receiveWithSender) 
PostOffice.default.register(sender: sender, recipient, ExampleRecipient.receiveWithoutSender) 
```

When posting a notification, a sender can optionally be provided.

```swift
PostOffice.default.post(ExampleNotification(info: 12, other: 15), sender: sender)
```

## DispatchQueues

When registering with a ``PostOffice``, the recipient can choose which `DispatchQueue` to be notified on.
If no queue is specified, the notificaiton is sent synchronously on the queue that posts the notification. If
a queue is specified, the notification is sent asynchronously on that queue.

```swift
PostOffice.default.register(queue: myDispatchQueue, recipient, MyClass.receive) 
```
