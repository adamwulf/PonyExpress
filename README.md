# PonyExpress

`PonyExpress` provides a type-safe alternative to `NotificationCenter`.

[![CI](https://github.com/adamwulf/PonyExpress/actions/workflows/swift.yml/badge.svg)](https://github.com/adamwulf/PonyExpress/actions/workflows/swift.yml)

## Documentation

[View the documentation](https://adamwulf.github.io/PonyExpress/documentation/ponyexpress/) for `PonyExpress`.

## Initialize Singleton

To mimic the `NotificationCenter.default`:

```swift
// Create a static shared PonyExpress
let globalDefault = PonyExpress<Int>()
public extension PonyExpress {
    static var default: PonyExpress<Int> {
        return globalDefault
    }
}
```

The above will create a `PonyExpress.default` that can send `Int` along with each notification.

## Observing notifications

All observers must implement the `PostOffice` protocol, and define the `Letter` contents type.

```swift
class MyClass: PostOffice {
    typealias MailContents = Int
    
    func receive(mail: Letter<Int>) {
        let notificationName: Notification.Name = mail.name
        let sender: AnyObject = mail.sender
        let contents: Int = mail.contents
    }
}
```

## UserInfo

While `Notification.userInfo` is typed as `[AnyHashable: Any]?`, the information sent along with 
`Letters` is strongly-typed to the `PonyExpress` instance that sends it.

```swift
// send Int with every notification
let intSender = PonyExpress<Int>()

intSender.post(.MyNotificationName, sender: nil, contents: 12)
```

It can be helpful to define an enum with each of the different types of information you might send.

```swift
// send your own enum
enum UserInfo {
    case fumble(variable: Int, other: Double)
    case mumble(things: [Float], name: String)
}
let mySender = PonyExpress<UserInfo>()
```

Then, your receiver will implement:

```swift
func receive(mail: Letter<UserInfo>) {
    guard case .mumble(let things, let name) = mail.contents else { return }
    // use things and name
}
```
