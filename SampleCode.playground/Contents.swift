import PonyExpress

struct ExampleNotification: Mail {
    var info: Int
    var other: Float
}

class ExampleRecipient {
    init() {
        PostOffice.default.register(self, ExampleRecipient.receive)
    }

    func receive(notification: ExampleNotification) {
        // ... process the notification
    }
}

// Send the notification ...
let recipient = ExampleRecipient()
PostOffice.default.post(ExampleNotification(info: 12, other: 15))

// or an enum
enum ExampleEnum: Mail {
    case fumble
    case mumble(bumble: Int)
}

PostOffice.default.register { (_: ExampleEnum) in
    // ... process the notification
}

PostOffice.default.post(ExampleEnum.mumble(bumble: 12))
