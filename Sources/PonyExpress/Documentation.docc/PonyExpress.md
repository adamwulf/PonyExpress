# ``PonyExpress``

`PonyExpress` provides a type-safe alternative to `NotificationCenter`.

## Overview

With `PonyExpress`, the contents of the notification, called a ``Letter``, are type-safe
and guaranteed at compile-time to match the observer site.

When sending notifications, `NotificationCenter` only provides an optional `[AnyHashable: Any]?`
`userInfo` object for the `Notification`. Unfortunately, this is not type-safe,
and requires casting at the observer site. If the `userInfo` format ever changes
for a notification, there is no compile-time check that all observers expect the new
format.

### Example

The following snippet shows how to initialize a <doc:PonyExpress/PonyExpress> to send an `Int`
along with each ``Letter``. An observer block is added, and finally a ``Letter``
is sent with the ``PonyExpress/PonyExpress/post(_:sender:contents:)`` method.

```swift
// Create a `PostOffice`
let postOffice = PostOffice<Int>()

// Add a `PostOfficeBlock`
postOffice.add(.MyNotificationName) { letter in
    print("received \(letter)")
}

// Send a `Letter`
postOffice.post(.MyNotificationName, sender: nil, contents: 12)
```
