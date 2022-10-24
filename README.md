# PonyExpress

`PonyExpress` provides a type-safe alternative to `NotificationCenter`.

[![CI](https://github.com/adamwulf/PonyExpress/actions/workflows/swift.yml/badge.svg)](https://github.com/adamwulf/PonyExpress/actions/workflows/swift.yml)

## Documentation

[View the documentation](https://adamwulf.github.io/PonyExpress/documentation/ponyexpress/) for `PonyExpress`.

## Installation

`PonyExpress` is available as a Swift package.

```
.package(url: "https://github.com/adamwulf/PonyExpress.git", .branch("main"))
```

https://github.com/adamwulf/PonyExpress.git

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
    
    func receive(_ notification: ExampleNotification, _ sender: AnyObject?) {
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
        token = PostOffice.default.register { [weak self] (_ note: ExampleNotification, _ sender: AnyObject?) in
            // make sure to hold `self` weakly inside this block to prevent a cycle
            // ... handle the notification
        }
    }
    
    deinit {
        PostOffice.default.unregister(token)
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

## Advanced Usage

### Senders

Sending a ``Letter`` can optionally include a `sender` as well. This is similar to `NotificationCenter`,
where recipients can optionally register for notifications sent only from a specific sender.

Recipients can choose to include or exclude the sender parameter from the receiving block or method.

```swift
class ExampleRecipient {
    init() {
        PostOffice.default.register(self, ExampleRecipient.receiveWithSender)
        PostOffice.default.register(self, ExampleRecipient.receiveWithoutSender)
    }

    func receiveWithSender(letter: ExampleLetter, sender: AnyObject?) {
        // ... process the Letter
    }

    func receiveWithoutSender(letter: ExampleLetter) {
        // ... process the Letter
    }
}

let recipient = ExampleRecipient()
PostOffice.default.register(sender: someSender, recipient, ExampleRecipient.receiveWithSender) 
PostOffice.default.register(sender: someSender, recipient, ExampleRecipient.receiveWithoutSender) 
```

### DispatchQueue

When registering with the ``PostOffice``, the recipient can choose which `DispatchQueue` to be notified on.
If no queue is specified, the notificaiton is sent synchronously on the queue that posts the ``Letter``. If
a queue is specified, the ``Letter`` is sent asynchronously on that queue.

```swift
PostOffice.default.register(queue: myDispatchQueue, recipient, MyClass.receive) 
```
