//
//  File.swift
//  
//
//  Created by Adam Wulf on 8/27/22.
//

import Foundation

/// A type-erased `PostOffice` value, which holds the original `PostOffice` weakly.
public class AnyPostOffice<Contents>: PostOffice {
    public typealias MailContents = Contents
    let wrapped: any PostOffice<MailContents>

    init(_ postOffice: some PostOffice<Contents>) {
        wrapped = postOffice
    }

    public func receive(mail: Letter<Contents>) {
        wrapped.receive(mail: mail)
    }
}
