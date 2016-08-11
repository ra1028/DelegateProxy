//
//  Receiver.swift
//  DelegateProxy
//
//  Created by Ryo Aoyama on 8/10/16.
//  Copyright © 2016 Ryo Aoyama. All rights reserved.
//

public final class Receiver: Receivable {
    private let handler: Arguments -> Void
    
    public init(_ handler: Arguments -> Void) {
        self.handler = handler
    }
    
    public func send(arguments: Arguments) {
        handler(arguments)
    }
}