# PonyExpress

`PonyExpress` provides a type-safe alternative to `NotificationCenter`.

[![CI](https://github.com/adamwulf/PonyExpress/actions/workflows/swift.yml/badge.svg)](https://github.com/adamwulf/PonyExpress/actions/workflows/swift.yml)

## Documentation

[View the documentation](https://adamwulf.github.io/PonyExpress/documentation/ponyexpress/) for `PonyExpress`.

## Initialize Singleton

To mimic the `NotificationCenter.default`:

```swift
// Create a static shared PostOffice
let globalDefault = PostOffice<Int>()
public extension PostOffice {
    static var default: PostOffice<Int> {
        return globalDefault
    }
}
```

The above will create a `PostOffice.default` that can send `Int` along with each notification.

## Notification Types

Any type that implements the `Letter` protocol can be sent as a notification. Recipients can then
register for that notification type explicitly. This allows the receiving method to be strongly
typed for the notification that it receives. Registration is similar to NotificationCenter, requiring
the object and the method name - the primary difference is that `PonyExpress` is type-safe.

For example:

```swift
struct ExampleNotification: Letter {
    var info: Int
    var other: Float
}

class ExampleRecipient {

    init() {
        PostOffice.default.register(recipient, ExampleRecipient.receive)
    }

    func receive(letter: ExampleNotification, sender: AnyObject?) {
        // ... process the Letter
    }
}

// Send the notification ...
PostOffice.default.post(ExampleNotification(info: 12, other: 15))
```

Above uses the `Recipient` protocol to define a single type of `Letter` that can be recieved,
but there are many ways to register for notifications, and all of them are typesafe for the
type of notification received.

## Observing notifications

There are multiple ways to receive notifications.

### Option 1: The `Recipient` protocol

Classes can implement the `Recipient` protocol to receive a single type of notification.
The `Recipient` requires setting the type of `Letter` recieved as its associated type, 
and then registering for that notification.

```swift
class MyClass: MailRecipient {
    typealias MailContents = Int
    
    func init() {
        PostOffice.default.register(self) 
    }

    func receive(letter: NotificationType, sender: AnyObject?) {
        let notificationName: String = letter.name
        let contents: Int = letter.anything
    }
}
```

Instead of implementing the protocol directly, a block or method can also be passed into the
PostOffice to observe `Letters`.

```swift
class MyClass {
    
    func init() {
        PostOffice.default.add(name: .MyNotificationName, observer: self.receive) 
    }
    
    func receive(mail: Letter<Int>) {
        let notificationName: Notification.Name = mail.name
        let sender: AnyObject = mail.sender
        let contents: Int = mail.contents
    }
}
```

## UserInfo

While `Notification.userInfo` is typed as `[AnyHashable: Any]?`, the information sent along with 
`Letters` is strongly-typed to the `PostOffice` instance that sends it.

```swift
// send Int with every notification
let intSender = PostOffice<Int>()

intSender.post(.MyNotificationName, sender: nil, contents: 12)
```

It can be helpful to define an enum with each of the different types of information you might send.

```swift
// send your own enum
enum UserInfo {
    case fumble(variable: Int, other: Double)
    case mumble(things: [Float], name: String)
}
let mySender = PostOffice<UserInfo>()
```

Then, your receiver will implement:

```swift
func receive(mail: Letter<UserInfo>) {
    guard case .mumble(let things, let name) = mail.contents else { return }
    // use things and name
}
```
