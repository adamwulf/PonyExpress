//
//  MailRecipient.swift
//  
//
//  Created by Adam Wulf on 8/27/22.
//

import Foundation

/// Represents a `MailRecipient` that can receive `Letter`s posted by the `PostOffice`.
/// The `MailContents` of the `MailRecipient` must match the `Contents` of the `PostOffice` where it is registered.
public protocol MailRecipient<MailContents>: AnyObject {
    associatedtype MailContents
    func receive(mail: Letter<MailContents>)
}
