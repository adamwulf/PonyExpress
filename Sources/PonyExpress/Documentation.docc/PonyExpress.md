# ``PonyExpress``

`PonyExpress` provides a type-safe alternative to `NotificationCenter`. Inspired by
https://en.wikipedia.org/wiki/Pony_Express.

## Overview

With `PonyExpress`, the notification, called a ``Letter``, are type-safe and guaranteed
at compile-time to match the observer site.

When sending notifications, `NotificationCenter` only provides an optional `[AnyHashable: Any]?`
`userInfo` object for the `Notification`. Unfortunately, this is not type-safe,
and requires casting at the observer site. If the `userInfo` format ever changes
for a notification, there is no compile-time check that all observers expect the new
format.

### Letters and Packages

All notifications must implement the ``Letter`` protocol. A provided ``Package`` struct
is available to wrap any other type. You can provide your notifications in whatever format
best suites your code.

### Example

The following snippet shows how to initialize a <doc:PonyExpress/PostOffice> to send an `Int`
along with each ``Letter``. An observer block is added, and finally a ``Letter``
is sent with the ``PonyExpress/PonyExpress/post(_:sender:contents:)`` method.

Below is an example of creating a custom notification type, listening for and then sending
that type.

```swift
// Define a Letter that we can send
struct MyImportantNotification: Letter {
    let fumble: Int
    let bumble: Float
}

// Listen for a `MyImportantNotification`
postOffice.register({ (letter: MyImportantNotification) in
    print("received: \(letter.fumble)")
})

// Send a MyImportantNotification
postOffice.post(MyImportantNotification(fumble: 12, bumble: 14))
```

For convenience, any type can be wrapped in a ``Package`` and sent through a ``PostOffice``

```swift
// Create a `PostOffice`
let postOffice = PostOffice()

// Listen for packages
postOffice.register({ (letter: Package<Int>) in
    print("received: \(letter.contents)")
})

// Send a `Letter`
postOffice.post(Package<Int>(contents: 12))
```
