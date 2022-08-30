# Making a shared PonyExpress

Similar to `NotificationCenter.default`, you can create `PonyExpress.shared` with the
following snippet, substituting your `Contents` type for the `Int` example below.

The following code will define a `shared` static ``PonyExpress`` that can be used
anywhere in your codebase.

```swift
private let globalShared = PonyExpress<Int>()
public extension PonyExpress {
    static var shared: PonyExpress<Int> {
        return globalShared
    }
}
```

After being defined, you can access your new ``PonyExpress`` singleton as `PonyExpress.shared`, just as you
would with `NotificationCenter.default`.
