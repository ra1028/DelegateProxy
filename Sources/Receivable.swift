//
//  Receivable.swift
//  DelegateProxy
//
//  Created by Ryo Aoyama on 8/10/16.
//  Copyright © 2016 Ryo Aoyama. All rights reserved.
//

public protocol Receivable {
    func send(arguments: Arguments)
}

public extension Receivable {
    @discardableResult
    func subscribe(to proxy: DelegateProxy, selector: Selector) -> Self {
        proxy.receive(selector: selector, receiver: self)
        return self
    }
}
