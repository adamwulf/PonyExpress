# Making a shared PonyExpress

`NotificationCenter` offers a default implementation with the static variable `NotificationCenter.default`.

For `PonyExpress`, you can mimic this behavior with the following snippet, substituting your `Contents`
type for the `Int` example below.

```swift
private let globalShared = PonyExpress<Int>()
public extension PonyExpress {
    static var shared: PonyExpress<Int> {
        return globalShared
    }
}
```

After being defined, you can access your new `PonyExpress` singleton as `PonyExpress.shared`, just as you
would with `NotificationCenter`.
