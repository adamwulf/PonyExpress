//
//  PostOffice.swift
//  
//
//  Created by Adam Wulf on 8/27/22.
//

import Foundation

/// Represents a `PostOffice` that can receive `Letter`s posted by the `PonyExpress`.
/// The `MailContents` of the `PostOffice` must match the `Contents` of the `PonyExpress` where it is registered.
public protocol PostOffice<MailContents>: AnyObject {
    associatedtype MailContents
    func receive(mail: Letter<MailContents>)
}
