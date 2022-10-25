# ``PonyExpress/PostOffice``

A `PostOffice` is able to send strongly-typed notifications from any strongly-typed sender, and will
relay them to all registered recipients appropriately.

## Overview

A ``default`` `PostOffice` is provided. To send a notification:

```swift
PostOffice.default.post(yourNotification, sender: yourSender)
```


## Topics

### Getting the Default Notification Center

- ``default``

### Creating a PostOffice

- ``init()``

### Adding Recipients

- ``register(queue:_:)``
- ``register(queue:_:_:)``
- ``register(queue:sender:_:_:)-v6ep``
- ``register(queue:sender:_:)-6ng6s``
- ``register(queue:sender:_:)-9pszg``
- ``register(queue:sender:_:)-7ykza``
- ``register(queue:sender:_:_:)-219pn``
- ``register(queue:sender:_:_:)-50a9``

### Removing Recipients

- ``unregister(_:)``

### Posting Notifications

- ``post(_:sender:)``
- ``post(_:)``
