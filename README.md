# PonyExpress

`PonyExpress` provides a type-safe alternative to `NotificationCenter`.

[![CI](https://github.com/adamwulf/PonyExpress/actions/workflows/swift.yml/badge.svg)](https://github.com/adamwulf/PonyExpress/actions/workflows/swift.yml)

## Documentation

[View the documentation](https://adamwulf.github.io/PonyExpress/documentation/ponyexpress/) for `PonyExpress`. Documentation for Xcode
can be built with the included `builddocs.sh` script.

```bash
$ ./builddocs.sh
```

## Installation

`PonyExpress` is available as a Swift package.

```
.package(url: "https://github.com/adamwulf/PonyExpress.git", .branch("main"))
```

https://github.com/adamwulf/PonyExpress.git

## Quick Start

Any object or value can be sent as a notification. The recipient registers a handler
method for the type of object to receive.

An example:

```swift
struct ExampleNotification: Mail {
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

## Posting notifications

Any object can be sent as a notification, and only recipients registered for that notification type
will receive it.

```swift
// Send a struct
struct ExampleNotification: Mail {
    var info: Int
    var other: Float
}

PostOffice.default.post(ExampleNotification(info: 12, other: 15))


// or an enum
enum ExampleEnum: Mail {
    case fumble
    case mumble(bumble: Int)
}

PostOffice.default.post(ExampleEnum.mumble(bumble: 12))

// or anything at all
PostOffice.default.post("Just a String")
```

## Observing notifications

There are multiple ways to receive notifications. All observers define the type of notification and sender
that they want to receive, and only notifications and senders matching those types will be received.

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

    // An non-optional sender will require that the sender of the notification match
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

## Motivation

Notifications using `NotificationCenter` are sent through a `[String: Any]` `userInfo` property of the 
notification. This means that any observesr for that notification need to decode the userInfo using
something like `guard let myStuff = notification.userInfo["someProperty"] as? MyStuff`.

This provides a number of problems:

- `"someProperty"` could contain a typo. Using a constant is susceptible to copy/paste errors.
- Notifications are verbose - they require a notification name, the `userInfo` keys, and the actual values
- Values are not typesafe. Sending a `Float` and attempting to decoding a `CGFloat` will silently fail (or runtime error).
- When recieving unexpected data, observers either siliently fail or crash at runtime.

In `PonyExpress`, the goal is to reduce verbosity and move errors from runtime to compile time.

- Observers always receive the exact types they expect
- Any errors are provided at compile time, guaranteeing runtime type safety
- No extra `String` names or keys - only the actual data is sent without any extra boiler plate

## Thanks! ❤️

Enjoying `PonyExpress`? [Say thanks](https://github.com/sponsors/adamwulf) and buy me a coffee ☕️!
