import UIKit

// MARK: - Setup some helper types for notifications and recipients.

protocol Mail { }
struct Letter: Mail { }
struct FakeMail { }
struct AnyRecipient {
    var block: ((Any) -> Void)

    init<U>(_ block: @escaping (_ notification: U) -> Void) {
        self.block = { notification in
            guard let notification = notification as? U else { return }
            block(notification)
        }
    }
}

class SingleCheckedExample {
    var recipients: [AnyRecipient] = []
    // This works, but requires any type besides `Mail` to be reimplemented in another class
    func register<Generic2: Mail>(block: @escaping (Generic2) -> Void) {
        recipients.append(AnyRecipient(block))
    }
    func register(block: @escaping (Mail) -> Void) {
        recipients.append(AnyRecipient(block))
    }
    func post(notification: Mail) {
        recipients.forEach({ $0.block(notification) })
    }
}
let example = SingleCheckedExample()
example.register(block: { (_ letter: Letter) in print("letter: \(letter)") })
example.register(block: { (_ letter: Mail) in print("mail: \(letter)") })
example.post(notification: Letter())

// MARK: - This is the barebones case, where the type of the recipient matches the type of the notification exactly
// Subtypes of the notification would have to be checked at runtime in the observer's block.
//
// Pros: Easy to understand
// Cons: No compile-time checks for subtypes in the observer

class ConstrainNotifierExample<Generic1> {
    var recipients: [AnyRecipient] = []
    // error: type 'Generic2' constrained to non-protocol, non-class type 'Generic1'
    func register(block: @escaping (Generic1) -> Void) {
        // I can register a block that exactly expects the class's generic type.
        // But i'd like the observer to be able to register a more specific method
        recipients.append(AnyRecipient(block))
    }
    func post(notification: Generic1) {
        recipients.forEach({ $0.block(notification) })
    }
}

let example1 = ConstrainNotifierExample<Mail>()
example1.register(block: { (_ mail: Mail) in print("received: \(mail)") })
// Unable to register subtype of Mail
// example1.register(block: { (_ letter: Letter) in print("received: \(letter)") })
example1.post(notification: Letter())

// Running to this point will correctly print "received: Letter()"

// MARK: - Constrain the observer instead of notifier
//
// Pros: Easy to understand
// Cons: No compile-time checks for notification types

class ConstrainObserverExample {
    var recipients: [AnyRecipient] = []
    // error: type 'Generic2' constrained to non-protocol, non-class type 'Generic1'
    func register<Generic1>(block: @escaping (Generic1) -> Void) {
        // I can register a block that exactly expects the class's generic type.
        // But i'd like the observer to be able to register a more specific method
        recipients.append(AnyRecipient(block))
    }
    func post(notification: Any) {
        recipients.forEach({ $0.block(notification) })
    }
}

let example2 = ConstrainObserverExample()
example2.register(block: { (_ mail: Mail) in print("received: \(mail)") })
example2.register(block: { (_ letter: Letter) in print("received: \(letter)") })
example2.post(notification: Letter())
// Unfortunately, also able to post notifications of any type
example2.post(notification: FakeMail())

// Running to this point will correctly print "received: Letter()" twice

// MARK: - Runtime checks
// In this example, we attempt to check the types match at runtime, as non-matching types signals a logic error
// by the programmer. Unfortunately, every runtime check fails, which allows the programmer to register
// type constrained blocks with non-matching types with no compiler or runtime error at all.
//
// Pros: Can constrain observer to a subtype of Generic1 with correct behavior
// Cons: Can constrain to an invalid type without error

class RuntimeCheckedExample<Generic1> {
    var recipients: [AnyRecipient] = []
    func register<Generic2>(block: @escaping (Generic2) -> Void) {
        let type1 = String(describing: Generic1.self)
        let type2 = String(describing: Generic2.self)
        // The below will always evaluate to false unless Generic2 == Generic1
        print("\(type1) is \(type2) == \(Generic2.self is Generic1.Type)")
        recipients.append(AnyRecipient(block))
    }
    func post(notification: Generic1) {
        recipients.forEach({ $0.block(notification) })
    }
}

let example3 = RuntimeCheckedExample<Mail>()
// We are allowed to register a subtype of Mail
example3.register(block: { (_ letter: Letter) in print("A received: \(letter)") })
// However, we can also register a type completed unrelated to Mail.
// The following register method should ideally compile-time error, or at least runtime error.
// Unfortuantely, there doesn't seem to be away to raise any error to the programmer for this logic error.
example3.register(block: { (_ letter: FakeMail) in print("B received: \(letter)") })
example3.post(notification: Letter())
// Correctly compile error when attempting to send a non-Mail notification
// example3.post(notification: FakeMail()) // compiler error

// Running to this point will:
// 1. Show the runtime type checking does not work
//    "Mail is Letter == false" should be "true"
// 2. correctly print "received: Letter()"

// MARK: - Twice constrained types, unsupported by the compiler
// What would be ideal, would be for the generic type of the registered block to be constrained to the
// generic type of the class. This unfortunately gives the error:
//   "type 'Generic2' constrained to non-protocol, non-class type 'Generic1'"
// Constraining Generic1 to a protocol or AnyObject has no effect.
//
// This would allow limiting sent notifications to some type, while also letting the
// observer constrain to a subtype of that notification type.
//
// Pros: Can constrain to a subtype, compile time errors for mismatched types
// Cons: Doesn't compile......

class CompileCheckedExample<Generic1> {
    var recipients: [AnyRecipient] = []
    // error: type 'Generic2' constrained to non-protocol, non-class type 'Generic1'
    func register<Generic2: Generic1>(block: @escaping (Generic2) -> Void) {
        print("1: " + String(describing: Generic1.self))
        print("2: " + String(describing: Generic2.self))
        // The below will always fail unless Generic2 == Generic1
        if Generic2.self is Generic1.Type { print("ok") }
        print("done")
        recipients.append(AnyRecipient(block))
    }
    func post(notification: Generic1) {
        recipients.forEach({ $0.block(notification) })
    }
}
let example4 = CompileCheckedExample<Mail>()
example4.register(block: { (_ letter: Letter) in print("received: \(letter)") })
