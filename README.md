# PonyExpress

`PonyExpress` provides a type-safe alternative to `NotificationCenter`.

## Initialize Singleton

To mimic the `NotificationCenter.default`:

```
// Create a static shared PonyExpress
let globalDefault = PonyExpress<Int>()
public extension PonyExpress {
    static var default: PonyExpress<Int> {
        return globalDefault
    }
}
```

The above will create a `PonyExpress.default` that can send `Int` along with each notification.

## UserInfo

While `Notification.userInfo` is typed as `[AnyHashable: Any]?`, the information sent along with 
`Letters` is strongly-typed to the `PonyExpress`.

```
// send Int with every notification
let intSender = PonyExpress<Int>()
```

It can be helpful to define an enum with each of the different types of information you might send.

```
// send your own enum
enum UserInfo {
    case fumble(variable: Int, other: Double)
    case mumble(things: [Float], name: String)
}
let mySender = PonyExpress<UserInfo>()
```

Then, your receiver will implement:

```
func receive(mail: Letter<UserInfo>) {
    guard case .mumble(let things, let name) = mail.contents else { return }
    // use things and name
}
```
