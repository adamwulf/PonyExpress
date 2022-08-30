# ``PonyExpress``

``PonyExpress`` provides a type-safe alternative to `NotificationCenter`.

### Example

The following snippet shows how to initialize a ``PonyExpress`` to send an `Int`
along with each ``Letter``. An observer block is added, and finally a ``Letter``
is sent with the ``PonyExpress/PonyExpress/post(_:sender:contents:)`` method.

```swift
// Create a ``PonyExpress``
let ponyExpress = PonyExpress<Int>()

// Add a ``PonyExpress/PonyExpress/PostOfficeBlock``
ponyExpress.add(.MyNotificationName) { letter in
    print("received \(letter)")
}

// Send a ``Letter``
ponyExpress.post(.MyNotificationName, sender: nil, contents: 12)
```
