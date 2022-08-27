//
//  PostOffice.swift
//  
//
//  Created by Adam Wulf on 8/27/22.
//

import Foundation

public protocol PostOffice: AnyObject {
    associatedtype MailContents
    func receive(mail: Letter<MailContents>)
}
