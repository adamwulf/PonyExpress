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

## Observing notifications

All observers must implement the `PostOffice` protocol, and define the `Letter` contents type.

```swift
class MyClass: MailRecipient {
    typealias MailContents = Int
    
    func init() {
        PostOffice.default.add(name: .MyNotificationName, observer: self) 
    }

    func receive(mail: Letter<Int>) {
        let notificationName: Notification.Name = mail.name
        let sender: AnyObject = mail.sender
        let contents: Int = mail.contents
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
