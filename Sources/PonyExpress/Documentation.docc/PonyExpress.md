# ``PonyExpress``

`PonyExpress` provides a type-safe alternative to `NotificationCenter`. Inspired by
https://en.wikipedia.org/wiki/Pony_Express.

## The Problem

When sending a notification with `NotificationCenter`, all information needs to be encoded
into a `[String: Any]` `userInfo` object attached to the notification. Sending all data through
arbitrary string keys presents a few problems:

1. There’s no compiler support to help catch mistakes or typos in a `String` key name
2. A wrongly typed object for a key will either silently fail at runtime if checked with `as? MyType`,
3. or, the above will crash at runtime when using `as! MyType`. Either way, there is no compile-time
support for notification types

All of these problems are from the observer silently failing at runtime, instead of loudly failing
at compile-time.


## The Solution

With `PonyExpress`, the notification is type-safe and guaranteed at compile-time to
match the observer site.

Instead of observing with a type-erased `#selector`, all observers in PonyExpress are strongly
typed. The example below registers a method to listen for MyNotification objects:

```
class ExampleRecipient {
    init {
        PostOffice.default.register(self, ExampleRecipient.receiveNotification)
    }

    func receiveNotification(notification: ExampleNotification) {
        count += 1
        testBlock?()
    }
}
```

When sending notifications, `NotificationCenter` only provides an optional `[AnyHashable: Any]?`
`userInfo` object for the `Notification`. Unfortunately, this requires casting at the
observer site. If the `userInfo` format ever changes for a notification, there is no
compile-time check that all observers expect the new format.

### Send Anything

Anything can be sent as a 

### Example

The following snippet shows how to initialize a <doc:PonyExpress/PostOffice> to send an `Int`
along with each notification. An observer block is added, and finally a notification
is sent with the ``PonyExpress/PonyExpress/post(_:sender:contents:)`` method.

Below is an example of creating a custom notification type, listening for and then sending
that type.

```swift
// Define a notification that we can send
struct MyImportantNotification {
    let fumble: Int
    let bumble: Float
}

// Listen for a `MyImportantNotification`
postOffice.register({ (notification: MyImportantNotification) in
    // process notification
})

// Send a MyImportantNotification
postOffice.post(MyImportantNotification(fumble: 12, bumble: 14))
```

For convenience, any type can be wrapped in a ``Package`` and sent through a ``PostOffice``

```swift
// Create a `PostOffice`
let postOffice = PostOffice()

// Listen for packages
postOffice.register({ (notification: Package<Int>) in
    // process notification
})

// Send a notification
postOffice.post(Package<Int>(contents: 12))
```
